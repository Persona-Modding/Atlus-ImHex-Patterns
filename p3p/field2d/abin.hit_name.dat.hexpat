#pragma author moddaman
#pragma endian little

struct objName {
    char Name[64] [[color("00DDDD")]];
};

struct nameDAT {
    u32 NamesLength [[name("Size"), comment("Total length of all names in bytes"), color("00BB00")]];
    u32 TotalNames [[name("Total Names"), color("0000FF")]];
    objName ObjectNames[TotalNames] [[name("Object Names"), comment("String can get cut-off in-game if too long")]];
     /*
        File may have extra bytes from here, but they're always just
        duplicated from the first X bytes of the file for padding
    */
};

nameDAT FILE @ 0 [[inline]];