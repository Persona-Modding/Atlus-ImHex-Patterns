// Unsure what the uncommented ones do but they're different for each type of item
enum ItemType : u8
{
    Weapon = 0,
    Armor = 1,
    Accessory = 2,
    ConsumableOrBugOrFish = 3, // Uses set skill
    BookOrKey = 4,
    Material = 5,
    SkillCard = 6, // Teaches set skill
    Clothes = 7,
    VegetableOrGem = 8
};

// TODO clean up numbers, confirm this is right
enum ItemIcon : u32
{
    YuSword = 1,
    YosukeKnives = 2,
    ChieShoes = 4,
    YukikoFan = 8,
    KanjiShield = 16,
    NaotoGun = 32,
    TeddieClaws = 64,
    Armor = 16384,
    Accessory = 32768,
    Consumable = 65536,
    Key = 131072,
    Material = 262144,
    SkillCard = 524288,
    Clothes = 1048576,
    Bug = 2097152,
    Fish = 4194304,
    Vegetable = 8388608,
    Book = 33554432,
    Gem = 268435456
};

bitfield EquippableBy {
    padding : 5; // TODO confirm this is right...
    Protag : 1;
    Yosuke : 1;  
    Chie : 1;
    Rise : 1;
    Kanji : 1;
    Naoto : 1;
    Teddie : 1;
    padding : 4;
};

struct ItemInfo {
    ItemType Type;
    padding[3];
    ItemIcon Icon;
    u16 Attack;
    u16 Accuracy; 
    u8 Unk[4]; // TOOD work out
    u16 Defense;
    u16 Evade;
    u8 Unk2[16];
    u16 Skill;
    padding[2];
    u16 AddedEffect;
    padding[2];
    u32 Unk3;
    EquippableBy EquippableBy;
    padding[2]; // TODO confirm
    u32 StoreCost;
    u8 SaleMonth [[comment("The month that the item becomes available in store")]];
    u8 SaleDay [[comment("The day of the month that the item becomes available in store")]];
    padding[2]; // TODO confirm whether this data is used or actual padding
    u8 NumMaterials;
    u16 MaterialId;
    u8 Unk4[5]; // TODO work out
};

struct ItemName {
    char Name[24];
};

struct SectionHeader {
    u32 NumEntries;
    u8 Unk[12]; // TODO work out what all this is!
};

struct ItemTbl {
    SectionHeader ItemInfoHeader;
    ItemInfo ItemInfo[ItemInfoHeader.NumEntries];
    SectionHeader ItemNameHeader;
    ItemName ItemName[ItemNameHeader.NumEntries];
};

ItemTbl File @ 0 [[inline]];