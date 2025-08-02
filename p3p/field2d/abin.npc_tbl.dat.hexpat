#pragma author moddaman
#pragma endian little

import type.base;

/* 
    TODO: Figure out how to force 'Pattern Data' window to sort
    enum keys by the actual value instead of alphabetically
*/
enum times : u8 {
    A_EarlyMorning = 0,
    B_Morning = 1,
    C_Lunchtime = 2,
    D_Daytime = 3,
    E_AfterSchool = 4,
    F_Evening = 5,
    G_LateNight = 6
};

struct calendarGroup {
    u8 OnMonth [[color("FF77FF")]];
    u8 OnDay [[color("DD55DD")]];
    times OnTime [[color("FFFF00")]];
    type::Hex<u8> Field03 [[color("00FFFF")]];
    type::Hex<u32> Field04 [[color("00FFFF")]];
    u32 GroupID [[color("00FF00"), comment("NPC Group to load from *_pck.dat")]];
    
};

struct tblDAT {
    type::Hex<u32> GroupsLength [[name("Size"), color("00BB00"), comment("Length of all calendar groups in bytes")]];
    u32 TotalGroups [[name("Total Groups"), color("FF0000")]];
    calendarGroup LoadDates[TotalGroups] [[name("Calendar Groups"), comment("Changes NPC groups past specified calendar dates and times")]];
    /*
        File may have extra bytes from here, but they're always just
        duplicated from the first X bytes of the file for padding
    */
};

tblDAT FILE @ 0 [[inline]];