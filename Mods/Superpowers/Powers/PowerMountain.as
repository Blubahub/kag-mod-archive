#include "Logging.as";

// See FleshHit for damage reduction

void onInit(CBlob@ this) {
    this.getShape().SetMass(this.getMass() * 1.5);
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}
