// TODO: Port server pool logic from C++ server_pool.h here

const std = @import("std");
const c = @cImport({
    @cInclude("enet/enet.h");
    @cInclude("time.h");
});
const config = @import("../config.zig");
const Player = @import("../handle/player_info.zig").Player;
const World = @import("../handle/world_info.zig").World;
const ItemDB = @import("../handle/item_defination.zig").ItemDB;
const PacketHandler = @import("../handle/packet_handler.zig").PacketHandler;
const ActionHandler = @import("../action/action.zig").ActionHandler;
const Database = @import("../database.zig").Database;
const EventSystem = @import("../events.zig").EventSystem;

pub const ServerState = enum {
    starting,
    running,
    stopping,
    stopped,
    maintenance,
};

pub const ServerStats = struct {
    uptime: i64 = 0,
    start_time: i64 = 0,
    total_connections: u64 = 0,
    current_connections: u32 = 0,
    max_connections: u32 = 0,
    total_packets_received: u64 = 0,
    total_packets_sent: u64 = 0,
    bytes_received: u64 = 0,
    bytes_sent: u64 = 0,
    
    pub fn init() ServerStats {
        return ServerStats{
            .start_time = std.time.milliTimestamp(),
        };
    }
    
    pub fn updateUptime(self: *ServerStats) void {
        self.uptime = std.time.milliTimestamp() - self.start_time;
    }
    
    pub fn addConnection(self: *ServerStats) void {
        self.total_connections += 1;
        self.current_connections += 1;
        if (self.current_connections > self.max_connections) {
            self.max_connections = self.current_connections;
        }
    }
    
    pub fn removeConnection(self: *ServerStats) void {
        if (self.current_connections > 0) {
            self.current_connections -= 1;
        }
    }
    
    pub fn addPacketReceived(self: *ServerStats, bytes: usize) void {
        self.total_packets_received += 1;
        self.bytes_received += bytes;
    }
    
    pub fn addPacketSent(self: *ServerStats, bytes: usize) void {
        self.total_packets_sent += 1;
        self.bytes_sent += bytes;
    }
};

pub const ServerPool = struct {
    allocator: std.mem.Allocator,
    state: ServerState = .stopped,
    stats: ServerStats,
    
    // Server components
    server: ?*c.ENetHost,
    worlds: std.ArrayList(World),
    items: std.AutoHashMap(i32, ItemDB),
    players: std.AutoHashMap(?*c.ENetPeer, *Player),
    packet_handler: PacketHandler,
    action_handler: ActionHandler,
    database: Database,
    event_system: EventSystem,
    
    // Threading
    main_thread: ?std.Thread,
    save_thread: ?std.Thread,
    event_thread: ?std.Thread,
    
    // Thread safety
    mutex: std.Thread.Mutex = .{},
    condition: std.Thread.Condition = .{},
    
    // Timers
    last_save: i64 = 0,
    last_event: i64 = 0,
    last_cleanup: i64 = 0,
    
    // Shutdown
    shutdown_requested: bool = false,
    
    pub fn init(allocator: std.mem.Allocator) ServerPool {
        return ServerPool{
            .allocator = allocator,
            .stats = ServerStats.init(),
            .server = null,
            .worlds = std.ArrayList(World).init(allocator),
            .items = std.AutoHashMap(i32, ItemDB).init(allocator),
            .players = std.AutoHashMap(?*c.ENetPeer, *Player).init(allocator),
            .packet_handler = PacketHandler.init(allocator),
            .action_handler = ActionHandler.init(allocator, &PacketHandler.init(allocator)),
            .database = Database.init(allocator),
            .event_system = EventSystem.init(allocator),
        };
    }
    
    pub fn deinit(self: *ServerPool) void {
        self.stop();
        
        // Cleanup players
        var player_iter = self.players.iterator();
        while (player_iter.next()) |entry| {
            entry.value_ptr.*.deinit();
            self.allocator.destroy(entry.value_ptr.*);
        }
        
        // Cleanup worlds
        for (self.worlds.items) |*world| {
            world.deinit();
        }
        
        // Cleanup items
        var item_iter = self.items.iterator();
        while (item_iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        
        self.worlds.deinit();
        self.items.deinit();
        self.players.deinit();
    }
    
    pub fn start(self: *ServerPool) !void {
        if (self.state != .stopped) {
            return error.ServerAlreadyRunning;
        }
        
        self.state = .starting;
        
        // Initialize ENet
        if (c.enet_initialize() != 0) {
            return error.ENetInitFailed;
        }
        
        // Create server
        var address: c.ENetAddress = undefined;
        address.host = c.ENET_HOST_ANY;
        address.port = config.global_config.server_port;
        
        self.server = c.enet_host_create(&address, config.global_config.max_players, config.global_config.max_channels, 0, 0);
        if (self.server == null) {
            return error.ServerCreateFailed;
        }
        
        // Load initial data
        try self.loadInitialData();
        
        // Start threads
        try self.startThreads();
        
        self.state = .running;
        std.debug.print("Server started successfully on port {}\n", .{address.port});
    }
    
    pub fn stop(self: *ServerPool) void {
        if (self.state == .stopped) return;
        
        self.state = .stopping;
        self.shutdown_requested = true;
        
        // Signal threads to stop
        self.condition.signal();
        
        // Wait for threads to finish
        if (self.main_thread) |thread| {
            thread.join();
        }
        if (self.save_thread) |thread| {
            thread.join();
        }
        if (self.event_thread) |thread| {
            thread.join();
        }
        
        // Save data
        self.saveAllData() catch |err| {
            std.debug.print("Error saving data during shutdown: {}\n", .{err});
        };
        
        // Cleanup ENet
        if (self.server != null) {
            c.enet_host_destroy(self.server);
            self.server = null;
        }
        c.enet_deinitialize();
        
        self.state = .stopped;
        std.debug.print("Server stopped\n", .{});
    }
    
    pub fn run(self: *ServerPool) !void {
        if (self.state != .running) {
            return error.ServerNotRunning;
        }
        
        var event: c.ENetEvent = undefined;
        
        while (!self.shutdown_requested) {
            const service_result = c.enet_host_service(self.server, &event, 1000);
            
            switch (service_result) {
                c.ENET_EVENT_TYPE_CONNECT => {
                    try self.handleNewConnection(event.peer);
                },
                c.ENET_EVENT_TYPE_RECEIVE => {
                    try self.handlePacket(event.peer, event.packet.*.data, event.packet.*.dataLength);
                    c.enet_packet_destroy(event.packet);
                },
                c.ENET_EVENT_TYPE_DISCONNECT => {
                    try self.handleDisconnection(event.peer);
                },
                c.ENET_EVENT_TYPE_NONE => {
                    // No events, continue
                },
                else => {
                    std.debug.print("Unknown event type: {}\n", .{service_result});
                },
            }
            
            // Update stats
            self.stats.updateUptime();
        }
    }
    
    fn handleNewConnection(self: *ServerPool, peer: ?*c.ENetPeer) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        // Create new player
        const player = try self.allocator.create(Player);
        player.* = Player.init(self.allocator);
        
        // Store player
        try self.players.put(peer, player);
        peer.?.data = player;
        
        // Update stats
        self.stats.addConnection();
        
        std.debug.print("New connection from {}\n", .{peer.?.address.host});
    }
    
    fn handlePacket(self: *ServerPool, peer: ?*c.ENetPeer, data: [*]const u8, dataLength: usize) !void {
        const data_slice = data[0..dataLength];
        
        // Update stats
        self.stats.addPacketReceived(dataLength);
        
        // Handle packet
        try self.packet_handler.handlePacket(peer, data_slice);
    }
    
    fn handleDisconnection(self: *ServerPool, peer: ?*c.ENetPeer) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        // Get and cleanup player
        if (self.players.get(peer)) |player| {
            player.deinit();
            self.allocator.destroy(player);
            _ = self.players.remove(peer);
        }
        
        // Reset peer data
        peer.?.data = null;
        
        // Update stats
        self.stats.removeConnection();
        
        std.debug.print("Client disconnected\n", .{});
    }
    
    fn loadInitialData(self: *ServerPool) !void {
        // Load items database
        self.items = try self.database.loadItemsDatabase();
        
        // Load default worlds
        const default_worlds = [_][]const u8{ "EXIT", "START", "MAIN" };
        for (default_worlds) |world_name| {
            if (self.database.loadWorld(world_name)) |world| {
                try self.worlds.append(world.*);
            } else |_| {
                // Create default world if it doesn't exist
                const world = try World.createWorld(self.allocator, world_name, "SYSTEM");
                try self.worlds.append(world);
            }
        }
        
        std.debug.print("Initial data loaded\n", .{});
    }
    
    fn startThreads(self: *ServerPool) !void {
        // Start save thread
        self.save_thread = try std.Thread.spawn(.{}, saveThread, .{self});
        
        // Start event thread
        self.event_thread = try std.Thread.spawn(.{}, eventThread, .{self});
        
        std.debug.print("Background threads started\n", .{});
    }
    
    fn saveThread(self: *ServerPool) void {
        while (!self.shutdown_requested) {
            self.mutex.lock();
            defer self.mutex.unlock();
            
            const now = std.time.milliTimestamp();
            if (now - self.last_save >= @as(i64, @intCast(config.global_config.save_interval * 1000))) {
                self.saveAllData() catch |err| {
                    std.debug.print("Error saving data: {}\n", .{err});
                };
                self.last_save = now;
            }
            
            // Wait for next save cycle or shutdown signal
            self.condition.wait(&self.mutex);
        }
    }
    
    fn eventThread(self: *ServerPool) void {
        while (!self.shutdown_requested) {
            self.mutex.lock();
            defer self.mutex.unlock();
            
            const now = std.time.milliTimestamp();
            if (now - self.last_event >= @as(i64, @intCast(config.global_config.event_interval * 1000))) {
                self.processEvents() catch |err| {
                    std.debug.print("Error processing events: {}\n", .{err});
                };
                self.last_event = now;
            }
            
            // Wait for next event cycle or shutdown signal
            self.condition.wait(&self.mutex);
        }
    }
    
    fn saveAllData(self: *ServerPool) !void {
        // Save all players
        var player_iter = self.players.iterator();
        while (player_iter.next()) |entry| {
            const filename = try std.fmt.allocPrint(self.allocator, "{s}.json", .{entry.value_ptr.*.temporary_tank_id_name});
            defer self.allocator.free(filename);
            try self.database.savePlayer(entry.value_ptr.*, filename);
        }
        
        // Save all worlds
        for (self.worlds.items) |*world| {
            try self.database.saveWorld(world);
        }
        
        // Save items database
        try self.database.saveItemsDatabase(self.items);
        
        // Save server state
        try self.database.saveServerState(self.stats);
        
        std.debug.print("Data saved successfully\n", .{});
    }
    
    fn processEvents(self: *ServerPool) !void {
        // Process events through event system
        try self.event_system.processEvents();
        
        // Process world-specific events
        for (self.worlds.items) |*world| {
            try world.processEvents();
        }
        
        std.debug.print("Events processed\n", .{});
    }
    
    pub fn getStats(self: *ServerPool) ServerStats {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        return self.stats;
    }
    
    pub fn getPlayerCount(self: *ServerPool) u32 {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        return self.stats.current_connections;
    }
    
    pub fn getWorldCount(self: *ServerPool) u32 {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        return @intCast(self.worlds.items.len);
    }
    
    pub fn broadcastMessage(self: *ServerPool, message: []const u8) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        // TODO: Implement broadcast message to all players
        _ = message;
    }
    
    pub fn kickPlayer(self: *ServerPool, player_name: []const u8, reason: []const u8) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        // TODO: Implement player kicking
        _ = player_name;
        _ = reason;
    }
    
    pub fn banPlayer(self: *ServerPool, player_name: []const u8, reason: []const u8, duration: i64) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        // TODO: Implement player banning
        _ = player_name;
        _ = reason;
        _ = duration;
    }
    
    pub fn createWorld(self: *ServerPool, name: []const u8, owner: []const u8) !*World {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        const world = try World.createWorld(self.allocator, name, owner);
        try self.worlds.append(world);
        
        return &self.worlds.items[self.worlds.items.len - 1];
    }
    
    pub fn destroyWorld(self: *ServerPool, name: []const u8) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        for (self.worlds.items, 0..) |*world, i| {
            if (std.mem.eql(u8, world.name, name)) {
                world.deinit();
                _ = self.worlds.orderedRemove(i);
                break;
            }
        }
    }
    
    pub fn findWorld(self: *ServerPool, name: []const u8) ?*World {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        for (self.worlds.items) |*world| {
            if (std.mem.eql(u8, world.name, name)) {
                return world;
            }
        }
        return null;
    }
    
    pub fn findPlayer(self: *ServerPool, name: []const u8) ?*Player {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        var player_iter = self.players.iterator();
        while (player_iter.next()) |entry| {
            if (std.mem.eql(u8, entry.value_ptr.*.temporary_tank_id_name, name)) {
                return entry.value_ptr.*;
            }
        }
        return null;
    }
};
