#include "FireParticle.as"
#include "Explosion.as";
#include "BombCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";

void onInit(CBlob@ this)
{
    this.server_SetTimeToDie(400.0f/30);
	this.set_f32("explosive_radius",12.0f);
	this.set_f32("explosive_damage",1.0f);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 20.0f);
	this.set_f32("map_damage_ratio", 0.4f);
	this.set_bool("map_damage_raycast", true);
	this.set_bool("explosive_teamkill", false);
	this.Tag("exploding");
}

void onInit( CSprite@ this )
{

}

void onTick( CBlob@ this )
{
    //explode on collision with map
    if (this.isOnMap()) 
    {
        this.server_Die();
    }
    else
    {
    	makeSmokeParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));
        makeFireParticle(this.getPosition() + getRandomVelocity(300.0f, 8.0f, 360.0f));
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

    return 2.0f;
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
    
    if (blob.hasTag("cannonhit"))
    {
        this.server_Die();
		//Explode(this);
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
    this.RotateAllBy(2 * vel.x, Vec2f_zero);	 		  
}

void onDie(CBlob@ this)
{
	Explode(this);// Numanator was here!
    ExplodeWithFire(this);
    this.getSprite().SetEmitSoundPaused(true);
}

void ExplodeWithFire(CBlob@ this)
{
    CMap@ map = getMap();
    if (map is null)   return;
    for (int doFire = 0; doFire <= 2 * 8; doFire += 1 * 8) //8 - tile size in pixels
    {
        int variation = 2;
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
        makeExplosionParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
        makeSmokeParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
        makeSmokeParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
        Explode(this, 64.0f, 0.5f);
    }
    this.getSprite().PlaySound("MolotovExplosion.ogg", 1.6f);
    this.getSprite().PlaySound("Glass-breaking-sound.ogg", 8.2f);
    Boom(this);
}

