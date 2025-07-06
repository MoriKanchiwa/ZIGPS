const std = @import("std");

pub const LogLevel = enum {
    debug,
    info,
    warn,
    error,
};

pub const Config = struct {
    // Server Settings
    server_name: []const u8 = "GrowSC Server",
    server_version: []const u8 = "1.0.0",
    server_port: u16 = 17091,
    max_players: u32 = 1024,
    max_channels: u32 = 2,
    
    // Database Settings
    database_path: []const u8 = "data/",
    save_interval: u32 = 300, // seconds
    
    // World Settings
    default_world: []const u8 = "EXIT",
    max_worlds: u32 = 1000,
    
    // Game Settings
    max_gems: u32 = 2100000000,
    max_level: u32 = 125,
    
    // Security Settings
    enable_anticheat: bool = true,
    max_warnings: u32 = 3,
    
    // Event Settings
    enable_events: bool = true,
    event_interval: u32 = 300, // seconds
    
    // Discord Integration
    discord_enabled: bool = false,
    discord_webhook: []const u8 = "",
    
    // API Settings
    api_enabled: bool = false,
    api_port: u16 = 8080,
    
    // Logging
    log_level: LogLevel = .info,
    log_file: []const u8 = "logs/server.log",
    
    pub fn loadFromFile(path: []const u8) !Config {
        const allocator = std.heap.page_allocator;
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();
        
        const content = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(content);
        
        // Simple JSON-like parsing for now
        // TODO: Implement proper JSON parsing
        return Config{};
    }
    
    pub fn saveToFile(self: Config, path: []const u8) !void {
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();
        
        // TODO: Implement proper JSON serialization
        _ = self;
    }
};

pub var global_config: Config = .{}; 