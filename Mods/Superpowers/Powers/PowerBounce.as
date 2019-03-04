#include "Logging.as";
#include "RunnerCommon.as";

// Also see RunnerMovement and FallDamage

const float JUMP_MULTIPLIER = 2.0; // change in RunnerMovement too
const float BOUNCE_ELASTICITY = 0.9;

void onInit(CBlob@ this) {
    RunnerMoveVars@ moveVars;
    if (!this.get("moveVars", @moveVars)) {
        log("onInit", "ERROR: couldn't find move vars on blob");
        return;
    }

    moveVars.jumpMaxVel *= JUMP_MULTIPLIER;
    moveVars.jumpFactor *= JUMP_MULTIPLIER;

    this.getShape().setElasticity(BOUNCE_ELASTICITY);
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}
