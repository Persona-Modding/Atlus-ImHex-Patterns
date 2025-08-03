#pragma author moddaman
#pragma endian little

import type.base;

/* 
    TODO: Figure out how to force 'Pattern Data' window to sort
    enum keys by the actual value instead of alphabetically
*/
enum chID : u8 {
    Makoto = 1,
    Yukari = 2,
    Aigis = 3,
    Mitsuru = 4,
    Junpei = 5,
    Fuuka = 6,
    Akihiko = 7,
    Ken = 8,
    Shinji = 9,
    Koromaru = 10,
    Ikutsuki = 11,
    Ryoji = 13,
    Takaya = 17,
    Kazushi = 20,
    Yuko = 21,
    Keisuke = 25,
    Hidetoshi = 26,
    Chihiro = 27,
    Rio = 29,
    Kenji = 30,
    Bebe = 31,
    Mamoru = 32,
    Bunkichi = 33,
    Mitsuko = 34,
    Maiko = 35,
    Tanaka = 36,
    Nozomi = 37,
    Mutatsu = 38,
    Akinari = 39,
    Saori = 41,
    Toriumi = 43,
    Elizabeth = 54,
    Theo = 55,
    Kotone = 99,
    Kashiwagi = 132,
    Margaret = 213,
    Vincent = 214
};

struct chunkSep {
    type::Hex<u32> Field00 [[comment("Always 0xFFFF0000?")]];
    type::Hex<u32> Field04 [[comment("Always 0x0000E803?")]];
    type::Hex<u32> Field08 [[comment("Always 0xFFFFFFFF?")]];
    type::Hex<u32> Field0C [[comment("Always 0x00000000?")]];
};

struct chunkNPC {
    /*
        TODO: Investigate if workaround/fix for "files with incorrect Segment counts"
        I did for 010 template is actually necessary or not
    */
    u32 PositionID [[color("0x00FF00")]];
    chID CharacterID [[color("0xFF77FF"), comment("NPC's character ID, determines nametag and texture (nX_0_0_0.tmx)")]];
    u8 TexVarID [[color("0xDD55DD"), comment("n0_X_0_0.tmx")]];
    type::Hex<u16> Field06 [[color("0x0000FF"), comment("Always 0xE803?")]];
    u32 ProcedureIndex [[color("0xFFFF00"), comment("Calls script procedure from corresponding BF file")]];
    u32 ShowOnFlag [[color("0x0077FF"), comment("Shows NPC if bitflag is enabled")]];
};

/**
    Checks if the following segment has values which identify it as the end
    of an NPC Group, returning true/false if it is or isn't respectively.
    Always reads relative to current position in file using $ operator.
*/
fn isNextEnd() {
    if (std::mem::read_unsigned($, 4, std::mem::Endian::Little) == 0xFFFF && std::mem::read_unsigned($ + 4, 4, std::mem::Endian::Little) == 0x3E80000 && std::mem::read_unsigned($ + 8, 4, std::mem::Endian::Little) == 0xFFFFFFFF && std::mem::read_unsigned($ + 12, 4, std::mem::Endian::Little) == 0) {
        return true;
    }
    return false;
};

struct npcGroup {
    chunkNPC NPC[while(!isNextEnd())];
    chunkSep Seperator [[color("0000FF"), comment("Seperates NPC Groups)")]];
};

struct pckDAT {
    type::Hex<u32> SegmentsLength [[name("Size"), color("00BB00"), comment("Total length of all NPC groups in bytes")]];
    u32 TotalSegments [[color("FF0000"), comment("Increments by 0x10")]];
    npcGroup GroupNPC[while(!std::mem::reached(SegmentsLength + 8))] [[name("Group")]];
};

pckDAT FILE @ 0 [[inline]];