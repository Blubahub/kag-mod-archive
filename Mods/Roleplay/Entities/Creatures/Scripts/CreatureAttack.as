// CreatureCollision.as
// @author Aphelion
// If you want to use this you must ask me. I can be contacted on the KAG forums.

#include "Hitters.as";

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
	
	if (!this.exists("attack damage"))
		this.set_f32("attack damage", 1.0f);
		
	if (!this.exists("attack hitter"))
		this.set_u8("attack hitter", Hitters::bite);
	
	if (!this.exists("attack sound"))
		this.set_string("attack sound", "Entities/Creatures/Zombie/ZombieBite");
	
	if (!this.exists("attack frequency"))
		this.set_u16("attack frequency", 30);

	this.getCurrentScript().removeIfTag	= "dead";
 	this.getCurrentScript().tickFrequency = 15;
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;
	if(this.getOverlapping(@overlapping))
	{
		for(uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ b = overlapping[i];
			if(canEat(this, b))
			{
				Bite(this, b, (b.getPosition() + this.getPosition()) * 0.5f);
			}
		}
	}
}

bool canEat(CBlob@ this, CBlob@ blob)
{
	if (this.getTeamNum() == blob.getTeamNum()) return false;

	bool facing_left = this.isFacingLeft();
	Vec2f pos = this.getPosition();
	Vec2f point1 = blob.getPosition();

	bool can_eat = facing_left ? point1.x < pos.x : point1.x > pos.x;
	if  (can_eat)
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
	}
	return can_eat;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (blob is null) return;
	
	if (canEat(this, blob))
	{
		Bite(this, blob, point1);
	}
}

void Bite(CBlob@ this, CBlob@ other, Vec2f pos)
{
	const u32 gametime = getGameTime();
	
	u32 next_attack = this.get_u32("next_attack");
	u16 attack_frequency = this.get_u16("attack frequency");
	
	if(gametime >= next_attack)
	{
		bool facing_left = this.isFacingLeft();
		Vec2f hitvel = Vec2f( facing_left ? -1.0: 1.0, 0.0f );
		this.server_Hit( other, pos, hitvel, this.get_f32("attack damage"), this.get_u8("attack hitter"), true);
		
		this.set_u32("next_attack", gametime + attack_frequency);
	}
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{		 
	if (damage > 0.0f)
	{
		this.getSprite().PlayRandomSound(this.get_string("attack sound"));
	}
}
