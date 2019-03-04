#include "Logging.as";
#include "Hitters.as";

const int DRAIN_FREQUENCY = 15;
const float DRAIN_DAMAGE = 0.25f;
const float DRAIN_RADIUS = 6*8.0;

void onInit(CBlob@ this) {
    this.getCurrentScript().tickFrequency = DRAIN_FREQUENCY;
    this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this) {
    CBlob@[] nearbyBlobs;

    getMap().getBlobsInRadius(this.getPosition(), DRAIN_RADIUS, nearbyBlobs);
    for (int i=0; i < nearbyBlobs.length; i++) {
        CBlob@ blob = nearbyBlobs[i];
        if (blob.hasTag("flesh") && blob.getTeamNum() != this.getTeamNum()) {
            this.server_Hit(blob, this.getPosition(), Vec2f(0,0), DRAIN_DAMAGE, Hitters::bite);
        }
    }
}
