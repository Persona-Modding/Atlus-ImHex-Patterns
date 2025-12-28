#pragma author SecreC.
#pragma description Reads P5 ftd/ctd/mtd/ttd files, taken from the 010 template repo https://github.com/tge-was-taken/010-Editor-Templates
#pragma endian big

// Imhex includes
#include <std/io.pat>
#include <std/mem.pat>
#include <std/string.pat>
#include <hex/provider.pat>

// tbl includes
#include <atlus/p5r/tbl/skill.expat>

// globals
str fileName = hex::prv::get_information("file_name");
u32 fileSize = std::mem::size();
u32 currentBlockIdx = 0;
u32 currentBlockSize = 0;

struct tblBlock {
    u32 blockSize;
    currentBlockSize = blockSize;
    
    match (std::string::to_upper(fileName)) {
        ("SKILL.TBL"): SkillTblBlock block;
        (_) : u8 block[blockSize];
    }
    
    padding[GetPaddingBytes($)];
    currentBlockIdx += 1;
};

fn GetPaddingBytes(u32 place) {
    if (place % 0x10 == 0)
        return 0;
    
    return 0x10 - (place % 0x10);
};

tblBlock block[while(!std::mem::eof())] @0x00;
