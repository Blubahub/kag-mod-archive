//drowning for all characters

#include "Hitters.as"

//config vars

const int FREQ = 6; //must be >2 or breathing at top of water breaks
const u8 default_freezecount = 180; //6s, remember to update runnerhoverhud.as

f32 modifier_raw = 1;
f32 modifier = 1;

void onInit(CBlob@ this)
{
	this.set_u8("freeze_count", default_freezecount);
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = FREQ; // opt
}

void onTick(CBlob@ this)
{
	// TEMP: don't drown migrants, its annoying
	if (this.getShape().isStatic())
		return;

	if (getNet().isServer())
	{
		Vec2f pos = this.getPosition();

		bool freeze = false;
		const bool inwater = this.isInWater() && this.getMap().isInWater(pos + Vec2f(0.0f, -this.getRadius() * 0.66f));
	
		f32 depth = 0;
		f32 addsub = 1;
		CBlob@[] blizzards;
		getBlobsByName("blizzard", @blizzards);
		if (blizzards.length != 0)
		{
			Vec2f hit;
			getMap().rayCastSolidNoBlobs(Vec2f(pos.x, 0), pos, hit);
			depth = Maths::Clamp(pos.y - hit.y, 0.0005, 50);
			addsub = Maths::Sqrt((depth*(-0.04)+1)*(depth*(-0.04)+1));
			if(depth < 25 || inwater)
				freeze = true;
		}
		//print("addsub: "+addsub);

		u8 freezecount = this.get_u8("freeze_count");

		this.getCurrentScript().tickFrequency = FREQ;

		if (freeze)
		{
			if (freezecount >= FREQ)
			{
				freezecount -= inwater ? FREQ : FREQ*addsub;
			}

			if (freezecount < FREQ)
			{
				this.server_Hit(this, pos, Vec2f(0, 0), 0.5f, Hitters::freeze, true);
				//Sound::Play("Gurgle", pos, 2.0f);
				freezecount += 30;
			}
		}
		else
		{
			if (freezecount < default_freezecount/2)
			{
				Sound::Play("Sounds/gasp.ogg", pos, 3.0f);
				freezecount = default_freezecount/2;
			}
			else if (freezecount < default_freezecount)
			{
				freezecount += FREQ*addsub;
			}
			else
			{
				freezecount = default_freezecount;
			}
		}

		this.set_u8("freeze_count", freezecount);
		this.Sync("freeze_count", true);
	}
}

f32 Lerp(f32 v0, f32 v1, f32 t) 
{
	return v0 + t * (v1 - v0);
}

// SPRITE renders in party indicator