#include "Logging.as";

// See RunnerMovement
void onTick(CBlob@ this) {
    if (this.isOnGround() || this.isInWater()) {
        this.set_s8("triple jump count", 2);
    }

    if (this.isKeyJustPressed(key_up)) {
        decJumpCount(this);
    }
}

void decJumpCount(CBlob@ this) {
        this.set_s8("triple jump count", this.get_s8("triple jump count") - 1);
}
