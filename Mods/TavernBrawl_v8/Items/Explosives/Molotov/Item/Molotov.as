#include "FireParticle.as"
#include "Explosion.as";
#include "BombCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";

void onInit(CBlob@ this)
{
    this.server_SetTimeToDie(400.0f/30);
}

void onInit( CSprite@ this )
{
    //burning sound	    
    this.SetEmitSound("MolotovBurning.ogg");
    this.SetEmitSoundVolume(5.0f);
    this.SetEmitSoundPaused(false);
}

void onTick( CBlob@ this )
{
    //explode on collision with map
    if (this.isOnMap()) 
    {
        this.server_Die();
        Explode(this);
    }
    else
    {
        if (XORRandom(2) == 0)
        {
            makeSmokeParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));
            makeFireParticle(this.getPosition() + getRandomVelocity(300.0f, 8.0f, 360.0f));

        }
    }
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    if (this is hitterBlob)
    {
        this.set_s32("bomb_timer", 0);
    }

    if (isExplosionHitter(customData))
    {
        return damage; //chain explosion
    }

    return 0.0f;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    //special logic colliding with players
    if (blob.hasTag("player"))
    {
        const u8 hitter = this.get_u8("custom_hitter");

        //all water bombs collide with enemies
        if (hitter == Hitters::water)
            return blob.getTeamNum() != this.getTeamNum();

        //collide with shielded enemies
        return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
    }

    string name = blob.getName();

    if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart")
    {
        return false;
    }

    return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
    if (!solid)
    {
        return;
    }

    const f32 vellen = this.getOldVelocity().Length();
    const u8 hitter = this.get_u8("custom_hitter");
    if (vellen > 1.7f)
    {
        Sound::Play(!isExplosionHitter(hitter) ? "/WaterBubble" :
                    "/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f));
    }

    if (!isExplosionHitter(hitter) && !this.isAttached())
    {
        Boom(this);
        if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
        {
            this.Tag("_hit_water");
            Vec2f pos = this.getPosition();
            blob.Tag("force_knock");
        }
    }
}

void Explode(CBlob@ this)
{
    if (this.hasTag("exploding"))
    {
        if (this.exists("explosive_radius") && this.exists("explosive_damage"))
        {
            Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
        }
        else //default "bomb" explosion
        {
            Explode(this, 64.0f, 3.0f);
        }
        this.Untag("exploding");
    }

    BombFuseOff(this);
    this.getCurrentScript().runFlags |= Script::remove_after_this;
    if (this.getHealth() < 0.5f || this.hasTag("player"))
    {
        this.getSprite().Gib();
        this.server_Die();
    }
    else
    {
        this.server_Hit(this, this.getPosition(), Vec2f_zero, this.get_f32("explosive_damage") * 0.5f, 0);
    }
}

//sprite update
void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    Vec2f vel = blob.getVelocity();
    this.RotateAllBy(9 * vel.x, Vec2f_zero);	 		  
}

void onDie(CBlob@ this)
{
    ExplodeWithFire(this);
    this.getSprite().SetEmitSoundPaused(true);
}

void ExplodeWithFire(CBlob@ this)
{
    CMap@ map = getMap();
    if (map is null)   return;
    for (int doFire = 0; doFire <= 2 * 8; doFire += 1 * 8) //8 - tile size in pixels
    {
        int variation = 4;
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        variation = 3;
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        variation = 2;
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        makeExplosionParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
        makeExplosionParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
        makeSmokeParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
        makeSmokeParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
        Explode(this, 64.0f, 0.5f);
    }
    this.getSprite().PlaySound("MolotovExplosion.ogg", 1.6f);
    this.getSprite().PlaySound("Glass-breaking-sound.ogg", 8.2f);
    Boom(this);
}

