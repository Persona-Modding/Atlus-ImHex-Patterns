#include <std/core.pat>
std::core::set_endian(std::mem::Endian::Little);

struct defObject {
    u32 ID [[color("00FF00")]];
    u16 X [[color("FFFF00")]];
    u16 Y [[color("DDDD00")]];
    u16 Field08 [[color("00FFFF")]];
    u16 Field0A [[color("FF00FF")]];
};

struct fieldDAT {
    u32 TotObj [[name("Total Objects"), color("FF0000")]];
    defObject Objects[TotObj];
    /*
        File may have extra bytes from here, but they're always just
        duplicated from the first X bytes of the file for padding
    */
};

fieldDAT FILE @ 0 [[inline]];