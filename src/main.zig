const std = @import("std");
const c = @cImport({
    @cInclude("enet/enet.h");
    @cInclude("stdlib.h");
    @cInclude("string.h");
    @cInclude("time.h");
});

// Import our modules
const config = @import("config.zig");
const types = @import("types.zig");
const Player = @import("handle/player_info.zig").Player;
const World = @import("handle/world_info.zig").World;
const ItemDB = @import("handle/item_defination.zig").ItemDB;
const PacketHandler = @import("handle/packet_handler.zig").PacketHandler;
const ServerPool = @import("server/server_pool.zig").ServerPool;

// Global allocator
pub const allocator = std.heap.page_allocator;

// Global variables
pub var server: ?*c.ENetHost = null;
pub var worlds: std.ArrayList(World) = undefined;
pub var items: std.AutoHashMap(i32, ItemDB) = undefined;
pub var players: std.AutoHashMap(?*c.ENetPeer, *Player) = undefined;
pub var packet_handler: PacketHandler = undefined;

// Global server pool
var server_pool: ServerPool = undefined;

// Initialize global data structures
pub fn initGlobals() !void {
    worlds = std.ArrayList(World).init(allocator);
    items = std.AutoHashMap(i32, ItemDB).init(allocator);
    players = std.AutoHashMap(?*c.ENetPeer, *Player).init(allocator);
    packet_handler = PacketHandler.init(allocator);
}

// Cleanup global data structures
pub fn deinitGlobals() void {
    worlds.deinit();
    items.deinit();
    
    // Cleanup all players
    var player_iter = players.iterator();
    while (player_iter.next()) |entry| {
        entry.value_ptr.*.deinit();
        allocator.destroy(entry.value_ptr.*);
    }
    players.deinit();
}

pub fn main() !void {
    // Load configuration
    config.global_config = config.Config.loadFromFile("config.json") catch config.global_config;
    
    // Initialize server pool
    server_pool = ServerPool.init(std.heap.page_allocator);
    defer server_pool.deinit();

    std.debug.print("Starting GrowSC Server...\n", .{});
    std.debug.print("Server name: {s}\n", .{config.global_config.server_name});
    std.debug.print("Server version: {s}\n", .{config.global_config.server_version});
    std.debug.print("Server port: {}\n", .{config.global_config.server_port});

    // Start server
    try server_pool.start();
    defer server_pool.stop();

    // Run server
    try server_pool.run();
}

fn serverLoop() !void {
    var event: c.ENetEvent = undefined;
    
    while (true) {
        const service_result = c.enet_host_service(server, &event, 1000);
        
        switch (service_result) {
            c.ENET_EVENT_TYPE_CONNECT => {
                std.debug.print("New connection from {}\n", .{event.peer.*.address.host});
                // Handle new connection
                try handleNewConnection(event.peer);
            },
            c.ENET_EVENT_TYPE_RECEIVE => {
                // Handle received packet
                try handlePacket(event.peer, event.packet.*.data, event.packet.*.dataLength);
                c.enet_packet_destroy(event.packet);
            },
            c.ENET_EVENT_TYPE_DISCONNECT => {
                std.debug.print("Client disconnected\n", .{});
                // Handle disconnection
                try handleDisconnection(event.peer);
            },
            c.ENET_EVENT_TYPE_NONE => {
                // No events, continue
            },
            else => {
                std.debug.print("Unknown event type: {}\n", .{service_result});
            },
        }
    }
}

fn handleNewConnection(peer: ?*c.ENetPeer) !void {
    // Create new player instance
    const player = try allocator.create(Player);
    player.* = Player.init(allocator);
    
    // Store player in our map
    try players.put(peer, player);
    
    // Set peer data to player
    peer.?.data = player;
    
    std.debug.print("Player created for peer\n", .{});
}

fn handlePacket(peer: ?*c.ENetPeer, data: [*]const u8, dataLength: usize) !void {
    // Convert to slice
    const data_slice = data[0..dataLength];
    
    // Use packet handler to process the packet
    try packet_handler.handlePacket(peer, data_slice);
}

fn handleDisconnection(peer: ?*c.ENetPeer) !void {
    // Get and cleanup player
    if (players.get(peer)) |player| {
        player.deinit();
        allocator.destroy(player);
        _ = players.remove(peer);
    }
    
    // Reset peer data
    peer.?.data = null;
}

test "basic test" {
    try std.testing.expectEqual(1, 1);
} 