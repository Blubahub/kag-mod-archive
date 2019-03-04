#include "Logging.as";

// See KnightLogic for longer shield gliding

void onInit(CBlob@ this) {
    this.set_f32("gravity scale", 0.5);
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}
