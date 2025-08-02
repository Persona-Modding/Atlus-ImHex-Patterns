#include <atlus/p4g/enums.hexpat>
#include <atlus/common/ftd.hexpat>

/**
    The list of skills that a party member will learn when you go on a scooter ride with them, in the order they are given.
    Note that BattleSkill::Attack (0) means no skill is learned on that trip.
    
    Party members in this array are:
    - 0: Yosuke
    - 1: Chie
    - 2: Yukiko
    - 3: Rise
    - 4: Kanji
    - 5: Naoto
    - 6: Teddie
*/
struct LearnedSkills {
    BattleSkill Skills[10];
};

Ftd<LearnedSkills> File @ 0 [[inline]];