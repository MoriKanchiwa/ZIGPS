const std = @import("std");
const types = @import("../types.zig");

pub const ItemDB = struct {
    // Basic properties
    block_possible_put: bool = false,
    grindable_count: i32 = 0,
    grindable_prize: i32 = 0,
    event_name: []const u8 = "",
    event_total: i32 = 0,
    oprc: i32 = 0,
    flagmay: i32 = 256,
    zombieprice: i32 = 0,
    surgeryprice: i32 = 0,
    wolfprice: i32 = 0,
    pwl: i32 = 0,
    blocked_place: bool = false,
    unobtainable: bool = false,
    extra_gems: i32 = 0,
    newdropchance: i32 = 0,
    gtwl: i32 = 0,
    u_gtwl: i32 = 0,
    chance: i32 = 0,
    max_gems2: i32 = 0,
    max_gems3: i32 = 0,
    clash_token: i32 = 0,
    buy_price: i32 = 0,
    scan_price: i32 = 0,
    battle_cage: i32 = 0,
    
    // Pet properties
    pet_name: []const u8 = "",
    pet_prefix: []const u8 = "",
    pet_suffix: []const u8 = "",
    pet_ability: []const u8 = "",
    pet_description: []const u8 = "",
    pet_element: u8 = 0,
    pet_cooldown: u8 = 0,
    box_size: u8 = 0,
    
    // Arrays
    last20sales: std.ArrayList(i32),
    commontrain_reward: std.ArrayList(i32),
    raretrain_reward: std.ArrayList(i32),
    randomitem: std.ArrayList(i32),
    epic: std.ArrayList(i32),
    rare: std.ArrayList(i32),
    uncommon: std.ArrayList(i32),
    price: std.ArrayList(i32),
    noob_item: std.ArrayList(std.meta.Tuple(&.{ i32, i32 })),
    rare_item: std.ArrayList(std.meta.Tuple(&.{ i32, i32 })),
    consume_prize: std.ArrayList(i32),
    
    // Block properties
    block_flag: i32 = 0,
    musical_block: bool = false,
    texture_name: []const u8 = "",
    texture_y: i8 = 0,
    val2: i16 = 0,
    is_rayman: i16 = 0,
    max_amount: u8 = 0,
    editable_type: i8 = 0,
    hit_sound_type: i8 = 0,
    fossil_rock: i32 = 0,
    fossil_rock2: i32 = 0,
    compress_item_return: i32 = 0,
    compress_return_count: i32 = 0,
    fish_max_lb: i32 = 0,
    hand_scythe_text: []const u8 = "",
    consume_needed: i32 = 0,
    emoji: []const u8 = "",
    farmable: bool = false,
    playmod_id: u32 = 0,
    val1: i32 = 0,
    texture_hash: i32 = 0,
    item_category: i8 = 0,
    item_kind: i8 = 0,
    texture_x: i8 = 0,
    spread_type: i8 = 0,
    is_stripey_wallpaper: i8 = 0,
    texture: []const u8 = "",
    extra_options: []const u8 = "",
    texture2: []const u8 = "",
    extra_options2: []const u8 = "",
    punch_options: []const u8 = "",
    tree_base: i8 = 0,
    tree_leaves: i8 = 0,
    seed_base: i8 = 0,
    seed_overlay: i8 = 0,
    seed_color: i32 = 0,
    seed_overlay_color: i32 = 0,
    extra_file_hash: i32 = 0,
    drop_chance: i32 = 0,
    shop_x: i32 = 0,
    shop_y: i32 = 0,
    
    // Item properties
    id: i32 = 0,
    name: []const u8 = "",
    break_hits: i32 = 0,
    far_punch: i32 = 0,
    punch_place: i32 = 0,
    punch_hit: i32 = 0,
    punch_id: i32 = 0,
    gems: i32 = 0,
    xp: i32 = 0,
    bonus: i32 = 0,
    item_price: i32 = 0,
    change_drop_seeds: i32 = 0,
    property_farmable: bool = false,
    property_unobtainable: bool = false,
    property_gacha: bool = false,
    property_untradeable: bool = false,
    property_blacklist: bool = false,
    property_blocked: bool = false,
    
    pub fn init(allocator: std.mem.Allocator) ItemDB {
        return ItemDB{
            .last20sales = std.ArrayList(i32).init(allocator),
            .commontrain_reward = std.ArrayList(i32).init(allocator),
            .raretrain_reward = std.ArrayList(i32).init(allocator),
            .randomitem = std.ArrayList(i32).init(allocator),
            .epic = std.ArrayList(i32).init(allocator),
            .rare = std.ArrayList(i32).init(allocator),
            .uncommon = std.ArrayList(i32).init(allocator),
            .price = std.ArrayList(i32).init(allocator),
            .noob_item = std.ArrayList(std.meta.Tuple(&.{ i32, i32 })).init(allocator),
            .rare_item = std.ArrayList(std.meta.Tuple(&.{ i32, i32 })).init(allocator),
            .consume_prize = std.ArrayList(i32).init(allocator),
        };
    }
    
    pub fn deinit(self: *ItemDB) void {
        self.last20sales.deinit();
        self.commontrain_reward.deinit();
        self.raretrain_reward.deinit();
        self.randomitem.deinit();
        self.epic.deinit();
        self.rare.deinit();
        self.uncommon.deinit();
        self.price.deinit();
        self.noob_item.deinit();
        self.rare_item.deinit();
        self.consume_prize.deinit();
    }
    
    pub fn hasProperty(self: ItemDB, property: types.ItemProperty) bool {
        return (self.block_flag & @intFromEnum(property)) != 0;
    }
    
    pub fn addProperty(self: *ItemDB, property: types.ItemProperty) void {
        self.block_flag |= @intFromEnum(property);
    }
    
    pub fn removeProperty(self: *ItemDB, property: types.ItemProperty) void {
        self.block_flag &= ~@intFromEnum(property);
    }
};
