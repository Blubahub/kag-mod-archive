#include "PowersCommon.as";
#include "Logging.as";

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData) {
    if (victim is null) {
        log("onPlayerDie", "WARN: victim is null");
        return;
    }
    else if (attacker is null) {
        log("onPlayerDie", "WARN: attacker is null");
        return;
    }

    CBlob@ victimBlob = victim.getBlob();
    CBlob@ attackerBlob = attacker.getBlob();

    if (victimBlob is null) {
        log("onPlayerDie", "WARN: victim blob is null");
        return;
    }
    else if (attackerBlob is null) {
        log("onPlayerDie", "WARN: attacker blob is null");
        return;
    }
    log("onPlayerDie", victim.getUsername() + " was killed by " + attacker.getUsername() + "... transferring powers.");

    for (u8 pow = Powers::BEGIN+1; pow < Powers::END; pow++) {
        if (hasPower(victimBlob, pow) &&
            !hasPower(attackerBlob, pow))
            givePower(attackerBlob, pow);
    }
}
