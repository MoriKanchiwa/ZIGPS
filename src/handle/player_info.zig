const std = @import("std");
const types = @import("../types.zig");

pub const AdventureItem = struct {
    id: i32 = 0,
    pos: i32 = -1,
    uid: i32 = -1,
};

pub const PlayMods = struct {
    id: u16 = 0,
    user: []const u8 = "",
    time: i64 = 0,
};

pub const Friends = struct {
    name: []const u8 = "",
    last_seen: i64 = 0,
    mute: bool = false,
    block_trade: bool = false,
};

pub const MarketPlace = struct {
    notifications: i32 = 0,
    fg: []const u8 = "",
    store_name: []const u8 = "",
    whose: []const u8 = "",
};

pub const RedeemCode = struct {
    code: []const u8 = "",
    expired: i64 = 0,
    created: i64 = 0,
};

pub const PlayerTitle = struct {
    mentor: bool = false,
    grow4good: bool = false,
    doctor: bool = false,
    of_legend: bool = false,
    tiktok_badge: bool = false,
    content_c_badge: bool = false,
    thanks_giving: bool = false,
    old_timer: bool = false,
    winter_santa: bool = false,
    party_animal: bool = false,
    growpass_bronze: bool = false,
    growpass_silver: bool = false,
    growpass_gold: bool = false,
    award_winning: bool = false,
};

pub const PlayerRole = struct {
    role_level: i32 = 0,
    super_boost_time: i64 = 0,
    boost_time: i64 = 0,
    owner_server: bool = false,
    unlimited: bool = false,
    god: bool = false,
    developer: bool = false,
    administrator: bool = false,
    moderator: bool = false,
    vip: bool = false,
    cheats: bool = false,
    boost: bool = false,
    super_boost: bool = false,
};

pub const PlayerRolesTitle = struct {
    farmer: bool = false,
    builder: bool = false,
    surgeon: bool = false,
    fisher: bool = false,
    chef: bool = false,
    startopian: bool = false,
};

pub const AntiFarmSpam = struct {
    last_break_tile: u64 = 0,
    total_warning: i32 = 0,
    last_timedout: u64 = 0,
};

pub const Proxys = struct {
    reme: bool = false,
    roulette: bool = false,
    fastspin: bool = false,
};

pub const EarnFreeGems = struct {
    time: i64 = 0,
    quest_1: i32 = 0,
    quest_2: i32 = 0,
    quest_3: i32 = 0,
    claim: std.ArrayList(i32),
    
    pub fn init(allocator: std.mem.Allocator) EarnFreeGems {
        return EarnFreeGems{
            .claim = std.ArrayList(i32).init(allocator),
        };
    }
    
    pub fn deinit(self: *EarnFreeGems) void {
        self.claim.deinit();
    }
};

pub const AntiWorlds = struct {
    load_assets: bool = false,
    // Note: In Zig we don't need explicit mutex, we'll handle thread safety differently
};

pub const BrutalJump = struct {
    xy: std.ArrayList(std.meta.Tuple(&.{ i32, i32 })),
    time: i64 = 0,
    actived: bool = false,
    
    pub fn init(allocator: std.mem.Allocator) BrutalJump {
        return BrutalJump{
            .xy = std.ArrayList(std.meta.Tuple(&.{ i32, i32 })).init(allocator),
        };
    }
    
    pub fn deinit(self: *BrutalJump) void {
        self.xy.deinit();
    }
};

pub const MirrorMaze = struct {
    carnival_mirror_maze: std.ArrayList(std.meta.Tuple(&.{ i32, i32 })),
    carnival_mirror_reset: bool = true,
    
    pub fn init(allocator: std.mem.Allocator) MirrorMaze {
        return MirrorMaze{
            .carnival_mirror_maze = std.ArrayList(std.meta.Tuple(&.{ i32, i32 })).init(allocator),
        };
    }
    
    pub fn deinit(self: *MirrorMaze) void {
        self.carnival_mirror_maze.deinit();
    }
};

pub const CardGame = struct {
    // Card variables
    cards_1: i32 = 0,
    cards_2: i32 = 0,
    cards_3: i32 = 0,
    cards_4: i32 = 0,
    cards_5: i32 = 0,
    cards_6: i32 = 0,
    cards_7: i32 = 0,
    cards_8: i32 = 0,
    cards_9: i32 = 0,
    cards_10: i32 = 0,
    cards_11: i32 = 0,
    cards_12: i32 = 0,
    cards_13: i32 = 0,
    cards_14: i32 = 0,
    cards_15: i32 = 0,
    cards_16: i32 = 0,
    vars: [16]i32 = [_]i32{0} ** 16,
    
    // Punch Card XY
    x_card_1: i32 = 0,
    y_card_1: i32 = 0,
    x_card_2: i32 = 0,
    y_card_2: i32 = 0,
    card_1: i32 = 0,
    card_2: i32 = 0,
    card_opened: i32 = 0,
    total_card_success: i32 = 0,
    
    // ItemID Card
    cards: std.ArrayList(i32),
    
    pub fn init(allocator: std.mem.Allocator) CardGame {
        var cards = std.ArrayList(i32).init(allocator);
        cards.appendSlice(&.{ 742, 744, 746, 748, 1918, 1920, 1922, 1924 }) catch unreachable;
        return CardGame{ .cards = cards };
    }
    
    pub fn deinit(self: *CardGame) void {
        self.cards.deinit();
    }
};

pub const Player = struct {
    // WinterFest Bingo
    has_win_bingo: bool = false,
    winter_bingo_prize: std.AutoHashMap([]const u8, std.meta.Tuple(&.{ i32, i32 })),
    winter_bingo_task: std.AutoHashMap([]const u8, i32),
    has_bingo_task: std.ArrayList(i32),
    has_claim_bingo: std.ArrayList([]const u8),
    has_bingo_prize: std.ArrayList(std.meta.Tuple(&.{ []const u8, i32, i32 })),
    
    // Account Notes
    account_notes: std.ArrayList([]const u8),
    
    // Gems Storage
    gems_storage: i64 = 0,
    
    // Discord things
    discord_verified: bool = false,
    accaap: bool = false,
    discord_id: []const u8 = "",
    discord_dis: []const u8 = "",
    discord_tag: []const u8 = "",
    discord_pending: bool = false,
    
    // Warning System
    warning: i32 = 0,
    warning_spam: i32 = 0,
    warning_message: std.ArrayList([]const u8),
    wm: std.ArrayList([]const u8),
    
    // Mod Setting
    npc_summon: bool = false,
    effworld_: bool = false,
    x_npc: i32 = 0,
    y_npc: i32 = 0,
    npc_net_id: i32 = 0,
    effworld: i32 = 0,
    cheat_bot_spam: i32 = 0,
    cheat_pull: i32 = 0,
    cheat_qq: i32 = 0,
    cheat_reme: i32 = 0,
    cheat_kick: i32 = 0,
    cheat_ban: i32 = 0,
    cheat_detect: i32 = 0,
    cheat_unacc: i32 = 0,
    cheat_hideother: i32 = 0,
    cheat_hidechat: i32 = 0,
    cheat_spam: i32 = 0,
    cheat_spam_delay: i32 = 1,
    cheat_last_spam: i32 = 0,
    cheat_spam_text: []const u8 = "",
    npc_text: []const u8 = "",
    npc_name: []const u8 = "",
    npc_world: []const u8 = "",
    
    // Title and Role
    title: PlayerTitle = .{},
    role: PlayerRole = .{},
    roles_title: PlayerRolesTitle = .{},
    
    // Kit
    started_kit: bool = false,
    kit_pass_prize: std.ArrayList([]const u8),
    lvl_kit: i32 = 0,
    lvl_kit_s2: i32 = 0,
    xp_kit: i32 = 0,
    xp_kit_s2: i32 = 0,
    
    // Marketplace
    buyp: i32 = 0,
    store_price: i32 = 0,
    store_id: i32 = 0,
    store_pos: []const u8 = "",
    store_desc: []const u8 = "",
    
    // Spotify
    spotify: i32 = 0,
    
    // Battle pet
    battle_pet: std.meta.Tuple(&.{ std.ArrayList(u16), std.ArrayList(u16) }),
    
    // Adventure
    adventure_item: std.ArrayList(AdventureItem),
    
    // Redeem Code
    last_redeem: i64 = 0,
    has_claim: std.ArrayList([]const u8),
    r_items: std.ArrayList(std.meta.Tuple(&.{ i32, i32 })),
    redeem_code: std.ArrayList(RedeemCode),
    n_items: std.ArrayList(std.meta.Tuple(&.{ i32, i32 })),
    
    // Tutorial
    new_player: bool = false,
    
    // Pet AI
    pet_name: []const u8 = "",
    pet_type: i32 = -1,
    pet_move: f32 = 0.0,
    pet_xp: i64 = 0,
    pets_death_times: i32 = 0,
    pets_hunger: i32 = 150,
    pets_health: i32 = 100,
    pets_builder_lvl: i32 = 0,
    pets_farmer_lvl: i32 = 0,
    pets_gems_lvl: i32 = 0,
    pets_xp_lvl: i32 = 0,
    pet_net_id: i32 = 0,
    pet_id: i32 = 0,
    pet_level: i32 = 0,
    ability_xgems: i32 = 0,
    ability_xxp: i32 = 0,
    pets_not: bool = false,
    pets_not2: bool = false,
    pets_not3: bool = false,
    pets_dead: bool = false,
    show_pets: bool = false,
    pet_clothes_updated: bool = false,
    hidden_pets_name: bool = false,
    master_pet: bool = false,
    active_bluename: bool = false,
    active_1hit: bool = false,
    liyue_htou_fly: bool = false,
    abyss_mage_fly: bool = false,
    uuuzz_fly: bool = false,
    random_sentences: bool = false,
    
    // Basic player info
    id: i32 = 0,
    net_id: i32 = 0,
    last_net_id: i32 = 0,
    state: i32 = 0,
    trading_with: i32 = -1,
    x: i32 = -1,
    y: i32 = -1,
    gems: i32 = 0,
    voucher: i32 = 0,
    used_megaphone: i32 = 0,
    temporary_tank_id_name: []const u8 = "",
    access_offers: std.AutoHashMap(i32, i32),
    hit1: bool = false,
    skin: i32 = 0x8295C3FF,
    exit_warn: i32 = 0,
    punched: u16 = 0,
    most_wt: bool = false,
    enter_game: i32 = 0,
    lock: i32 = 0,
    flag_may: i32 = 256,
    lock_item: i32 = 0,
    n: u8 = 0, // newbie passed save
    supp: u8 = 0,
    hs: u8 = 0,
    m_h: u8 = 0,
    d_s: u8 = 0,
    
    // Player stats
    flags: i32 = 19451,
    time_dilation: i32 = 30,
    _flags: i32 = 104912,
    _time_dilation: i32 = 30,
    strong_punch: f32 = 200,
    high_jump: f32 = 1000,
    player_speed: f32 = 250,
    water_speed: f32 = 125,
    build_range: i32 = 128,
    punch_range: i32 = 128,
    state_player: i32 = 0,
    punch_effect: i32 = 0,
    type_player: i32 = 0,
    guild_role: i32 = -1,
    flag_may_form: i32 = 0,
    punch_modifier: i32 = 0,
    punch_decrease: bool = false,
    
    // Complex structures
    brutal_jump: BrutalJump,
    mirror_maze: MirrorMaze,
    card_game: CardGame,
    
    // More fields will be added in the next step...
    
    pub fn init(allocator: std.mem.Allocator) Player {
        return Player{
            .winter_bingo_prize = std.AutoHashMap([]const u8, std.meta.Tuple(&.{ i32, i32 })).init(allocator),
            .winter_bingo_task = std.AutoHashMap([]const u8, i32).init(allocator),
            .has_bingo_task = std.ArrayList(i32).init(allocator),
            .has_claim_bingo = std.ArrayList([]const u8).init(allocator),
            .has_bingo_prize = std.ArrayList(std.meta.Tuple(&.{ []const u8, i32, i32 })).init(allocator),
            .account_notes = std.ArrayList([]const u8).init(allocator),
            .warning_message = std.ArrayList([]const u8).init(allocator),
            .wm = std.ArrayList([]const u8).init(allocator),
            .kit_pass_prize = std.ArrayList([]const u8).init(allocator),
            .battle_pet = .{ 
                std.ArrayList(u16).init(allocator), 
                std.ArrayList(u16).init(allocator) 
            },
            .adventure_item = std.ArrayList(AdventureItem).init(allocator),
            .has_claim = std.ArrayList([]const u8).init(allocator),
            .r_items = std.ArrayList(std.meta.Tuple(&.{ i32, i32 })).init(allocator),
            .redeem_code = std.ArrayList(RedeemCode).init(allocator),
            .n_items = std.ArrayList(std.meta.Tuple(&.{ i32, i32 })).init(allocator),
            .access_offers = std.AutoHashMap(i32, i32).init(allocator),
            .brutal_jump = BrutalJump.init(allocator),
            .mirror_maze = MirrorMaze.init(allocator),
            .card_game = CardGame.init(allocator),
        };
    }
    
    pub fn deinit(self: *Player) void {
        self.winter_bingo_prize.deinit();
        self.winter_bingo_task.deinit();
        self.has_bingo_task.deinit();
        self.has_claim_bingo.deinit();
        self.has_bingo_prize.deinit();
        self.account_notes.deinit();
        self.warning_message.deinit();
        self.wm.deinit();
        self.kit_pass_prize.deinit();
        self.battle_pet[0].deinit();
        self.battle_pet[1].deinit();
        self.adventure_item.deinit();
        self.has_claim.deinit();
        self.r_items.deinit();
        self.redeem_code.deinit();
        self.n_items.deinit();
        self.access_offers.deinit();
        self.brutal_jump.deinit();
        self.mirror_maze.deinit();
        self.card_game.deinit();
    }
};
