#include "Explosion.as";
#include "Hitters.as";

const f32 reloadingTime = 8 * 30;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
	this.SetLight( true );
	this.SetLightRadius( 18.0f );
	this.SetLightColor( SColor(255, 255, 240, 171 ) );
	this.Tag("place norotate");

	this.Tag("blocks water");

	this.set_f32("explosive_radius",18.0f);
	this.set_f32("explosive_damage",0.2f);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");  
	this.set_f32("map_damage_radius", 8.0f);
	this.set_f32("map_damage_ratio", 1.0f);
	this.set_bool("map_damage_raycast", true);
	this.set_u32("priming ticks", 0 );
	this.set_bool("explosive_teamkill", false);

	//this.set_u8("custom_hitter", FUNHitters::explosive_trap);
	this.set_bool("explode", false);  

	resetTimer(this);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{	
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	f32 time_ready = this.get_f32("time_ready");
	if (getGameTime() > time_ready)
	{
		if (blob !is null && this.getTeamNum() != blob.getTeamNum() && blob.hasTag("player"))
		{
			Explode(this,64.0f,2.0f);
			resetTimer(this);
			if (this.getSprite() !is null) this.getSprite().SetAnimation("inwater");
		}
	}

}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::bomb:
		dmg *= 0.0f;
		break;

	case Hitters::keg:
		dmg *= 0.0f;

	case Hitters::arrow:
		dmg = 0.0f;
		break;

	case Hitters::cata_stones:
		dmg *= 3.0f;
		break;
	}		
	return dmg;
}

void resetTimer(CBlob@ this)
{
	this.set_f32("time_ready", getGameTime() + reloadingTime);
}