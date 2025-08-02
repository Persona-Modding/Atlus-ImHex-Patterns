#include <atlus/common/ftd.hexpat>

struct Quest {
    u32 NewFlag [[comment("The flag that causes the New badge to show next to the quest in the quest list")]];
    u32 UnlockedFlag [[comment("The flag that causes the quest to show as unlocked in the quest list")]];
    u32 CompletedFlag [[comment("The flag that causes the quest to show as completed in the quest list")]];
    u32 Id [[comment("The id of the quest. Used to get the name in the cmpQuestItem.ctd file and description in the datQuestHelp.bmd file")]];
};

Ftd<Quest> File @ 0 [[inline]];