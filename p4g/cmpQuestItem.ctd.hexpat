#include <atlus/common/ftd>

struct QuestName {
    char Text[64];
};

Ftd<QuestName> File @ 0 [[inline]];