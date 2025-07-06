const std = @import("std");

// Basic types
pub const BYTE = u8;
pub const PlayerMoving = struct {
    net_id: i32 = 0,
    effect_flags_check: i32 = 0,
    packet_type: i32 = 0,
    character_state: i32 = 0,
    planting_tree: i32 = 0,
    punch_x: i32 = 0,
    punch_y: i32 = 0,
    second_net_id: i32 = 0,
    x: f32 = 0.0,
    y: f32 = 0.0,
    x_speed: f32 = 0.0,
    y_speed: f32 = 0.0,
    packet_3: i32 = 0,
    packet_int_40: i32 = 0,
};

// Item properties
pub const ItemProperty = enum(u32) {
    zero = 0,
    no_seed = 1,
    dropless = 2,
    beta = 4,
    mod = 8,
    chemical = 12,
    untradeable = 16,
    wrenchable = 32,
    multi_facing = 64,
    permanent = 128,
    auto_pickup = 256,
    world_lock = 512,
    no_self = 1024,
    random_grow = 2048,
    public = 4096,
    foreground = 8192,
};

// Clothing types
pub const ClothType = enum {
    hair,
    shirt,
    pants,
    feet,
    face,
    hand,
    back,
    mask,
    necklace,
    ances,
    none,
};

// Block types
pub const BlockType = enum {
    foreground,
    background,
    silkworm,
    consumable,
    seed,
    display_shelf,
    pain_block,
    bedrock,
    vip_entrance,
    heart_monitor,
    painting_easel,
    main_door,
    sign,
    door,
    clothing,
    fist,
    wrench,
    checkpoint,
    lock,
    lock_bot,
    gateway,
    treasure,
    weather,
    trampoline,
    mannequin,
    toggle_foreground,
    chemical_combiner,
    switch_block,
    sfx_foreground,
    random_block,
    spirit_storage,
    portal,
    platform,
    fish_mount,
    mailbox,
    giving_tree,
    magic_egg,
    crystal,
    gems,
    deadly,
    chest,
    faction,
    bulletin_board,
    bouncy,
    anim_foreground,
    component,
    sucker,
    fish,
    fish_tank,
    battle_cage,
    steam,
    ground_block,
    portrait,
    display,
    storage,
    vending,
    donation,
    phone,
    sewing_machine,
    crime_villain,
    provider,
    adventure,
    cctv,
    storage_box,
    timer,
    item_sucker,
    trickster,
    kranken,
    fossil,
    geiger_charger,
    country_flag,
    auto_block,
    game_block,
    game_generator,
    oven,
    pet_trainer,
    achievement_block,
    unknown,
};

// NPC types
pub const GTPS_NPC = enum(i32) {
    exchange = -777,
    marketplace = -888,
};

// Game modifiers
pub const Modifier = enum {
    score,
    live,
    hit,
};

// Game actions
pub const GameAction = enum(u8) {
    start = 0,
    end = 1,
    update_player_score = 2,
    update_team_score = 3,
    capture = 4,
    unk_val = 5,
    leave = 6,
    join = 7,
};

// Game options
pub const GameOptions = enum(u32) {
    respawn_on_score = 1,
    reset_on_score = 2,
    owner_plays = 4,
    late_join = 8,
    smash_enemy_block = 16,
    smash_own_block = 32,
    disable_music = 64,
    dont_use_chat_log = 128,
    restart_automatically = 256,
};

// Game teams
pub const GameTeam = enum(u8) {
    red_rabbits = 0,
    blue_bombers = 1,
    yellow_yaks = 2,
    purple_penguins = 3,
    free_for_all = 4,
};

// Utility functions
pub fn memoryCopy(dest: [*]u8, src: [*]const u8, size: usize) void {
    @memcpy(dest[0..size], src[0..size]);
}

pub fn memorySet(ptr: [*]u8, value: u8, size: usize) void {
    @memset(ptr[0..size], value);
}

pub fn memoryMove(dest: [*]u8, src: [*]const u8, size: usize) void {
    @memcpy(dest[0..size], src[0..size]);
} 