#pragma author moddaman
#pragma endian little

import type.base;

struct defNPC {
    u32 Index [[color("00FF00")]];
    u16 X [[color("FFFF00")]];
    u16 Y [[color("DDDD00")]];
    type::Hex<u16> Field08 [[color("00FFFF"), comment("Padding?")]];
    type::Hex<u16> [[color("FF00FF"), comment("Denotes end of segment?")]];
};

struct npcDAT {
    u32 NumNPC [[name("Total NPCs"), color("FF0000")]];
    defNPC AllNPC[NumNPC] [[name("All NPCs"), comment("List is completely unsorted, entries can go in any order")]];
    /*
        File may have extra bytes from here, but they're always just
        duplicated from the first X bytes of the file for padding
    */
};

npcDAT FILE @ 0 [[inline]];