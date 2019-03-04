//drowning for all characters

#include "/Entities/Common/Attacks/Hitters.as"
#include "HumanoidCommon.as"

//config vars

const int FREQ = 6; //must be >2 or breathing at top of water breaks
const u8 default_aircount = 180; //6s, remember to update runnerhoverhud.as

void onInit(CBlob@ this)
{
	this.set_u8("air_count", default_aircount);
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = FREQ; // opt
}

void onTick(CBlob@ this)
{
	// TEMP: don't drown migrants, its annoying
	if (this.getShape().isStatic())
		return;
		
	bool Torso = bodyPartNeedsBreath(this,"torso") && bodyPartFunctioning(this, "torso");
	bool Main_arm = bodyPartNeedsBreath(this,"main_arm") && bodyPartFunctioning(this, "main_arm");
	bool Sub_arm = bodyPartNeedsBreath(this,"sub_arm") && bodyPartFunctioning(this, "sub_arm");
	bool Front_leg = bodyPartNeedsBreath(this,"front_leg") && bodyPartFunctioning(this, "front_leg");
	bool Back_leg = bodyPartNeedsBreath(this,"back_leg") && bodyPartFunctioning(this, "back_leg");
	
	if(!Torso && !Main_arm && !Sub_arm && !Front_leg && !Back_leg)return;

	// if (getNet().isServer())
	// {
	
	// TFlippy's Edit, re-added gas suffocation by Rob and fixed some stuff
	Vec2f pos = this.getPosition();
	bool gassed = false;
	
	CMap@ map = this.getMap();
	CBlob@[] blobs;
	if (map is null) return;
	
	map.getBlobsInRadius(this.getPosition(), 8, @blobs);

	for (int i = 0; i < blobs.length; i++)
	{
		if (blobs[i].hasTag("gas"))
		{
			gassed = true;
			break;
		}
	}
	
	const bool inWater = this.isInWater() && this.getMap().isInWater(pos + Vec2f(0.0f, -this.getRadius() * 0.66f));
	const bool canBreathe = !inWater && !gassed;
	
	const bool server = getNet().isServer();				
	const bool client = getNet().isClient();				
	
	u8 aircount = this.get_u8("air_count");

	this.getCurrentScript().tickFrequency = FREQ;

	if(!canBreathe)
	{
		if(inWater){
			if (aircount >= FREQ)
			{
				aircount -= FREQ;
			}
		} else {
			if (aircount >= FREQ/2)
			{
				aircount -= FREQ/2;
			}
		}

		//drown damage
		if (aircount < FREQ)
		{	
			if (server)
			{
				this.server_Hit(this, pos, Vec2f(0, 0), 2.0f, Hitters::drown, true);
			}
			
			if (client)
			{
				if (inWater)
				{
					Sound::Play("Gurgle", pos, 2.0f);
				}
				else if (gassed && getGameTime() >= this.get_u32("next_cough")) 
				{
					Sound::Play("cough" + XORRandom(5), pos, 2.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					this.set_u32("next_cough", getGameTime() + 70);
				}
			}
			
			aircount += 30;
		}
	}
	else
	{
		if (aircount < default_aircount/2)
		{
			if (client) Sound::Play("Sounds/gasp.ogg", pos, 3.0f);
			aircount = default_aircount/2;
		}
		else if (aircount < default_aircount)
		{
			if (this.isOnGround() || this.isOnLadder())
			{
				aircount += FREQ * 2;
			}
			else
			{
				aircount += FREQ;
			}
		}
		else
		{
			aircount = default_aircount;
		}
	}

	if (server)
	{
		this.set_u8("air_count", aircount);
		this.Sync("air_count", true);
	}
	// }
}

// SPRITE renders in party indicator