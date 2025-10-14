#pragma author oceanstuck
#pragma endian big

#include <std/io.pat>
#include <std/mem.pat>

enum CharacterId : u16 {
    None,
    Joker,
    Ryuji,
    Mona,
    Ann,
    Yusuke,
    Makoto,
    Haru,
    Futaba,
    Akechi,
    Sumire,
    Justine = 1001,
    Caroline,
    Sojiro,
    Iwai,
    Sae,
    Hifumi,
    Ohya,
    Takemi,
    Kawakami,
    Shinya,
    Mishima,
    Yoshida,
    Chihaya,
    Maruki
};

struct ResrcNpcTblEntry {
    u16 npcId;
    u16 unknown1;
    CharacterId modelMajorId;
    u8 modelMinorId;
    u8 modelSubId;
    u16 attach_major;
    u8 attach_minor;
    u8 umbrella;
    u16 attach_major2;
    u8 attach_minor2;
    u8 anim_type;
    u16 unknown2;
    u16 unknown3;
    u16 anim_base;
    u16 anim_add;
    u16 anim_base_rain;
    u16 anim_add_rain;
}[[format("FormatResrcNpc")]];

fn FormatResrcNpc(ref ResrcNpcTblEntry self) {
    return std::format("{} - C{}_{}_{}", self.npcId, u16(self.modelMajorId), self.modelMinorId, self.modelSubId);
};

u32 numEntries = std::mem::size() / 0x1c;
ResrcNpcTblEntry entries[numEntries] @0x0;