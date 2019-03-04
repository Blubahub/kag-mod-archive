
//drowning for all characters

#include "/Entities/Common/Attacks/Hitters.as"

//config vars

const int FREQ = 5; //must be >2 or breathing at top of water breaks
const s32 default_aircount = 2000; //remember to update runnerhoverhud

void onInit(CBlob@ this)
{
	this.set_s32("food_count", default_aircount);
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = FREQ; // opt
}

void onTick(CBlob@ this)
{
	// TEMP: don't drown migrants, its annoying
	if (this.getShape().isStatic())
		return;
s32 foodcount = -1;
	if (getNet().isServer())
	{
		Vec2f pos = this.getPosition();
		foodcount = this.get_s32("food_count");

		this.getCurrentScript().tickFrequency = FREQ;
			if (foodcount > 0)
			{
				foodcount -= FREQ;
			}

			//drown damage
			if (foodcount < 10)
			{
				this.server_Hit(this, pos, Vec2f(0, 0), 1.0f, Hitters::drown, true);
				foodcount += 2000;
			}

		}
		if (foodcount != -1)
			{

	this.set_s32("food_count", foodcount);
	this.Sync("food_count", true);
	}

		
	
}

// SPRITE renders in party indicator