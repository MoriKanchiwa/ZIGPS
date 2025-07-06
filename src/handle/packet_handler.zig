// TODO: Port packet handler logic from C++ PacketHandler.h here

const std = @import("std");
const c = @cImport({
    @cInclude("enet/enet.h");
});
const types = @import("../types.zig");

pub const PacketType = enum(u8) {
    // Basic packets
    hello = 0,
    join_request = 1,
    join_response = 2,
    disconnect = 3,
    ping = 4,
    pong = 5,
    
    // Player packets
    player_move = 6,
    player_place = 7,
    player_punch = 8,
    player_pickup = 9,
    player_drop = 10,
    player_wear = 11,
    player_say = 12,
    player_emote = 13,
    
    // World packets
    world_join = 14,
    world_leave = 15,
    world_data = 16,
    world_update = 17,
    world_weather = 18,
    
    // Game packets
    game_start = 19,
    game_end = 20,
    game_score = 21,
    game_flag = 22,
    
    // Chat packets
    chat_message = 23,
    chat_broadcast = 24,
    chat_whisper = 25,
    
    // Trade packets
    trade_request = 26,
    trade_accept = 27,
    trade_decline = 28,
    trade_item = 29,
    trade_confirm = 30,
    trade_cancel = 31,
    
    // Admin packets
    admin_kick = 32,
    admin_ban = 33,
    admin_world_edit = 34,
    admin_broadcast = 35,
    
    // Custom packets
    custom_packet = 36,
};

pub const GameUpdatePacket = struct {
    packet_type: PacketType = .hello,
    net_id: i32 = 0,
    item_id: i32 = 0,
    count: i32 = 0,
    flags: u32 = 0,
    float_var: f32 = 0.0,
    int_data: i32 = 0,
    vec_x: f32 = 0.0,
    vec_y: f32 = 0.0,
    vec2_x: f32 = 0.0,
    vec2_y: f32 = 0.0,
    vec3_x: f32 = 0.0,
    vec3_y: f32 = 0.0,
    int_x: i32 = 0,
    int_y: i32 = 0,
    int_x2: i32 = 0,
    int_y2: i32 = 0,
    
    pub fn init(packet_type: PacketType) GameUpdatePacket {
        return GameUpdatePacket{
            .packet_type = packet_type,
        };
    }
    
    pub fn serialize(self: GameUpdatePacket, allocator: std.mem.Allocator) ![]u8 {
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();
        
        // Write packet type
        try buffer.append(@intFromEnum(self.packet_type));
        
        // Write net_id
        try buffer.appendSlice(&std.mem.toBytes(self.net_id));
        
        // Write item_id
        try buffer.appendSlice(&std.mem.toBytes(self.item_id));
        
        // Write count
        try buffer.appendSlice(&std.mem.toBytes(self.count));
        
        // Write flags
        try buffer.appendSlice(&std.mem.toBytes(self.flags));
        
        // Write float_var
        try buffer.appendSlice(&std.mem.toBytes(self.float_var));
        
        // Write int_data
        try buffer.appendSlice(&std.mem.toBytes(self.int_data));
        
        // Write vec_x
        try buffer.appendSlice(&std.mem.toBytes(self.vec_x));
        
        // Write vec_y
        try buffer.appendSlice(&std.mem.toBytes(self.vec_y));
        
        // Write vec2_x
        try buffer.appendSlice(&std.mem.toBytes(self.vec2_x));
        
        // Write vec2_y
        try buffer.appendSlice(&std.mem.toBytes(self.vec2_y));
        
        // Write vec3_x
        try buffer.appendSlice(&std.mem.toBytes(self.vec3_x));
        
        // Write vec3_y
        try buffer.appendSlice(&std.mem.toBytes(self.vec3_y));
        
        // Write int_x
        try buffer.appendSlice(&std.mem.toBytes(self.int_x));
        
        // Write int_y
        try buffer.appendSlice(&std.mem.toBytes(self.int_y));
        
        // Write int_x2
        try buffer.appendSlice(&std.mem.toBytes(self.int_x2));
        
        // Write int_y2
        try buffer.appendSlice(&std.mem.toBytes(self.int_y2));
        
        return buffer.toOwnedSlice();
    }
    
    pub fn deserialize(data: []const u8) !GameUpdatePacket {
        if (data.len < 56) return error.InvalidPacketSize;
        
        var packet = GameUpdatePacket{};
        var offset: usize = 0;
        
        // Read packet type
        packet.packet_type = @enumFromInt(data[offset]);
        offset += 1;
        
        // Read net_id
        packet.net_id = std.mem.readIntLittle(i32, data[offset..offset+4]);
        offset += 4;
        
        // Read item_id
        packet.item_id = std.mem.readIntLittle(i32, data[offset..offset+4]);
        offset += 4;
        
        // Read count
        packet.count = std.mem.readIntLittle(i32, data[offset..offset+4]);
        offset += 4;
        
        // Read flags
        packet.flags = std.mem.readIntLittle(u32, data[offset..offset+4]);
        offset += 4;
        
        // Read float_var
        packet.float_var = std.mem.readIntLittle(f32, data[offset..offset+4]);
        offset += 4;
        
        // Read int_data
        packet.int_data = std.mem.readIntLittle(i32, data[offset..offset+4]);
        offset += 4;
        
        // Read vec_x
        packet.vec_x = std.mem.readIntLittle(f32, data[offset..offset+4]);
        offset += 4;
        
        // Read vec_y
        packet.vec_y = std.mem.readIntLittle(f32, data[offset..offset+4]);
        offset += 4;
        
        // Read vec2_x
        packet.vec2_x = std.mem.readIntLittle(f32, data[offset..offset+4]);
        offset += 4;
        
        // Read vec2_y
        packet.vec2_y = std.mem.readIntLittle(f32, data[offset..offset+4]);
        offset += 4;
        
        // Read vec3_x
        packet.vec3_x = std.mem.readIntLittle(f32, data[offset..offset+4]);
        offset += 4;
        
        // Read vec3_y
        packet.vec3_y = std.mem.readIntLittle(f32, data[offset..offset+4]);
        offset += 4;
        
        // Read int_x
        packet.int_x = std.mem.readIntLittle(i32, data[offset..offset+4]);
        offset += 4;
        
        // Read int_y
        packet.int_y = std.mem.readIntLittle(i32, data[offset..offset+4]);
        offset += 4;
        
        // Read int_x2
        packet.int_x2 = std.mem.readIntLittle(i32, data[offset..offset+4]);
        offset += 4;
        
        // Read int_y2
        packet.int_y2 = std.mem.readIntLittle(i32, data[offset..offset+4]);
        
        return packet;
    }
};

pub const PacketHandler = struct {
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator) PacketHandler {
        return PacketHandler{
            .allocator = allocator,
        };
    }
    
    pub fn handlePacket(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        if (data.len == 0) return;
        
        const packet_type = @as(PacketType, @enumFromInt(data[0]));
        
        switch (packet_type) {
            .hello => try self.handleHello(peer, data),
            .join_request => try self.handleJoinRequest(peer, data),
            .player_move => try self.handlePlayerMove(peer, data),
            .player_place => try self.handlePlayerPlace(peer, data),
            .player_punch => try self.handlePlayerPunch(peer, data),
            .player_say => try self.handlePlayerSay(peer, data),
            .world_join => try self.handleWorldJoin(peer, data),
            .world_leave => try self.handleWorldLeave(peer, data),
            .chat_message => try self.handleChatMessage(peer, data),
            .trade_request => try self.handleTradeRequest(peer, data),
            .admin_broadcast => try self.handleAdminBroadcast(peer, data),
            else => {
                std.debug.print("Unknown packet type: {}\n", .{packet_type});
            },
        }
    }
    
    fn handleHello(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = data;
        std.debug.print("Received HELLO packet from peer\n", .{});
        
        // Send HELLO response
        var response = GameUpdatePacket.init(.hello);
        try self.sendPacket(peer, &response);
    }
    
    fn handleJoinRequest(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received JOIN_REQUEST packet from peer\n", .{});
        
        // TODO: Implement join request handling
    }
    
    fn handlePlayerMove(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received PLAYER_MOVE packet from peer\n", .{});
        
        // TODO: Implement player movement handling
    }
    
    fn handlePlayerPlace(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received PLAYER_PLACE packet from peer\n", .{});
        
        // TODO: Implement block placement handling
    }
    
    fn handlePlayerPunch(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received PLAYER_PUNCH packet from peer\n", .{});
        
        // TODO: Implement block punching handling
    }
    
    fn handlePlayerSay(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received PLAYER_SAY packet from peer\n", .{});
        
        // TODO: Implement chat handling
    }
    
    fn handleWorldJoin(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received WORLD_JOIN packet from peer\n", .{});
        
        // TODO: Implement world joining handling
    }
    
    fn handleWorldLeave(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received WORLD_LEAVE packet from peer\n", .{});
        
        // TODO: Implement world leaving handling
    }
    
    fn handleChatMessage(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received CHAT_MESSAGE packet from peer\n", .{});
        
        // TODO: Implement chat message handling
    }
    
    fn handleTradeRequest(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received TRADE_REQUEST packet from peer\n", .{});
        
        // TODO: Implement trade request handling
    }
    
    fn handleAdminBroadcast(self: *PacketHandler, peer: ?*c.ENetPeer, data: []const u8) !void {
        _ = self;
        _ = peer;
        _ = data;
        std.debug.print("Received ADMIN_BROADCAST packet from peer\n", .{});
        
        // TODO: Implement admin broadcast handling
    }
    
    pub fn sendPacket(self: *PacketHandler, peer: ?*c.ENetPeer, packet: *GameUpdatePacket) !void {
        const data = try packet.serialize(self.allocator);
        defer self.allocator.free(data);
        
        const enet_packet = c.enet_packet_create(
            data.ptr,
            @intCast(data.len),
            c.ENET_PACKET_FLAG_RELIABLE,
        );
        
        if (enet_packet == null) {
            return error.FailedToCreatePacket;
        }
        
        const result = c.enet_peer_send(peer, 0, enet_packet);
        if (result != 0) {
            return error.FailedToSendPacket;
        }
    }
    
    pub fn broadcastPacket(self: *PacketHandler, server: ?*c.ENetHost, packet: *GameUpdatePacket) !void {
        const data = try packet.serialize(self.allocator);
        defer self.allocator.free(data);
        
        const enet_packet = c.enet_packet_create(
            data.ptr,
            @intCast(data.len),
            c.ENET_PACKET_FLAG_RELIABLE,
        );
        
        if (enet_packet == null) {
            return error.FailedToCreatePacket;
        }
        
        c.enet_host_broadcast(server, 0, enet_packet);
    }
};

// Utility functions for packet handling
pub fn sendRawPacket(peer: ?*c.ENetPeer, data: []const u8, flags: u32) !void {
    const enet_packet = c.enet_packet_create(
        data.ptr,
        @intCast(data.len),
        flags,
    );
    
    if (enet_packet == null) {
        return error.FailedToCreatePacket;
    }
    
    const result = c.enet_peer_send(peer, 0, enet_packet);
    if (result != 0) {
        return error.FailedToSendPacket;
    }
}

pub fn sendRawPacketToAll(server: ?*c.ENetHost, data: []const u8, flags: u32) void {
    const enet_packet = c.enet_packet_create(
        data.ptr,
        @intCast(data.len),
        flags,
    );
    
    if (enet_packet != null) {
        c.enet_host_broadcast(server, 0, enet_packet);
    }
}
