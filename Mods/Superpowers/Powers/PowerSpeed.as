#include "Logging.as";
#include "RunnerCommon.as";

// See RunnerMovement
void onInit(CBlob@ this) {
    RunnerMoveVars@ moveVars;
    if (!this.get("moveVars", @moveVars)) {
        log("onInit", "Blob has no moveVars!");
        return;
    }

    //moveVars.overallScale = 2.50f;
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}
