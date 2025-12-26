#pragma author oceanstuck
#pragma description Reads P5R mtd files, used for Thieves Den. Made with help of Cornflakes.
#pragma endian big

#include <hex/provider.pat>
#include <std/string.pat>
#include <atlus/p5r/common/bitflag.expat>

str fileName = hex::prv::get_information("file_name");

struct MtdHeader {
    u32 version, magic, size, unknown1, unknown2;
    padding[16];
    u32 dataLength, entryCount;
    padding[4];
};

enum AwardCategory : u8 {
    SchoolLife,
    Confidants,
    Battle,
    Phantom,
    Unused = 0xFF
};

struct MtdAwardDataEntry {
    AwardCategory category;
    u8 unknown1;
    padding[2];
    u32 reward, requirement;
};

struct MtdImageDataEntry{
    u16 unknown1, unknown2, unknown3, unknown4;
    u8 month, day; 
    u16 priceMaybe;
    Bitflag bitflags[2];
};

enum ItemCategory : u8 {
    VelvetRoom,
    Metaverse,
    Enemy,
    Confidants,
    DailyLife
};

struct MtdItemDataEntry {
    u16 bfMajor, bfMinor;   // ids of fbn, mhit, and mnpc to use. bfMajor is 22 for all except unused, which is same major id as thieves' den itself
    u8 unknown1;            // for objects in the skylight, is 4
    ItemCategory category;
    u8 unknown2;            // for objects in the skylight, is 2
    padding[1];
    u8 month, day;
    u16 price;
    Bitflag bitflags[2];
};

struct MtdOrnamentDataEntry {
    u8 month, day;
    u16 unknown1;    // this is 1000 for all except default den decor
    Bitflag bitflags[2];
};

struct MtdSoundDataEntry {
    u16 cueId, unknown1;
    u8 month, day;
    u16 price;
    Bitflag bitflags[2];
};

struct MtdVideoDataEntry {
    u32 unknown1;
    u16 storyArc, msgId;
    u64 unknown2;
    u8 month, day;
    u16 price;
    Bitflag bitflags[2];
};

struct MtdEntry {
    if (std::string::ends_with(fileName, "NameTable.mtd")) { char name[64]; }
    else {
        match (fileName) {
            ("mypAwardDataTable.mtd"): MtdAwardDataEntry entry;
            ("mypImageDataTable.mtd"): MtdImageDataEntry entry;
            ("mypItemDataTable.mtd"):  MtdItemDataEntry entry;
            ("mypOrnamentDataTable.mtd"): MtdOrnamentDataEntry entry;
            ("mypSoundDataTable.mtd"): MtdSoundDataEntry entry;
            ("mypVideoDataTable.mtd"): MtdVideoDataEntry entry;
            (_) : u16 entry;
        }
    }
};

MtdHeader header @0x00;
MtdEntry entries[header.entryCount] @0x30;.mtd"): MtdVideoDataEntry entry;
        (_) : u16 entry;
    }
};

MtdHeader header @0x00;
MtdEntry entries[header.entryCount] @0x30;