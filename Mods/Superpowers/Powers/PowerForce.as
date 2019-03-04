#include "Logging.as";
#include "RunnerCommon.as";

const float FORCE_RADIUS = 16.0;
const float FORCE_FORCE = 5.0;
const float MASS_FACTOR = 0.2;
const float LOW_FORCE_DISTANCE = 6.0;
const float LOW_FORCE_FACTOR = 0.2;
const int PARTICLE_FREQ = 10;

const float FORCE_ENERGY_MAX = 100;
const float FORCE_USE_PT = 1;
const float FORCE_REGEN_PT = 0.5;
const int FORCE_COOLDOWN = 60;

void onInit(CBlob@ this) {
    this.set_u32("last force particle", 0);
    this.set_f32("force energy", FORCE_ENERGY_MAX);
    this.set_u32("last force end time", 0);
    this.set_bool("using force", false);
    this.getCurrentScript().removeIfTag = "dead";
}

void onInit(CSprite@ this) {
    this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this) {
    if (this.isKeyJustPressed(key_use) && CanUseForce(this))
        this.set_bool("using force", true);
    else if (this.isKeyJustReleased(key_use) && this.get_bool("using force") ||
             this.isKeyPressed(key_use) && GetForceEnergy(this) <= 0) {
        this.set_bool("using force", false);
        this.set_u32("last force end time", getGameTime());
    }

    //log("onTick", "Force energy: " + GetForceEnergy(this));

    if (this.get_bool("using force")) {
        Vec2f forcePos = this.getAimPos();
        DoParticles(this, forcePos);
        UseEnergy(this);

        CBlob@[] blobs;
        getMap().getBlobsInRadius(forcePos, FORCE_RADIUS, blobs);
        for (int i=0; i < blobs.length; i++) {
            CBlob@ blob = blobs[i];
            if (ShouldSkipBlob(blob)) continue;

            Vec2f delta = forcePos - blob.getPosition();

            Vec2f force = delta;
            force.Normalize();
            force *= FORCE_FORCE *
                MASS_FACTOR *
                blob.getMass() *
                (delta.Length() / FORCE_RADIUS);

            //log("onTick", "Acting on " + blob.getName());
            //log("onTick", "force(" + force.x + ", " + force.y + ")");
            blob.AddForce(force);
        }
    }
    else {
        RegenEnergy(this);
    }
}

bool CanUseForce(CBlob@ this) {
    bool enoughEnergy = this.get_f32("force energy") > 0;
    bool onCooldown = getGameTime() - this.get_u32("last force end time") < FORCE_COOLDOWN;

    return enoughEnergy && !onCooldown;
}

bool ShouldSkipBlob(CBlob@ blob) {
    return blob.getShape().isStatic();
}

void DoParticles(CBlob@ this, Vec2f forcePos) {
    u32 timeSinceLastParticle = getGameTime() - this.get_u32("last force particle");
    if (timeSinceLastParticle > PARTICLE_FREQ) {
        ParticleZombieLightning(this.getPosition());
        ParticleZombieLightning(forcePos);
        this.set_u32("last force particle", getGameTime());
    }
}

float GetForceEnergy(CBlob@ this) {
    return this.get_f32("force energy");
}

void UseEnergy(CBlob@ this) {
    this.set_f32("force energy", GetForceEnergy(this) - FORCE_USE_PT);
}

void RegenEnergy(CBlob@ this) {
    float energy = GetForceEnergy(this);
    if (energy < FORCE_ENERGY_MAX) {
        this.set_f32("force energy", energy + FORCE_REGEN_PT);
    }
}

// Force energy bar
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    Vec2f pos2d = blob.getScreenPos() + Vec2f(-21, -7.5);
    Vec2f dim = Vec2f(8, 24);
    const f32 perc = GetForceEnergy(blob) / FORCE_ENERGY_MAX;
    GUI::DrawRectangle(Vec2f(pos2d.x, pos2d.y), Vec2f(pos2d.x + dim.x, pos2d.y + dim.y));
    GUI::DrawRectangle(Vec2f(pos2d.x + 2, pos2d.y + 2 + (dim.y-4)*(1-perc)),
                       Vec2f(pos2d.x + dim.x - 2, pos2d.y + dim.y - 2),
                       SColor(0xffb300b3));
}
