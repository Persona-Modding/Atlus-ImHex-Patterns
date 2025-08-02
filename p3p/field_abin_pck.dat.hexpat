#include <std/core.pat>
std::core::set_endian(std::mem::Endian::Little);

/* 
    TODO: Document what the unknown icons actually are,
    since ImHex seems to shows the value as {enumname}::??? when
    there isn't a corresponding entry, as opposed to the raw
    value like 010 does.
*/
enum icons : u8 {
    AreaTransition = 8,
    SavePoint = 56,
    Unknown18 = 24,
    Unknown48 = 72
};

struct fldObject {
    u16 ID [[color("FFFF00")]];
    u8 Field02 [[color("00FFFF")]];
    icons Icon [[color("FF7FFF")]];
    u16 Field04 [[color("00FFFF")]];
    u16 Field06 [[color("0000FF"), comment("Appears to always be 0xE803?")]];
    u32 ProcedureIndex [[color("00FF00"), comment("Index of Flowscript procedure to call when Object is interacted with.")]];
    u32 Field0C [[color("00FFFF")]];
};

struct pckDAT {
    u32 TotalLength [[color("FF0000"), comment("Total length of all objects in bytes.")]];
    u32 ObjectCount [[color("FF0000")]];
    fldObject FieldObjects[ObjectCount] [[name("Field Objects")]];
    /*
        File may have extra bytes from here, but they're always just
        duplicated from the first X bytes of the file for padding
    */
};

pckDAT FILE @ 0 [[inline]];