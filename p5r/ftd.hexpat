#pragma author SecreC.
#pragma description Reads P5 ftd/ctd/mtd/ttd files, taken from the 010 template https://github.com/tge-was-taken/010-Editor-Templates

// imhex includes
#include <std/io.pat>
#include <std/mem.pat>
#include <std/core.pat>
#include <std/string.pat>
#include <hex/provider.pat>

// ftd includes
#include <p5r/ftd/ftdEntryStructs.expat>

struct ftdStringList {
    u8 stringLen;
    u8 unk01;
    u8 unk02;
    u8 unk03;
    char value[stringLen];
}[[name(std::format("[{}] ftdStringEntry", currentEntry)), format("fmt_ftdStringList")]];

struct ftdStringListPointer {
    ftdStringList *ftdString : u32 [[inline]];
    currentEntry = currentEntry + 1;
}[[inline]];

fn fmt_ftdStringList(ref ftdStringList self) {
    return self.value;
};

struct ftdData {
    ftdEntryStruct entry;
    currentEntry = currentEntry + 1;
}[[inline]];

struct ftdDataList {
    s32 unk00;
    u32 listSize;
    u32 entryCount;
    s16 entryType;
    s16 unk0e;

    entrySize = listSize / entryCount;
    currentEntry = 0;
    ftdData data[entryCount];
}[[name(std::format("List [{}]", currentList))]];

struct ftdDataListPointer {
    ftdDataList *listOffsets : u32 [[inline]];
    currentList = currentList + 1;
}[[inline]];

struct ftdHeader {

    std::core::set_endian(std::mem::read_unsigned(1,1,1));
    std::print("Ftd endianness is {}", std::core::get_endian());

    u32 unk00;
    u32 magic;
    u32 fileSize;

    if (std::core::get_endian() == 1) {
        // Big Endian
        s16 listType;
        s16 listCount;
    } else {
        // Little Endian
        s16 listCount;
        s16 listType;
    }

    if (listType == 0)
        ftdDataListPointer lists[listCount];
    else
        ftdStringListPointer lists[listCount][[inline]];
};

u32 entrySize = 0;
u32 currentList = 0;
u32 currentEntry = 0;

ftdHeader data @0x0;
