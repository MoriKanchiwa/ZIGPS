const std = @import("std");
const config = @import("config.zig");
const Player = @import("handle/player_info.zig").Player;
const World = @import("handle/world_info.zig").World;

pub const EventType = enum {
    player_join,
    player_leave,
    player_move,
    player_chat,
    player_action,
    world_create,
    world_destroy,
    world_update,
    item_drop,
    item_pickup,
    special_event,
    scheduled_task,
};

pub const EventPriority = enum {
    low,
    normal,
    high,
    critical,
};

pub const GameEvent = struct {
    id: u64,
    event_type: EventType,
    priority: EventPriority,
    timestamp: i64,
    player_name: ?[]const u8,
    world_name: ?[]const u8,
    data: std.StringHashMap([]const u8),
    
    pub fn init(allocator: std.mem.Allocator, event_type: EventType, priority: EventPriority) GameEvent {
        return GameEvent{
            .id = std.time.milliTimestamp(),
            .event_type = event_type,
            .priority = priority,
            .timestamp = std.time.milliTimestamp(),
            .player_name = null,
            .world_name = null,
            .data = std.StringHashMap([]const u8).init(allocator),
        };
    }
    
    pub fn deinit(self: *GameEvent) void {
        self.data.deinit();
    }
    
    pub fn setPlayer(self: *GameEvent, name: []const u8) void {
        self.player_name = name;
    }
    
    pub fn setWorld(self: *GameEvent, name: []const u8) void {
        self.world_name = name;
    }
    
    pub fn addData(self: *GameEvent, key: []const u8, value: []const u8) !void {
        try self.data.put(key, value);
    }
};

pub const ScheduledTask = struct {
    id: u64,
    name: []const u8,
    interval: u64, // milliseconds
    last_run: i64,
    next_run: i64,
    enabled: bool,
    callback: *const fn() void,
    
    pub fn init(name: []const u8, interval: u64, callback: *const fn() void) ScheduledTask {
        const now = std.time.milliTimestamp();
        return ScheduledTask{
            .id = @intCast(now),
            .name = name,
            .interval = interval,
            .last_run = 0,
            .next_run = now + @as(i64, @intCast(interval)),
            .enabled = true,
            .callback = callback,
        };
    }
    
    pub fn shouldRun(self: *ScheduledTask) bool {
        if (!self.enabled) return false;
        return std.time.milliTimestamp() >= self.next_run;
    }
    
    pub fn execute(self: *ScheduledTask) void {
        if (self.shouldRun()) {
            self.callback();
            self.last_run = std.time.milliTimestamp();
            self.next_run = self.last_run + @as(i64, @intCast(self.interval));
        }
    }
};

pub const EventSystem = struct {
    allocator: std.mem.Allocator,
    events: std.ArrayList(GameEvent),
    scheduled_tasks: std.ArrayList(ScheduledTask),
    event_handlers: std.AutoHashMap(EventType, std.ArrayList(*const fn(GameEvent) void)),
    
    pub fn init(allocator: std.mem.Allocator) EventSystem {
        return EventSystem{
            .allocator = allocator,
            .events = std.ArrayList(GameEvent).init(allocator),
            .scheduled_tasks = std.ArrayList(ScheduledTask).init(allocator),
            .event_handlers = std.AutoHashMap(EventType, std.ArrayList(*const fn(GameEvent) void)).init(allocator),
        };
    }
    
    pub fn deinit(self: *EventSystem) void {
        // Cleanup events
        for (self.events.items) |*event| {
            event.deinit();
        }
        
        // Cleanup event handlers
        var handler_iter = self.event_handlers.iterator();
        while (handler_iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        
        self.events.deinit();
        self.scheduled_tasks.deinit();
        self.event_handlers.deinit();
    }
    
    pub fn addEvent(self: *EventSystem, event: GameEvent) !void {
        try self.events.append(event);
        
        // Process event immediately
        try self.processEvent(event);
    }
    
    pub fn addScheduledTask(self: *EventSystem, task: ScheduledTask) !void {
        try self.scheduled_tasks.append(task);
    }
    
    pub fn registerEventHandler(self: *EventSystem, event_type: EventType, handler: *const fn(GameEvent) void) !void {
        if (self.event_handlers.get(event_type)) |handlers| {
            try handlers.append(handler);
        } else {
            var new_handlers = std.ArrayList(*const fn(GameEvent) void).init(self.allocator);
            try new_handlers.append(handler);
            try self.event_handlers.put(event_type, new_handlers);
        }
    }
    
    pub fn processEvents(self: *EventSystem) !void {
        // Process scheduled tasks
        for (self.scheduled_tasks.items) |*task| {
            task.execute();
        }
        
        // Process pending events
        while (self.events.items.len > 0) {
            const event = self.events.orderedRemove(0);
            try self.processEvent(event);
            event.deinit();
        }
    }
    
    fn processEvent(self: *EventSystem, event: GameEvent) !void {
        if (self.event_handlers.get(event.event_type)) |handlers| {
            for (handlers.items) |handler| {
                handler(event);
            }
        }
        
        // Log event
        try self.logEvent(event);
    }
    
    fn logEvent(self: *EventSystem, event: GameEvent) !void {
        const timestamp = std.time.timestamp();
        const time_str = try std.fmt.allocPrint(self.allocator, "{d}", .{@as(f64, @floatFromInt(timestamp))});
        defer self.allocator.free(time_str);
        
        std.debug.print("[{s}] Event: {s} (Priority: {s})\n", .{
            time_str,
            @tagName(event.event_type),
            @tagName(event.priority),
        });
        
        if (event.player_name) |player_name| {
            std.debug.print("  Player: {s}\n", .{player_name});
        }
        
        if (event.world_name) |world_name| {
            std.debug.print("  World: {s}\n", .{world_name});
        }
    }
    
    pub fn createPlayerJoinEvent(self: *EventSystem, player_name: []const u8, world_name: []const u8) !void {
        var event = GameEvent.init(self.allocator, .player_join, .normal);
        event.setPlayer(player_name);
        event.setWorld(world_name);
        try event.addData("action", "join");
        try self.addEvent(event);
    }
    
    pub fn createPlayerLeaveEvent(self: *EventSystem, player_name: []const u8, world_name: []const u8) !void {
        var event = GameEvent.init(self.allocator, .player_leave, .normal);
        event.setPlayer(player_name);
        event.setWorld(world_name);
        try event.addData("action", "leave");
        try self.addEvent(event);
    }
    
    pub fn createPlayerMoveEvent(self: *EventSystem, player_name: []const u8, world_name: []const u8, x: u32, y: u32) !void {
        var event = GameEvent.init(self.allocator, .player_move, .low);
        event.setPlayer(player_name);
        event.setWorld(world_name);
        try event.addData("x", try std.fmt.allocPrint(self.allocator, "{}", .{x}));
        try event.addData("y", try std.fmt.allocPrint(self.allocator, "{}", .{y}));
        try self.addEvent(event);
    }
    
    pub fn createPlayerChatEvent(self: *EventSystem, player_name: []const u8, message: []const u8) !void {
        var event = GameEvent.init(self.allocator, .player_chat, .normal);
        event.setPlayer(player_name);
        try event.addData("message", message);
        try self.addEvent(event);
    }
    
    pub fn createWorldCreateEvent(self: *EventSystem, world_name: []const u8, owner: []const u8) !void {
        var event = GameEvent.init(self.allocator, .world_create, .high);
        event.setWorld(world_name);
        try event.addData("owner", owner);
        try self.addEvent(event);
    }
    
    pub fn createWorldDestroyEvent(self: *EventSystem, world_name: []const u8) !void {
        var event = GameEvent.init(self.allocator, .world_destroy, .high);
        event.setWorld(world_name);
        try self.addEvent(event);
    }
    
    pub fn createSpecialEvent(self: *EventSystem, event_name: []const u8, data: std.StringHashMap([]const u8)) !void {
        var event = GameEvent.init(self.allocator, .special_event, .high);
        try event.addData("event_name", event_name);
        
        // Copy data from the provided map
        var data_iter = data.iterator();
        while (data_iter.next()) |entry| {
            try event.addData(entry.key_ptr.*, entry.value_ptr.*);
        }
        
        try self.addEvent(event);
    }
    
    pub fn getEventCount(self: *EventSystem) u32 {
        return @intCast(self.events.items.len);
    }
    
    pub fn getScheduledTaskCount(self: *EventSystem) u32 {
        return @intCast(self.scheduled_tasks.items.len);
    }
    
    pub fn clearEvents(self: *EventSystem) void {
        for (self.events.items) |*event| {
            event.deinit();
        }
        self.events.clearRetainingCapacity();
    }
    
    pub fn disableTask(self: *EventSystem, task_name: []const u8) void {
        for (self.scheduled_tasks.items) |*task| {
            if (std.mem.eql(u8, task.name, task_name)) {
                task.enabled = false;
                break;
            }
        }
    }
    
    pub fn enableTask(self: *EventSystem, task_name: []const u8) void {
        for (self.scheduled_tasks.items) |*task| {
            if (std.mem.eql(u8, task.name, task_name)) {
                task.enabled = true;
                break;
            }
        }
    }
}; 