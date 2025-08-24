#pragma author Rirurin
#pragma description Template for decrypted saves from Persona 5 Royal (2022 multiplatform release)
// Header structures from https://github.com/zarroboogs/fiber-saveutil


//#define LOAD_ANALYSIS_DATA // Bitfields that aren't aligned to a byte boundary are quite slow since they can't be optimized

#include <std/array.pat>
#include <std/mem.pat>
#include <std/io.pat>
#include <atlus/p5r/common/numerics.expat>

struct EncryptInfo {
    char signature[4];
    u32 crc;
    u32 timestamp;
    u32 flags;
    u128 iv[[hidden]]; // always zero
}[[format("fmt_encryptinfo")]];
fn fmt_encryptinfo(ref EncryptInfo self) { return std::format("CRC 0x{:X}, TIME 0x{:X}", self.crc, self.timestamp); };

struct DataInfo {
    u16 head_size;
    u16 head_size_cmp[[hidden]]; // always zero
    u32 data_size;
    u32 data_size_cmp[[hidden]]; // always zero
    u32 flags;
    u32 crc;
    padding[12];
}[[format("fmt_datainfo")]];
fn fmt_datainfo(ref DataInfo self) { return std::format("CRC 0x{:X}, FLAGS 0x{:X}", self.crc, self.flags); };

enum TimeOfDay : u8 {
    EarlyMorning = 0,
    Morning = 1,
    Lunchtime = 2,
    Daytime = 3,
    AfterSchool = 4,
    Evening = 5,
    LateNight = 6
};

enum Difficulty : u8 {
    Safe = 0,
    Easy = 1,
    Normal = 2,
    Hard = 3,
    Merciless = 4
};

struct DataHeader {
    u32 playtime_frames[[format("fmt_playtime")]];
    s16 day[[format("fmt_day")]]; // days since April 1
    TimeOfDay time;
    u8 playthrough; // Normal/NG+ ? (can't check i don't have a ng+ save)
    Difficulty difficulty;
    u8 level;
    u8 clear;
    padding[1];
    u8 fld_major;
    u8 fld_minor;
    u8 lang0;
    u8 lang1;
    char last_name[64][[sealed]]; // utf8
    char first_name[64][[sealed]]; // utf8
    char description[256]; // ascii
}[[format("fmt_dataheader")]];

fn fmt_playtime(u32 self) {
    u32 seconds = self / 30;
    u32 sec_disp = seconds % 60;
    u32 min_disp = (seconds / 60) % 60;
    u32 hour_disp = (seconds / 3600);
    return std::format("{:02d}:{:02d}:{:02d}", hour_disp, min_disp, sec_disp);
};

u32 days_per_month[12];
days_per_month[0] = 30; // april
days_per_month[1] = 31; // may
days_per_month[2] = 30; // june
days_per_month[3] = 31; // july
days_per_month[4] = 31; // august
days_per_month[5] = 30; // september
days_per_month[6] = 31; // october
days_per_month[7] = 30; // november
days_per_month[8] = 31; // december
days_per_month[9] = 31; // january
days_per_month[10] = 28; // february (2017)
days_per_month[11] = 30; // march

fn fmt_day(s16 self) {
    u8 month = 0;
    while (s16(self - days_per_month[month]) > 0) {
        self -= days_per_month[month];
        month += 1;
    }
    month = (month + 3) % 12;
    return std::format("{}/{}", month + 1, self + 1);
};

fn fmt_dataheader(ref DataHeader self) {
    return std::format(
        "{} @ f{:03}_{:03}, {}", 
        fmt_day(self.day), self.fld_major, self.fld_minor, fmt_playtime(self.playtime_frames)
    );
};

struct DataVersion {
    u32 version;
    padding[12];
}[[format("fmt_dataversion")]];
fn fmt_dataversion(ref DataVersion self) { return std::format("version {}", self.version); };

fn read_u8(u32 addr) {
    u8 value @ addr;
    return value;
};

fn read_u16(u32 addr) {
    u16 value @ addr;
    return value;
};

fn read_u32(u32 addr) {
    u32 value @ addr;
    return value;
};

fn read_u64(u32 addr) {
    u64 value @ addr;
    return value;
};

// Save data blocks

// mv::savedata::gamedata::v39_new::DataBlockPlayer<49>
enum PlayerId : u32 {
    Player = 1,
    Ryuji = 2,
    Morgana = 3,
    Ann = 4,
    Yusuke = 5,
    Makoto = 6,
    Haru = 7,
    Futaba = 8,
    Akechi = 9,
    Kasumi = 10
};

enum PIDShort : u16 {
    Player = 1,
    Ryuji = 2,
    Morgana = 3,
    Ann = 4,
    Yusuke = 5,
    Makoto = 6,
    Haru = 7,
    Futaba = 8,
    Akechi = 9,
    Kasumi = 10
};

struct PersonaStats {
    u8 strength;
    u8 magic;
    u8 endurance;
    u8 agility;
    u8 luck;
};
struct DatPersona {
    u8 flags;
    u8 unlocked;
    u16 id;
    u8 level;
    u8 inherit;
    u8 trait;
    padding[1];
    u32 exp;
    u16 skill[8];
    PersonaStats stats;
    PersonaStats stats_ex;
    PersonaStats stats_ex_temp;
    u32 field_3b;
    u8 field_3f;
}[[static, format("fmt_persona")]];
fn fmt_persona(ref DatPersona self) { return std::format("ID {}, LEVEL {}, EXP {}", self.id, self.level, self.exp); };
struct DatItem {
    u16 melee_id;
    u16 protect_id;
    u16 accessory_id;
    u16 outfit_id;
    u16 ranged_id;
};
struct DatUnit {
    u32 flags; // @ 0x0
    u16 type; // @ 0x4
    padding[2]; // @ 0x6
    PlayerId id; // @ 0x8
    u32 hp; // @ 0xc
    u32 sp; // @ 0x10
    u32 ailments; // @ 0x14
    u16 joker_lvl; // @ 0x18
    padding[2];
    u32 joker_exp; // @ 0x1c
    u32 affinity; // @ 0x20
    u32 buffs; // @ 0x24
    u32 buffs2; // @ 0x28
    u8 buff_type[10]; // @ 0x2c
    u16 field_36;; // @ 0x36
    u32 field_38; // @ 0x38
    u32 field_3c; // @ 0x3c
    u16 curr_persona_idx; // @ 0x40
    padding[2];
    DatPersona persona[12]; // @ 0x44
    DatItem items; // @ 0x284
    padding[4];
    u16 tactics_state; // @ 0x292
    u16 bullet_count; // @ 0x294
    u16 hit_status; // @ 0x296
    u32 ref_count; // @ 0x298
    u16 hp_next_lv; // @ 0x29c
    u16 sp_next_lv; // @ 0x29c
}[[static, format("fmt_datunit")]];
fn get_player_level(ref DatUnit self) {
    if (self.id == PlayerId::Player) return self.joker_lvl;
    return self.persona[0].level;
};
fn fmt_datunit(ref DatUnit self) { return std::format("{}, LV {}, HP {}, SP {}", self.id, get_player_level(self), self.hp, self.sp); };
// mv::savedata::gamedata::v39_new::DataBlockParty<49>
struct DataBlockParty {
    u16 active_party_ids[10];
    std::mem::AlignTo<0x10> align;
};
fn fmt_party(ref DataBlockParty data) {
    u32 curr_addr = addressof(data);
    str party = "Active Party: [ ";
    PIDShort curr_member = read_u16(curr_addr);
    while (curr_member != 0) {
        party += std::format("{}", curr_member);
        curr_addr += 2;
        curr_member = read_u16(curr_addr);
        if (curr_member != 0) party += ", ";
    }
    party += " ]";
    return party;
};

// mv::savedata::gamedata::v39_new::DataBlockItemBag<49>
struct ItemBag {
    u8 melee_counts[1024];
    u8 armor_counts[1024];
    u8 accessory_counts[512];
    u8 consumable_counts[1024];
    u8 key_item_counts[256];
    u8 material_counts[1024];
    u8 skill_card_counts[1024];
    u8 outfit_counts[512];
    u8 ranged_counts[256];
    u8 field_1a00[128];
};

// mv::savedata::gamedata::v39_new::DataBlockMoney<49>
struct Money {
    u32 money;
    std::mem::AlignTo<0x10> align;
}[[format("fmt_money")]];
fn fmt_money(ref Money self) { return std::format("¥{}", self.money); };

// mv::savedata::gamedata::v39_new::DataBlockFlag<49>
struct Bitflags {
    u8 section0[384];
    u8 section1[384];
    u8 section2[640];
    u8 section3[64];
    u8 section4[64];
    u8 section5[64];
};

// mv::savedata::gamedata::v39_new::DataBlockCounter<49>
struct Counts {
    u32 counts[384][[inline]];
};

// mv::savedata::gamedata::v39_new::DataBlockPersonaWork<49>
struct PersonaWork {
    DatPersona persona[464][[inline]];
};

// mv::savedata::gamedata::v39_new::DataBlockAnalyze<49>
bitfield EnemyAffinityVisible {
    KnowPhysical : 1;
    KnowGun : 1;
    KnowFire : 1;
    KnowIce : 1;
    KnowElectric : 1;
    KnowWind : 1;
    KnowPsychic : 1;
    KnowNuclear : 1;
    KnowBless : 1;
    KnowCurse : 1;
    KnowAlmighty: 1;
};
struct AnalysisData {
    #ifdef LOAD_ANALYSIS_DATA
        EnemyAffinityVisible affinity_visible[783]; // 1077 bytes
        padding[3];
        u8 knows_item_reward[100]; // 800 bitflags, used when Shadow Calculus (Makoto Rank 1) isn't yet unlocked
        EnemyAffinityVisible ai_act_multitarget[783];
        padding[3];
        EnemyAffinityVisible ai_act_singletarget[783];
        padding[3];
    #endif
    #ifndef LOAD_ANALYSIS_DATA
        u8 affinity_visible[1080][[sealed]];
        u8 knows_item_reward[100];
        u8 ai_act_multitarget[1080][[sealed]];
        u8 ai_act_singletarget[1080][[sealed]];
    #endif
    u32 field_d0c;
};

// mv::savedata::gamedata::v40::DataBlockCalendar_work<49>
struct CalendarWork {
    s16 days_since_april1[[format("fmt_day")]];
    TimeOfDay time_of_day;
    padding[1];
    u16 next_timeskip_day[[format("fmt_day")]];
    TimeOfDay next_timeskip_time;
    std::mem::AlignTo<0x10> align;
}[[format("fmt_calendar")]];
fn fmt_calendar(ref CalendarWork self) { return std::format("{}, {}", fmt_day(self.days_since_april1), self.time_of_day); };

// mv::savedata::gamedata::v39_new::DataBlockP5ShopData<49>
struct ShopData {
    u8 inner[36864][[sealed]];
};

// mv::savedata::gamedata::v39_new::DataBlockCmmWork<49>
struct CmmDataEntry {
    u16 field_00;
    u16 flags;
    u16 arcana;
    u16 lvl;
    u16 points;
    u16 invites;
    u16 field_0c;
    u16 field_0e;
}[[static, format("fmt_cmmdataentry")]];
fn fmt_cmmdataentry(ref CmmDataEntry self) { return std::format("Arcana {}, Level {}, Points {}", self.arcana, self.lvl, self.points); };

struct CommunityData {
    u16 promise;
    CmmDataEntry entries[24][[inline]];
    u16 field_182;
    u32 arbeit_pay;
    std::mem::AlignTo<0x10> align;
};

// mv::savedata::gamedata::v42::DataBlockHeroName<49>
struct PlayerName {
    u8 player_name[104][[sealed]]; // utf8
    u8 last_name[52][[sealed]]; // utf8
    u8 first_name[52][[sealed]]; // utf8
    u8 field_d0[20][[sealed]];
    u8 field_e4[20][[sealed]];
    u8 field_f8[40][[sealed]];
    u8 field_120[28][[sealed]];
    u8 phantom_theives_name[76][[sealed]]; // utf8
    padding[1];
    u8 language;
    std::mem::AlignTo<0x10> align;
};

// mv::savedata::gamedata::v39_new::DataBlockPcParam<49>
struct PlayerCharacterParam {
    u16 knowledge;
    u16 charm;
    u16 proficiency;
    u16 guts;
    u16 kindness;
    std::mem::AlignTo<0x10> align;
}[[format("fmt_pc_param")]];
fn fmt_pc_param(ref PlayerCharacterParam self) { return std::format(
    "{} knowledge, {} charm, {} proficiency, {} guts, {} kindness", 
    self.knowledge, self.charm, self.proficiency, self.guts, self.kindness
); };

// mv::savedata::gamedata::v39_new::DataBlockFldSaveCallParam<49>
struct FieldInfo {
    u16 fld_major;
    u16 fld_minor;
    u16 fld_sub;
    u16 env_id;
    vector3 pc_pos;
    vector4 pc_rot;
    padding[8];
    u16 fld_at_dng_pack_list;
    u16 fld_at_dng_pack_entry;
}[[format("fmt_fieldinfo")]];
fn fmt_fieldinfo(ref FieldInfo self) { return std::format("f{:03d}_{:03d}_{:02d} @ {}", self.fld_major, self.fld_minor, self.fld_sub, self.pc_pos); };

// mv::savedata::gamedata::v39_new::DataBlockFldSaveLog<49>
struct FieldLogEntry {
    u16 fld_major;
    u16 fld_minor;
    u32 times_visited;
}[[static, format("fmt_fieldlogentry")]];
fn fmt_fieldlogentry(ref FieldLogEntry self) { return std::format("f{:03d}_{:03d}, visited {} times", self.fld_major, self.fld_minor, self.times_visited); } ;

struct FieldSaveLog {
    FieldLogEntry visited_fields[0x40][[inline]];
    u8 unk[0x40];
};

// mv::savedata::gamedata::v39_new::DataBlockQuest<49>
enum QuestStatus : u8 {
    Blank = 0,
    Unknown,
    Identified_UseDesc0,
    Identified_UseDesc1,
    Identified_UseDesc2,
    Done
};
struct QuestEntry {
    u8 flags;
    QuestStatus status;
    u16 field_02;
    u8 field_04;
    padding[3];
}[[static, format("fmt_quest_entry")]];
fn fmt_quest_entry(ref QuestEntry self) { return std::format("{}", self.status); };
struct Quest {
    u32 known_quest_count; // Includes known but unidentified, identified and completed
    QuestEntry quests[100][[inline]];
    std::mem::AlignTo<0x10> align;
}[[format("fmt_quest")]];
fn fmt_quest(ref Quest self) { return std::format("{} known quests", self.known_quest_count); };

// mv::savedata::gamedata::v39_new::DataBlockFclPublicShop<49>
struct PublicShopEntry {
    u8 unk[0x3c][[sealed]];
    u8 item_quantity[0x1e];
    u8 field_5a;
    u8 field_5b;
    bool known_item[0x1e]; // when 0, a new! will be listed for the item
}[[static]];

struct PublicShop {
    PublicShopEntry shops[100][[inline]]; // matches with shop id as seen in fclPublicShopDataTable, fclPublicShopName etc.
    std::mem::AlignTo<0x10> align; // shop ids 89 - 99 are unused
};

// mv::savedata::gamedata::v39_new::DataBlockChat<49>
enum ChatFlags : u8 {
    None = 0,
    Read = 1 << 0,
    Switch = 1 << 1,
    Hold = 1 << 2,
    New = 1 << 3
};
struct ChatEntry {
    ChatFlags flags;
    u8 appear_month;
    u8 appear_day;
    padding[5];
    u16 msg_id;
    u16 msg_recv_idx;
    u16 field_0c;
    u16 field_0e;
}[[static, format("fmt_chatentry")]];
fn fmt_chatentry(ref ChatEntry self) { return std::format("ID {}, STAT {}, APPEAR {}/{}", self.msg_id, self.flags, self.appear_month, self.appear_day); };

struct Chat {
    u16 unk[4];
    u8 chk_arrival[128];
    ChatEntry chats[50];
    std::mem::AlignTo<0x10> align;
};

// mv::savedata::gamedata::v39_new::DataBlockSystemWork<49>
struct SystemWork {
    u32 frames[[format("fmt_playtime")]];
    std::mem::AlignTo<0x10> align;
}[[format("fmt_systemwork")]];
fn fmt_systemwork(ref SystemWork self) { return std::format("{}", fmt_playtime(self.frames)); };

// mv::savedata::gamedata::v39_new::DataBlockNpcFlag<49>
struct NpcFlags {
    u8 flags[100];
    std::mem::AlignTo<0x10> align;
};

// mv::savedata::gamedata::v39_new::DataBlockFldSaveData<49>
bitfield MementosAreaProgress {
    areas : 8;
    unlocked : 1;
    padding : 7;
}[[static]];
struct FieldSaveData {
    MementosAreaProgress mementos_paths[10];
    u32 field_14;
    u8 palace_portrait_id;
    u8 last_palace_id;
    u8 unk[38];
};

// mv::savedata::gamedata::v39_new::DataBlockCmmBookWork<49>
struct BookWork {
    u32 pages_read[128];
    bool finished_reading[128];
};

// mv::savedata::gamedata::v39_new::DataBlockNpcQuestOrder<49>
struct QuestOrder {
    u8 inner[0x50];
};

// mv::savedata::gamedata::v39_new::DataBlockNetVoice<49>
struct NetVoice {
    u8 inner[0x20];
};

// mv::savedata::gamedata::v39_new::DataBlockArbeitManager<49>
struct ArbeitManager {
    u8 inner[44];
    std::mem::AlignTo<0x10> align;
};

// mv::savedata::gamedata::v39_new::DataBlockTrophyWork<49>
struct TrophyManager {
    u8 inner[136];
    std::mem::AlignTo<0x10> align;
};
// mv::savedata::gamedata::v39_new::DataBlockBuyItemMainWork<49>
struct ItemMainWork {
    u8 inner[484];
    std::mem::AlignTo<0x10> align;
};

// mv::savedata::gamedata::v39_new::DataBlockFldMissionListWork<49>
struct FieldMissionListWork {
    u8 inner[288];
};
// mv::savedata::gamedata::v40::DataBlockCursorMemory<49>
struct CursorMemoryPlayer {
    u16 persona_id;
    u16 skill_id;
    padding[8];
}[[static]];

struct CursorMemory {
    CursorMemoryPlayer player_params[11];
    u16 item_id;
    padding[2];
    u32 item_sel;
    u32 item_sel_pad;
};
// mv::savedata::gamedata::v39_new::DataBlockFldCasinoWork<49>
struct FieldCasinoWork {
    u32 entries[20][[inline]];
};
// mv::savedata::gamedata::v39_new::DataBlockSndAppBgmWork<49>
struct SoundBgmWork {
    u32 field_00;
    u32 field_04;
    u16 field_08;
    u8 field_0a;
    u8 field_0b;
    u32 field_0c;
};
// mv::savedata::gamedata::v39_new::DataBlockDiary<49>
struct DiaryEntry {
    u8 activity0; // Value used refers to the index in cmmNetReportTable.ctd
    u8 activity1;
}[[static]];

struct Diary {
    DiaryEntry entry[365][[inline]]; // Daily Log entries in Camp menu Calendar
    std::mem::AlignTo<0x10> align;
};
// mv::savedata::gamedata::v39_new::DataBlockFldSaveATDngStamp<49>
struct MementosStampPack {
    u16 field_00;
    padding[2];
    u8 field_04;
    padding[3];
}[[static]];

struct JoseStampData {
    MementosStampPack stamp_packs[8];
    padding[14];
    u16 exp_boost;
    u16 money_boost;
    u16 item_boost;
    padding[10];
    u32 coin_count;
    std::mem::AlignTo<0x10> align;
};
// mv::savedata::gamedata::v39_new::DataBlockCustomData<49>
struct GunCustomData {
    u8 inner[256][[inline]];
};
// mv::savedata::gamedata::v39_new::DataBlockFclCombineSaveData<49>
struct VelvetRoomSaveData {
    u8 inner[102];
    std::mem::AlignTo<0x10> align;
};
// mv::savedata::gamedata::v39_new::DataBlockFclMementosShop<49>
struct MementosShop {
    u8 inner[412];
    std::mem::AlignTo<0x10> align;
};
// mv::savedata::gamedata::v39_new::DataBlockCmpSkillCard<49>
struct SkillCard {
    u8 inner[128];
};
// mv::savedata::gamedata::v39_new::DataBlockChallengeBtl<49>
struct ChallengeEntry {
    u32 high_score;
    padding[2];
    u16 rewards_done; // bitflags (0x1 - first reward, 0x2 - second reward, 0x4 - third reward)
}[[static]];

struct ChallengeBattle {
    ChallengeEntry battles[16][[inline]];
};
// mv::savedata::gamedata::v39_new::DataBlockCmpPcData<49>
struct PlayerCharacterData {
    u32 inner[12][[inline]];
    std::mem::AlignTo<0x10> align;
};

// mv::savedata::gamedata::v39_new::DataBlockBtlPlayLog<49>
struct BattlePlayLog {
    u32 inner[16][[inline]];
};

// System data blocks

// mv::savedata::sysdata::v2_new::DataBlockSysFlag<7>
struct SystemFlags {
    u8 flags[64];
};
// mv::savedata::sysdata::v2_new::DataBlockMyPalaceItem<7>
// mypItemDataTable.mtd
struct ThievesDenItemPlacedEntry {
    u16 item_id;
    u8 unk[14];
}[[static]];

struct ThievesDenItems {
    ThievesDenItemPlacedEntry placed_items[16];
    u8 place_item_menu_known[12]; // bitflags for 96 items, 58 used in game
    u8 buy_item_menu_known[12];
    u8 field_118[12];
    u8 place_item_menu_new[12];
    u8 buy_item_menu_new[12];
    u32 item_npc_data[80];
    u8 decor_type;
    padding[3];
};
// mv::savedata::sysdata::v2_new::DataBlockThiefPoint<7>
struct ThievesDenPoints {
    u32 points;
    std::mem::AlignTo<0x10> align;
}[[format("fmt_thievesden_points")]];
fn fmt_thievesden_points(ref ThievesDenPoints self) { return std::format("P {}", self.points); };
// mv::savedata::sysdata::v2_new::DataBlockMyPalaceVideo<7>
struct ThievesDenVideo {
    u8 is_owned[0x10]; // bitflag for each video (according to order of videos in mypVideoDataTable.mtd
    u8 is_known[0x10];
    u8 is_unlocked[0x10];
    u8 field_30[0x10];
    u8 is_new[0x10];
};
// mv::savedata::sysdata::v2_new::DataBlockMyPalaceSound<7>
struct ThievesDenMusic {
    u8 music_bought[0x14];
    u8 music_known[0x14];
    u8 field_28[0x14];
    u8 music_previewed[0x14];
    u8 music_not_new[0x14];
    std::mem::AlignTo<0x10> align;
};
// mv::savedata::sysdata::v2_new::DataBlockMyPalaceImage<7>
struct ThievesDenImage {
    u8 image_bought[0x1c];
    u8 image_known[0x1c];
    u8 field_38[0x1c];
    u8 image_previewed[0x1c];
    u8 image_not_new[0x1c];
    std::mem::AlignTo<0x10> align;
};
// mv::savedata::sysdata::v2_new::DataBlockMyPalaceAward<7>
struct ThievesDenAward {
    u32 award_progress[80];
    u8 unk[0x2440][[sealed]];
    u8 awards_completed[12]; // bitflags
    u8 field_2598[12];
    u8 unk2[0x18][[sealed]];
};
// mv::savedata::sysdata::v2_new::DataBlockMyPalaceEnv<7>
struct ThievesDenENV {
    u32 field_00;
    u8 env_known[4];
    u8 field_0c[4];
    u8 field_10[4];
    u8 env_not_new[4];
    std::mem::AlignTo<0x10> align;
};
// mv::savedata::sysdata::v2_new::DataBlockMyPalaceCareerPoker<7>
struct TycoonPlacement {
    u32 tycoon;
    u32 rich;
    u32 poor;
    u32 beggar;
};
struct TycoonData {
    padding[32];
    u8 settings[16]; // settings bitflags
    TycoonPlacement casual;
    TycoonPlacement serious;
    TycoonPlacement cutthroat;
    padding[208];
    u8 challenges[16]; // challenges completed bitflags
    
};
// mv::savedata::sysdata::v4::DataBlockKeyAssign<7>
struct KeyboardKeys {
    // this uses Hedgehog Engine Input keycodes
    // A translation to Direct Input Keycodes is available at g_keyboardmgr->KeyboardWin32->HHToDIKCodes
    // [[142a8bbf8] + 60] + 5c8 in Cheat Engine
    u32 entries[8];
}[[static]];

struct KeyAssign {
    u16 controller_keys[0x80];
    KeyboardKeys keyboard_keys[0x80];
    u8 unk[0x800];
};
// mv::savedata::sysdata::v5::DataBlockActivity<7>
// mv::savedata::sysdata::v5::DataBlockSaveloadWindow<7>
// mv::savedata::sysdata::v6::DataBlockConfigOption<7>

bitfield ConfigOptionFlags {
    Flag0 : 1;
    Vibration : 1;
    DialogueVoices : 1;
    AutoAdvance : 1;
    AnimationSubtitles : 1;
    MaintainFastForward : 1;
    CursorMemory : 1;
    BattleMemory : 1;
    PersonaMemory : 1;
    CamHorizontalInvert : 1;
    CamVerticalInvert : 1;
    CameraShake : 1;
    CameraAutoAdjust : 1;
    CamAdjustOnCover : 1;
    RotateMinimapWithCamera : 1;
    JapaneseVoices : 1;
    Flag16 : 1;
    EnableVSync : 1;
    Flag18 : 1;
    Flag19 : 1;
    Flag20 : 1;
    Flag21 : 1;
    Flag22 : 1;
    Flag23 : 1;
    Flag24 : 1;
    Flag25 : 1;
    Flag26 : 1;
    Flag27 : 1;
    Flag28 : 1;
    Flag29 : 1;
    Flag30 : 1;
    Flag31 : 1;
};

struct ConfigOptions {
    u8 mouse_sense;
    u8 control_sense;
    u8 button_display;
    u8 main_volume;
    u8 bgm_volume;
    u8 se_volume;
    u8 voice_volume;
    u8 movie_volume;
    u8 graphic_quality;
    u8 shadow_quality;
    u8 antialias;
    u8 dof_level;
    padding[4];
    u16 render_scale;
    u16 fps_limit;
    ConfigOptionFlags flags;
    u32 width;
    u32 height;
    padding[8];
    u16 screen_dimness;
    padding[2];
    u8 cam_speed;
    std::mem::AlignTo<0x10> align;
};

// 0x14809c7f0
struct DataBlock {
    u32 block_id;
    u32 size;
    padding[8];
    match (block_id) {
        (0x10001 ... 0x1000A): DatUnit data;
        (0x18001 ... 0x1800A): DatUnit data;
        (0x10011 | 0x18011): DataBlockParty data;
        (0x10012 | 0x18012): ItemBag data;
        (0x10013 | 0x18013): Money data;
        (0x10014 | 0x18014): Bitflags data;
        (0x10015 | 0x18015): Counts data;
        (0x10016 | 0x18016): PersonaWork data;
        (0x10017 | 0x18017): AnalysisData data;
        (0x10018 | 0x18018): CalendarWork data;
        (0x10019 | 0x18019): ShopData data;
        (0x1001a | 0x1801a): CommunityData data;
        (0x1001b | 0x1801b): Quest data;
        (0x1001c | 0x1801c): PlayerName data;
        (0x1001d | 0x1801d): PlayerCharacterParam data;
        (0x1001f | 0x1801f): PublicShop data;
        (0x10020 | 0x18020): Chat data;
        (0x10021 | 0x18021): SystemWork data;
        (0x10022 | 0x18022): NpcFlags data;
        (0x10023 | 0x18023): FieldSaveData data;
        (0x10024 | 0x18024): BookWork data;
        (0x10025 | 0x18025): QuestOrder data;
        (0x10026 | 0x18026): NetVoice data;
        (0x10027 | 0x18027): ArbeitManager data;
        (0x10028 | 0x18028): TrophyManager data;
        (0x10029 | 0x18029): ItemMainWork data;
        (0x1002a | 0x1802a): FieldMissionListWork data;
        (0x1002b | 0x1802b): CursorMemory data;
        (0x1002c | 0x1802c): FieldCasinoWork data;
        (0x1002d | 0x1802d): SoundBgmWork data;
        (0x1002e | 0x1802e): Diary data;
        (0x1002f | 0x1802f): JoseStampData data;
        (0x10030 | 0x18030): GunCustomData data;
        (0x10031 | 0x18031): VelvetRoomSaveData data;
        (0x10032 | 0x18032): MementosShop data;
        (0x10033 | 0x18033): SkillCard data;
        (0x10034 | 0x18034): ChallengeBattle data;
        (0x10035 | 0x18035): PlayerCharacterData data;
        (0x30000 | 0x30001): FieldInfo data;
        (0x30002): FieldSaveLog data;
        (0x40000): BattlePlayLog data;
        (0x60000): SystemFlags data;
        (0x60001): ThievesDenItems data;
        (0x60002): ThievesDenPoints data;
        (0x60003): ThievesDenVideo data;
        (0x60004): ThievesDenMusic data;
        (0x60005): ThievesDenImage data;
        (0x60006): ThievesDenAward data;
        (0x60007): ThievesDenENV data;
        (0x60008): TycoonData data;
        (0x60009): KeyAssign data;
        (0x6000c): ConfigOptions data;
        (_): u8 data[size][[sealed]];
    }
}[[name(std::format("SAVE BLOCK 0x{:X}", block_id)), format("fmt_datablock")]];

fn fmt_datablock(ref DataBlock self) {
    match (self.block_id) {
        (0x10001 ... 0x1000A): return fmt_datunit(self.data);
        (0x18001 ... 0x1800A): return fmt_datunit(self.data);
        (0x10011 | 0x18011): return fmt_party(self.data);
        (0x10012 | 0x18012): return "Item Bag";
        (0x10013 | 0x18013): return fmt_money(self.data);
        (0x10014 | 0x18014): return "Bitflags";
        (0x10015 | 0x18015): return "Counts";
        (0x10016 | 0x18016): return "Persona Compendium Record";
        (0x10017 | 0x18017): return "Analysis Data";
        (0x10018 | 0x18018): return fmt_calendar(self.data);
        (0x10019 | 0x18019): return "P5 Shop Data TODO";
        (0x1001a | 0x1801a): return "Confidant Data";
        (0x1001b | 0x1801b): return fmt_quest(self.data);
        (0x1001c | 0x1801c): return "Player Name";
        (0x1001d | 0x1801d): return fmt_pc_param(self.data);
        (0x1001f | 0x1801f): return "Public Shop Data";
        (0x10020 | 0x18020): return "Chat Data";
        (0x10021 | 0x18021): return fmt_systemwork(self.data);
        (0x10022 | 0x18022): return "NPC Flags";
        (0x10023 | 0x18023): return "Mementos Palace Data";
        (0x10024 | 0x18024): return "Book Reading";
        (0x10025 | 0x18025): return "Quest Order TODO";
        (0x10026 | 0x18026): return "Net Voice TODO";
        (0x10027 | 0x18027): return "Arbeit Manager TODO";
        (0x10028 | 0x18028): return "Trophy Manager TODO";
        (0x10029 | 0x18029): return "Item Main Work TODO";
        (0x1002a | 0x1802a): return "Field Mission List TODO";
        (0x1002b | 0x1802b): return "Cursor Memory";
        (0x1002c | 0x1802c): return "Field Casino TODO";
        (0x1002d | 0x1802d): return "Sound BGM Data";
        (0x1002e | 0x1802e): return "Diary (Camp Menu Calendar)";
        (0x1002f | 0x1802f): return "Jose Stamp Data (Mementos)";
        (0x10030 | 0x18030): return "Gun Customization Data";
        (0x10031 | 0x18031): return "Velvet Room Save Data TODO";
        (0x10032 | 0x18032): return "Mementos Shop Data TODO";
        (0x10033 | 0x18033): return "Skill Card TODO";
        (0x10034 | 0x18034): return "Challenge Battle";
        (0x10035 | 0x18035): return "Player Character Params TODO";
        (0x30000 | 0x30001): return fmt_fieldinfo(self.data);
        (0x30002): return "Field Save Log";
        (0x40000): return "Battle Log Data TODO";
        (0x60000): return "System Flags";
        (0x60001): return "Thieves Den Items";
        (0x60002): return fmt_thievesden_points(self.data);
        (0x60003): return "Thieves Den Videos";
        (0x60004): return "Thieves Den BGM";
        (0x60005): return "Thieves Den Images";
        (0x60006): return "Thieves Den Awards";
        (0x60007): return "Thieves Den ENV";
        (0x60008): return "Thieves Den Tycoon Data";
        (0x60009): return "Button Config";
        (0x6000a): return "Activity Data TODO";
        (0x6000b): return "Save Load Window TODO";
        (0x6000c): return "Config Options";
        (0xffffffff): return "EOF";
        (_): return std::format("TODO", self.block_id); 
    }
};

struct SaveFile {
    EncryptInfo encrypt_info;
    DataInfo data_info;
    if (data_info.head_size == 0x1d0)
        DataHeader data_header;
    DataVersion version;
    DataBlock data_blocks[while(!std::mem::eof())][[inline]];
};

SaveFile contents @ 0x00[[inline]];