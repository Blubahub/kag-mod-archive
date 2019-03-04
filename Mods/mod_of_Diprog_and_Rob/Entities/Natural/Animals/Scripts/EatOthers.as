
// eating other things
// setup: set in properties a string[] 

#include "Hitters.as";
#include "FUNHitters.as";

void onInit(CBlob@ this)
{
	if (!this.exists("names to eat"))
	{
		string[] names;
		this.set("names to eat", names);
	}
	
	if (!this.exists("names not to eat"))
	{
		string[] names = {this.getName()}; //default dont eat same type
		this.set("names not to eat", names);
	}
	
	if (!this.exists("tags to eat"))
	{
		string[] tags;
		this.set("tags to eat", tags);
	}
	
	if (!this.exists("bite damage"))
		this.set_f32("bite damage", 1.0f);
		
	if (!this.exists("bite hitter"))
	{
		if (this.getConfig() == "bison") this.set_u8("bite hitter", FUNHitters::bison);
		else if (this.getConfig() == "shark") this.set_u8("bite hitter", FUNHitters::shark);
		else this.set_u8("bite hitter", Hitters::bite);
	}
		
		
	if (!this.exists("bite sound"))
		this.set_string("bite sound", "ZombieBite");

	this.getCurrentScript().removeIfTag	= "dead";
 
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (blob is null) return;
	bool facing_left = this.isFacingLeft();
	Vec2f pos = this.getPosition();
	
	//TODO: mouth position & radius
	bool can_eat = facing_left ? point1.x < pos.x : point1.x > pos.x;
	
	if (can_eat)
	{
		string[]@ names;
		this.get("names to eat", @names);
		
		string[]@ notnames;
		this.get("names not to eat", @notnames);
		
		string name = blob.getName();
		
		uint len = names.length;
		bool found_in_names = false;
		for(uint i = 0; i < len; ++i)
			if(names[i] == name)
			{
				found_in_names = true;
				break;
			}
		
		len = notnames.length;
		bool found_in_notnames = false;
		for(uint i = 0; i < len; ++i)
			if(notnames[i] == name)
			{
				found_in_notnames = true;
				break;
			}
			
		can_eat = found_in_names && !found_in_notnames;
		
		if (!can_eat && !found_in_notnames) //find a tag
		{
			string[]@ tags;
			this.get("tags to eat", @tags);
			for (uint step = 0; step < tags.length; ++step)
			{
				if (blob.hasTag(tags[step]))
				{
					can_eat = true;
					break;
				}
			}
		}
		
		if (can_eat)
		{
			Vec2f hitvel = Vec2f( facing_left ? -1.0: 1.0, 0.0f );
			this.server_Hit( blob, point1, hitvel, this.get_f32("bite damage"), this.get_u8("bite hitter"), true);
			
		}
	}
}
			  
void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{		 
	if (damage > 0.0f)
	{
		this.getSprite().PlayRandomSound( this.get_string("bite sound") );
	}
}
