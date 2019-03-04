#include "Explosion.as";
#include "Hitters.as";
#include "FUNHitters.as";
::double time;
::double timeSec;

const double explodingTime = 3.0;

void onInit( CBlob@ this )
{
	this.set_f32("explosive_radius",18.0f);
    this.set_f32("explosive_damage",0.2f);
    this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");  
    this.set_f32("map_damage_radius", 8.0f);
    this.set_f32("map_damage_ratio", 1.0f);
    this.set_bool("map_damage_raycast", true);
	this.set_u32("priming ticks", 0 );
    this.set_bool("explosive_teamkill", false);
	
	this.set_bool("explode", false);  
	
	this.getSprite().SetZ(200);
	
	this.set_u8("custom_hitter", FUNHitters::mega_bomb);
}
void onTick( CBlob@ this )
{
 this.set_bool("explosive_teamkill", false);

	if (this.hasTag("exploding")) 
	{
			if (timeSec > 0 && timeSec < explodingTime)
			{
				Explode(this,64.0f,10.0f);
			}
			if (timeSec > explodingTime)
			{
				time = 0;
				timeSec = 0;
				this.server_Die();
				this.Untag("exploding");
			}
	}
	time += 3.2;
	timeSec = time/100;
	this.getSprite().SetZ(200);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("activate"))
	{
		time = 0;
		timeSec = 0;
		this.Tag("exploding");

	}

}