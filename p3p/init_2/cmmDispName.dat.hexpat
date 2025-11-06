#pragma author AnimatedSwine
#pragma endian little

struct DispNameEntry {
    u32 Id [[comment("The ID of the NPC this is for. Used in places like the tmx files in field2d/npc.")]];
    u32 RealNameFlag [[comment("The flag that needs to be on for RealName to be used or 0 if they never are a stranger.")]];
    char StrangerName[17] [[comment("The initial name displayed for the character. Used when you shouldn't know their name yet.")]];
    char RealName[19] [[comment("The character's real name. Used once you know them, when the RealNameFlag is true")]];
};

struct CmmDispNameHeader {
    u32 FileSize [[comment("The size of the file excluding the header")]];
    u32 NumEntries;    
};

struct CmmDispName {
    CmmDispNameHeader Header;
    DispNameEntry Entries[Header.NumEntries];
};

CmmDispName File @ 0 [[inline]];