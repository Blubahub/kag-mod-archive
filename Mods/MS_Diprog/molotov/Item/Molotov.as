#include "BombCommon.as";

void onInit( CSprite@ this )
{
    //burning sound	    
    this.SetEmitSound("MolotovBurning.ogg");
    this.SetEmitSoundVolume(5.0f);
    this.SetEmitSoundPaused(false);
}

const s32 bomb_fuse = 120;

void onInit( CBlob@ this )
{
    	this.set_u16("explosive_parent", 0);
	this.getShape().getConsts().net_threshold_multiplier = 2.0f;
	SetupBomb(this, bomb_fuse, 32.0f, 1.5f, 12.0f, 0.2f, true);
	//
	//this.Tag("activated"); // make it lit already and throwable
    this.server_SetTimeToDie(120.0f/30);
}
void onTick( CBlob@ this )
{
    //explode on collision with map
    if (this.isOnMap()) 
    {
        this.server_Die();
    }
}

//sprite update
void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    Vec2f vel = blob.getVelocity();
    this.RotateAllBy(5 * vel.x, Vec2f_zero);	 		  
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    if ((blob.hasTag("solid") || blob.hasTag("door") || ( blob.hasTag("player")) && blob.getTeamNum() != this.getTeamNum() ))
        this.server_Die();
    return false;
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
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y + doFire), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y - doFire), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + doFire, this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - doFire, this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + doFire, this.getPosition().y + doFire), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - doFire, this.getPosition().y - doFire), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + doFire, this.getPosition().y - doFire), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - doFire, this.getPosition().y + doFire), true);
    }
    this.getSprite().PlaySound("MolotovExplosion.ogg", 1.6f);
}