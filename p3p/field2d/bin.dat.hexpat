#pragma author moddaman
#pragma endian little

import type.base;

struct layoutHeader {
    type::Hex<u32> Field00;
    type::Hex<u32> Field04;
    u32 Size [[color("FF0000"), comment("Total Width & Height of field navigable by player. Textures scaled to fit. Scaled by resolution(?)")]];
    // TODO: Learn what all of these do in relation to the effect files...
    type::Hex<u16> Field0C;
    type::Hex<u16> Field0E;
    type::Hex<u16> Field10;
    type::Hex<u16> Field12;
    type::Hex<u16> Field14;
    type::Hex<u16> Field16;
};

struct textureSegment
{
    u16 ConnectRight [[color("0xCC00CC"), comment("ID of segment to connect this one to the right of. Indexes from 1.")]];
    u16 ConnectUnder [[color("0xFF00FF"), comment("ID of segment to connect this one underneath. Indexes from 1.")]];
    s16 OffsetX [[color("0xFFFF00"), comment("Amount to move segment around on X-Axis. Game auto-expands field size with large/negative values that exceed bounds(?)")]];
    s16 OffsetY [[color("0xCCCC00"), comment("Amount to move segment around on Y-Axis. Game auto-expands field size with large/negative values that exceed bounds(?)")]];
    char FileName[0x20] [[color("0x22FF22")]];
} [[name("Texture")]];

struct effectSegment {
    char FileName[0x20] [[color("0x00CC00")]];
} [[name("Effect")]];

struct fieldLayout {
    layoutHeader Header;
    textureSegment FldSegments[3] [[name("Field Segments"), comment("List of background texture files to load into field.")]];
    effectSegment EffSegments[4] [[name("Effect Segments"), comment("List of effect files to load into field. Only 3 are usable?")]];
    /*
        File may have extra bytes from here, but they're always just
        duplicated from the first X bytes of the file for padding
    */
};

fieldLayout FILE @ 0 [[inline]];