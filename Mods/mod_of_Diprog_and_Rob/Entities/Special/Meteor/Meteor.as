#include "/Entities/Common/Attacks/Hitters.as";	   
#include "/Entities/Common/Attacks/LimitedAttacks.as";
#include "/Entities/Items/Explosives/Explosion.as";

const int pierce_amount = 8;

const f32 hit_amount_ground = 0.2f;
const f32 hit_amount_air = 20.0f;
const f32 hit_amount_cata = 10.0f;

void onInit( CBlob @ this )
{
    this.set_u8("launch team",255);
    this.server_setTeamNum(-1);
	this.Tag("medium weight");
    
    LimitedAttack_setup(this);
    
    this.set_u8( "blocks_pierced", 0 );
    u32[] tileOffsets;
    this.set( "tileOffsets", tileOffsets );
    
    // damage
    this.set_f32("hit dmg modifier", hit_amount_ground);
	this.set_f32("map dmg modifier", 0.0f); //handled in this script


	this.set_f32("explosive_radius",68.0f);
    this.set_f32("explosive_damage",2.0f);
    this.set_f32("map_damage_radius", 68.0f);
    this.set_f32("map_damage_ratio", 4.0f);
    this.set_bool("map_damage_raycast", true);
	this.set_u32("priming ticks", 0 );

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
}

void onTick( CBlob@ this)
{
	if (this.isOnMap())
		this.server_Die();
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null)
	{
		if (blob.hasTag("flesh"))
			this.server_Die();
	}
	
}
void onDie(CBlob@ this)
{
	Explode(this,84.0f,10.0f);
	Sound::Play( "MeteorExplosion.ogg" );
	SetScreenFlash(255, 255, 255, 255);
}