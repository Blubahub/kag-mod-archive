#include "Logging.as";

void onTick(CBlob@ this) {
    if (this.isOnWall() || this.isOnCeiling())
        this.getShape().getVars().onladder = true;
}
