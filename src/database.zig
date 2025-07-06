const std = @import("std");
const config = @import("config.zig");
const Player = @import("handle/player_info.zig").Player;
const World = @import("handle/world_info.zig").World;
const ItemDB = @import("handle/item_defination.zig").ItemDB;

pub const Database = struct {
    allocator: std.mem.Allocator,
    data_path: []const u8,
    
    pub fn init(allocator: std.mem.Allocator) Database {
        return Database{
            .allocator = allocator,
            .data_path = config.global_config.database_path,
        };
    }
    
    pub fn savePlayer(self: *Database, player: *Player, filename: []const u8) !void {
        const file_path = try std.fmt.allocPrint(self.allocator, "{s}/players/{s}.json", .{ self.data_path, filename });
        defer self.allocator.free(file_path);
        
        // Create directory if it doesn't exist
        try std.fs.cwd().makePath(std.fs.path.dirname(file_path).?);
        
        const file = try std.fs.cwd().createFile(file_path, .{});
        defer file.close();
        
        // TODO: Implement JSON serialization for Player
        // For now, just write basic info
        const writer = file.writer();
        try writer.print("{{\n", .{});
        try writer.print("  \"name\": \"{s}\",\n", .{player.temporary_tank_id_name});
        try writer.print("  \"gems\": {},\n", .{player.gems});
        try writer.print("  \"level\": {},\n", .{player.level});
        try writer.print("  \"x\": {},\n", .{player.x});
        try writer.print("  \"y\": {},\n", .{player.y});
        try writer.print("  \"world\": \"{s}\",\n", .{player.last_visited_worlds.items[0]});
        try writer.print("  \"last_save\": {}\n", .{std.time.milliTimestamp()});
        try writer.print("}}\n", .{});
    }
    
    pub fn loadPlayer(self: *Database, filename: []const u8) !?*Player {
        const file_path = try std.fmt.allocPrint(self.allocator, "{s}/players/{s}.json", .{ self.data_path, filename });
        defer self.allocator.free(file_path);
        
        const file = std.fs.cwd().openFile(file_path, .{}) catch |err| {
            if (err == error.FileNotFound) {
                return null;
            }
            return err;
        };
        defer file.close();
        
        const content = try file.readToEndAlloc(self.allocator, 1024 * 1024);
        defer self.allocator.free(content);
        
        // TODO: Implement JSON deserialization for Player
        // For now, create a new player
        const player = try self.allocator.create(Player);
        player.* = Player.init(self.allocator);
        
        return player;
    }
    
    pub fn saveWorld(self: *Database, world: *World) !void {
        const file_path = try std.fmt.allocPrint(self.allocator, "{s}/worlds/{s}.json", .{ self.data_path, world.name });
        defer self.allocator.free(file_path);
        
        // Create directory if it doesn't exist
        try std.fs.cwd().makePath(std.fs.path.dirname(file_path).?);
        
        const file = try std.fs.cwd().createFile(file_path, .{});
        defer file.close();
        
        // TODO: Implement JSON serialization for World
        // For now, just write basic info
        const writer = file.writer();
        try writer.print("{{\n", .{});
        try writer.print("  \"name\": \"{s}\",\n", .{world.name});
        try writer.print("  \"owner\": \"{s}\",\n", .{world.owner});
        try writer.print("  \"width\": {},\n", .{world.width});
        try writer.print("  \"height\": {},\n", .{world.height});
        try writer.print("  \"blocks_count\": {},\n", .{world.blocks.items.len});
        try writer.print("  \"last_save\": {}\n", .{std.time.milliTimestamp()});
        try writer.print("}}\n", .{});
    }
    
    pub fn loadWorld(self: *Database, world_name: []const u8) !?*World {
        const file_path = try std.fmt.allocPrint(self.allocator, "{s}/worlds/{s}.json", .{ self.data_path, world_name });
        defer self.allocator.free(file_path);
        
        const file = std.fs.cwd().openFile(file_path, .{}) catch |err| {
            if (err == error.FileNotFound) {
                return null;
            }
            return err;
        };
        defer file.close();
        
        const content = try file.readToEndAlloc(self.allocator, 1024 * 1024);
        defer self.allocator.free(content);
        
        // TODO: Implement JSON deserialization for World
        // For now, create a new world
        const world = try self.allocator.create(World);
        world.* = World.init(self.allocator, world_name);
        
        return world;
    }
    
    pub fn saveItemsDatabase(self: *Database, items: std.AutoHashMap(i32, ItemDB)) !void {
        const file_path = try std.fmt.allocPrint(self.allocator, "{s}/items.json", .{self.data_path});
        defer self.allocator.free(file_path);
        
        // Create directory if it doesn't exist
        try std.fs.cwd().makePath(std.fs.path.dirname(file_path).?);
        
        const file = try std.fs.cwd().createFile(file_path, .{});
        defer file.close();
        
        // TODO: Implement JSON serialization for ItemDB
        // For now, just write basic info
        const writer = file.writer();
        try writer.print("{{\n", .{});
        try writer.print("  \"items_count\": {},\n", .{items.count()});
        try writer.print("  \"last_save\": {}\n", .{std.time.milliTimestamp()});
        try writer.print("}}\n", .{});
    }
    
    pub fn loadItemsDatabase(self: *Database) !std.AutoHashMap(i32, ItemDB) {
        const file_path = try std.fmt.allocPrint(self.allocator, "{s}/items.json", .{self.data_path});
        defer self.allocator.free(file_path);
        
        const file = std.fs.cwd().openFile(file_path, .{}) catch |err| {
            if (err == error.FileNotFound) {
                // Return empty items database
                return std.AutoHashMap(i32, ItemDB).init(self.allocator);
            }
            return err;
        };
        defer file.close();
        
        const content = try file.readToEndAlloc(self.allocator, 1024 * 1024);
        defer self.allocator.free(content);
        
        // TODO: Implement JSON deserialization for ItemDB
        // For now, return empty database
        return std.AutoHashMap(i32, ItemDB).init(self.allocator);
    }
    
    pub fn saveServerState(self: *Database, stats: anytype) !void {
        const file_path = try std.fmt.allocPrint(self.allocator, "{s}/server_state.json", .{self.data_path});
        defer self.allocator.free(file_path);
        
        // Create directory if it doesn't exist
        try std.fs.cwd().makePath(std.fs.path.dirname(file_path).?);
        
        const file = try std.fs.cwd().createFile(file_path, .{});
        defer file.close();
        
        const writer = file.writer();
        try writer.print("{{\n", .{});
        try writer.print("  \"uptime\": {},\n", .{stats.uptime});
        try writer.print("  \"total_connections\": {},\n", .{stats.total_connections});
        try writer.print("  \"current_connections\": {},\n", .{stats.current_connections});
        try writer.print("  \"max_connections\": {},\n", .{stats.max_connections});
        try writer.print("  \"total_packets_received\": {},\n", .{stats.total_packets_received});
        try writer.print("  \"total_packets_sent\": {},\n", .{stats.total_packets_sent});
        try writer.print("  \"bytes_received\": {},\n", .{stats.bytes_received});
        try writer.print("  \"bytes_sent\": {},\n", .{stats.bytes_sent});
        try writer.print("  \"last_save\": {}\n", .{std.time.milliTimestamp()});
        try writer.print("}}\n", .{});
    }
    
    pub fn backupDatabase(self: *Database) !void {
        const timestamp = std.time.milliTimestamp();
        const backup_path = try std.fmt.allocPrint(self.allocator, "{s}/backup_{}", .{ self.data_path, timestamp });
        defer self.allocator.free(backup_path);
        
        // Create backup directory
        try std.fs.cwd().makePath(backup_path);
        
        // Copy all data files to backup
        try self.copyDirectory(self.data_path, backup_path);
        
        std.debug.print("Database backed up to: {s}\n", .{backup_path});
    }
    
    fn copyDirectory(self: *Database, src: []const u8, dst: []const u8) !void {
        var dir = try std.fs.cwd().openDir(src, .{ .iterate = true });
        defer dir.close();
        
        var iter = dir.iterate();
        while (try iter.next()) |entry| {
            const src_path = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ src, entry.name });
            defer self.allocator.free(src_path);
            
            const dst_path = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ dst, entry.name });
            defer self.allocator.free(dst_path);
            
            switch (entry.kind) {
                .directory => {
                    try std.fs.cwd().makePath(dst_path);
                    try self.copyDirectory(src_path, dst_path);
                },
                .file => {
                    try std.fs.copyFileAbsolute(src_path, dst_path);
                },
                else => {},
            }
        }
    }
    
    pub fn cleanupOldBackups(self: *Database, max_backups: u32) !void {
        var dir = try std.fs.cwd().openDir(self.data_path, .{ .iterate = true });
        defer dir.close();
        
        var backups = std.ArrayList([]const u8).init(self.allocator);
        defer backups.deinit();
        
        var iter = dir.iterate();
        while (try iter.next()) |entry| {
            if (std.mem.startsWith(u8, entry.name, "backup_")) {
                const backup_path = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ self.data_path, entry.name });
                try backups.append(backup_path);
            }
        }
        
        // Sort backups by timestamp (oldest first)
        std.mem.sort([]const u8, backups.items, {}, struct {
            fn lessThan(_: void, a: []const u8, b: []const u8) bool {
                return std.mem.lessThan(u8, a, b);
            }
        }.lessThan);
        
        // Remove oldest backups if we have too many
        while (backups.items.len > max_backups) {
            const oldest_backup = backups.orderedRemove(0);
            try std.fs.deleteTreeAbsolute(oldest_backup);
            self.allocator.free(oldest_backup);
        }
    }
}; 