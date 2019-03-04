
//drowning for all characters

#include "/Entities/Common/Attacks/Hitters.as"

//config vars

const int FREQ = 5; //must be >2 or breathing at top of water breaks
const s8 default_aircount = 60; //remember to update runnerhoverhud

void onInit(CBlob@ this)
{
	this.set_s8("air_count", default_aircount);
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = FREQ; // opt
}

void onTick(CBlob@ this)
{
	// TEMP: don't drown migrants, its annoying
	if (this.getShape().isStatic())
		return;
		
	if(this.get_s16("cant_drown") > 0)return;

	if (getNet().isServer())
	{
		Vec2f pos = this.getPosition();
		const bool inwater = this.isInWater() && this.getMap().isInWater(pos + Vec2f(0.0f, -this.getRadius() * 0.66f));

		s8 aircount = this.get_s8("air_count");

		this.getCurrentScript().tickFrequency = FREQ;

		if (inwater ^^ (this.get_s16("cant_breathe_air") >0))
		{
			if (aircount > -100)
			{
				aircount -= FREQ;
			}

			//drown damage
			if (aircount < -90)
			{
				this.server_Hit(this, pos, Vec2f(0, 0), 0.5f, Hitters::drown, true);
				Sound::Play("Gurgle", pos, 2.0f);
				aircount += 30;
			}
		}
		else
		{
			if (aircount < -60)
			{
				Sound::Play("Sounds/gasp.ogg", pos, 3.0f);
				aircount = -50;
			}

			if (aircount < default_aircount)
			{
				if (this.isOnGround() || this.isOnLadder())
				{
					aircount += FREQ * 2;
				}
				else
				{
					aircount += FREQ * 0.5f;
				}
			}
			else
			{
				aircount = default_aircount;
			}
		}

		this.set_s8("air_count", aircount);
		this.Sync("air_count", true);
	}
}

// SPRITE renders in party indicator