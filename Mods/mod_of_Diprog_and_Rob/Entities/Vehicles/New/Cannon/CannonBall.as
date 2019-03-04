//Rock logic
#include "Explosion.as";
#include "/Entities/Common/Attacks/Hitters.as";
#include "FUNHitters.as";
// defines amount of damage as well as maximum separate hits
// - in terms of this's health. see config
const f32 ROCK_DAMAGE = 1.0f;

u32 g_lastplayedsound = 0;

//sprite functions

//blob functions
void onInit( CBlob@ this )
{
    this.server_SetTimeToDie( 12 );
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;
	if (this.getSprite() !is null) this.getSprite().SetRelativeZ( -50.0f );
	
	this.set_f32("explosive_radius",18.0f);
    this.set_f32("explosive_damage",0.2f);
    this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");  
    this.set_f32("map_damage_radius", 8.0f);
    this.set_f32("map_damage_ratio", 1.0f);
    this.set_bool("map_damage_raycast", true);
	this.set_u32("priming ticks", 0 );
    this.set_bool("explosive_teamkill", false);
	
	this.set_u8("custom_hitter", FUNHitters::cannon);
	
}
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}

void onTick( CBlob@ this )
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	Tile tile = map.getTile( pos );	 

	if( map.isTileSolid(tile))
	{
		this.server_Die();
	}
	if ( map.isTileBackgroundNonEmpty( tile ) )
	{				
		if (map.getSectorAtPosition( pos, "no build") !is null) {
			return;
		}
		
		map.server_DestroyTile( pos, 5.0f, this );
	}
}	
void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (blob !is null && blob.getTeamNum() != this.getTeamNum())
	{
		this.server_Die();
	}
}
void HitMap(CBlob@ this, CMap@ map, Vec2f tilepos, bool ricochet)
{
	TileType t = map.getTile(tilepos).type;
				
	if(map.isTileCastle(t) || map.isTileWood(t))
	{
		if (map.getSectorAtPosition( tilepos, "no build") is null) {
			this.server_Die();
		}
	}
	
}
void onDie(CBlob@ this)
{
	Explode(this,32.0f,4.0f);
	this.getSprite().Gib();
}
