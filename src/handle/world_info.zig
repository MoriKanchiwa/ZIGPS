const std = @import("std");
const types = @import("../types.zig");

pub const WorldRate = struct {
    owner: []const u8 = "",
    rate: i32 = 0,
    time: i64 = 0,
};

pub const WorldDrop = struct {
    id: i32 = 0,
    count: i32 = 0,
    x: i32 = 0,
    y: i32 = 0,
};

pub const WorldBlock = struct {
    foreground: u16 = 0,
    background: u16 = 0,
    x: i32 = 0,
    y: i32 = 0,
    flags: u32 = 0,
    owner: []const u8 = "",
    last_modified: i64 = 0,
};

pub const WorldMachines = struct {
    // TODO: Add machine-specific fields
};

pub const WorldBulletin = struct {
    // TODO: Add bulletin-specific fields
};

pub const WorldCCTV = struct {
    // TODO: Add CCTV-specific fields
};

pub const WorldSBOX1 = struct {
    // TODO: Add SBOX1-specific fields
};

pub const WorldNPC = struct {
    id: i32 = 0,
    x: i32 = 0,
    y: i32 = 0,
    name: []const u8 = "",
    message: []const u8 = "",
    flags: u32 = 0,
};

pub const WorldGhost = struct {
    id: i32 = 0,
    x: f32 = 0.0,
    y: f32 = 0.0,
    speed: f32 = 0.0,
    direction: f32 = 0.0,
    last_move: i64 = 0,
};

pub const World = struct {
    // Basic world info
    name: []const u8 = "",
    owner: []const u8 = "",
    description: []const u8 = "",
    world_type: i32 = 0,
    width: i32 = 100,
    height: i32 = 60,
    
    // World settings
    is_public: bool = false,
    is_owner_plays: bool = false,
    is_restricted: bool = false,
    is_guest: bool = false,
    is_cloud_world: bool = false,
    is_cloud_guest: bool = false,
    
    // World state
    player_count: i32 = 0,
    max_players: i32 = 100,
    last_activity: i64 = 0,
    created_time: i64 = 0,
    
    // World data
    blocks: std.ArrayList(WorldBlock),
    drops: std.ArrayList(WorldDrop),
    npcs: std.ArrayList(WorldNPC),
    ghosts: std.ArrayList(WorldGhost),
    machines: std.ArrayList(WorldMachines),
    bulletins: std.ArrayList(WorldBulletin),
    cctvs: std.ArrayList(WorldCCTV),
    sboxes: std.ArrayList(WorldSBOX1),
    
    // World rates
    rates: std.ArrayList(WorldRate),
    
    // Special events
    special_event: bool = false,
    special_event_item: i32 = 0,
    last_special_event: i64 = 0,
    world_event_items: std.ArrayList(i32),
    
    // Weather and effects
    weather: i32 = 0,
    weather_time: i64 = 0,
    
    // World flags
    flags: u32 = 0,
    
    // Game settings
    game_mode: i32 = 0,
    game_time: i32 = 0,
    game_lives: i32 = 0,
    game_goals: i32 = 0,
    
    // Access control
    access_list: std.ArrayList([]const u8),
    banned_list: std.ArrayList([]const u8),
    
    // World metadata
    metadata: std.AutoHashMap([]const u8, []const u8),
    
    pub fn init(allocator: std.mem.Allocator, world_name: []const u8) World {
        return World{
            .name = allocator.dupe(u8, world_name) catch world_name,
            .blocks = std.ArrayList(WorldBlock).init(allocator),
            .drops = std.ArrayList(WorldDrop).init(allocator),
            .npcs = std.ArrayList(WorldNPC).init(allocator),
            .ghosts = std.ArrayList(WorldGhost).init(allocator),
            .machines = std.ArrayList(WorldMachines).init(allocator),
            .bulletins = std.ArrayList(WorldBulletin).init(allocator),
            .cctvs = std.ArrayList(WorldCCTV).init(allocator),
            .sboxes = std.ArrayList(WorldSBOX1).init(allocator),
            .rates = std.ArrayList(WorldRate).init(allocator),
            .world_event_items = std.ArrayList(i32).init(allocator),
            .access_list = std.ArrayList([]const u8).init(allocator),
            .banned_list = std.ArrayList([]const u8).init(allocator),
            .metadata = std.AutoHashMap([]const u8, []const u8).init(allocator),
        };
    }
    
    pub fn deinit(self: *World) void {
        self.blocks.deinit();
        self.drops.deinit();
        self.npcs.deinit();
        self.ghosts.deinit();
        self.machines.deinit();
        self.bulletins.deinit();
        self.cctvs.deinit();
        self.sboxes.deinit();
        self.rates.deinit();
        self.world_event_items.deinit();
        self.access_list.deinit();
        self.banned_list.deinit();
        self.metadata.deinit();
    }
    
    pub fn addBlock(self: *World, block: WorldBlock) !void {
        try self.blocks.append(block);
    }
    
    pub fn removeBlock(self: *World, x: i32, y: i32) void {
        for (self.blocks.items, 0..) |block, i| {
            if (block.x == x and block.y == y) {
                _ = self.blocks.orderedRemove(i);
                break;
            }
        }
    }
    
    pub fn getBlock(self: World, x: i32, y: i32) ?WorldBlock {
        for (self.blocks.items) |block| {
            if (block.x == x and block.y == y) {
                return block;
            }
        }
        return null;
    }
    
    pub fn addDrop(self: *World, drop: WorldDrop) !void {
        try self.drops.append(drop);
    }
    
    pub fn removeDrop(self: *World, x: i32, y: i32) void {
        for (self.drops.items, 0..) |drop, i| {
            if (drop.x == x and drop.y == y) {
                _ = self.drops.orderedRemove(i);
                break;
            }
        }
    }
    
    pub fn addNPC(self: *World, npc: WorldNPC) !void {
        try self.npcs.append(npc);
    }
    
    pub fn removeNPC(self: *World, id: i32) void {
        for (self.npcs.items, 0..) |npc, i| {
            if (npc.id == id) {
                _ = self.npcs.orderedRemove(i);
                break;
            }
        }
    }
    
    pub fn isPlayerInWorld(self: World, player_name: []const u8) bool {
        // TODO: Implement player tracking
        _ = self;
        _ = player_name;
        return false;
    }
    
    pub fn canPlayerAccess(self: World, player_name: []const u8) bool {
        // Check if player is banned
        for (self.banned_list.items) |banned| {
            if (std.mem.eql(u8, banned, player_name)) {
                return false;
            }
        }
        
        // Check if world is public or player has access
        if (self.is_public) return true;
        
        // Check access list
        for (self.access_list.items) |allowed| {
            if (std.mem.eql(u8, allowed, player_name)) {
                return true;
            }
        }
        
        // Owner always has access
        return std.mem.eql(u8, self.owner, player_name);
    }
    
    pub fn setWeather(self: *World, weather_type: i32) void {
        self.weather = weather_type;
        self.weather_time = std.time.milliTimestamp();
    }
    
    pub fn startSpecialEvent(self: *World, item_id: i32) void {
        self.special_event = true;
        self.special_event_item = item_id;
        self.last_special_event = std.time.milliTimestamp();
    }
    
    pub fn endSpecialEvent(self: *World) void {
        self.special_event = false;
        self.special_event_item = 0;
    }
};

// World management functions
pub fn findWorldByName(worlds: std.ArrayList(World), name: []const u8) ?*World {
    for (worlds.items) |*world| {
        if (std.mem.eql(u8, world.name, name)) {
            return world;
        }
    }
    return null;
}

pub fn createWorld(allocator: std.mem.Allocator, name: []const u8, owner: []const u8) !World {
    var world = World.init(allocator, name);
    world.owner = allocator.dupe(u8, owner) catch owner;
    world.created_time = std.time.milliTimestamp();
    world.last_activity = std.time.milliTimestamp();
    return world;
}

pub fn destroyWorld(world: *World) void {
    world.deinit();
}
