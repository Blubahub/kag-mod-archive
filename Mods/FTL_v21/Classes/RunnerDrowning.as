//drowning for all characters

#include "/Entities/Common/Attacks/Hitters.as"

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

	if (getNet().isServer())
	{
		Vec2f pos = this.getPosition();
		bool hasAir = false;

		CBlob@[] blobs;
	
		getBlobsByTag("room", blobs);
		
		for (u32 k = 0; k < blobs.length; k++)
		{
			CBlob@ blob = blobs[k];
			if(Maths::Sqrt(Maths::Pow(this.getPosition().x-blob.getPosition().x, 2)+Maths::Pow(this.getPosition().y-blob.getPosition().y, 2)) < 20){
				if(blob.get_u16("oxygen") > 100){
					hasAir = true;
					blob.set_u16("oxygen",blob.get_u16("oxygen")-1);
				}
			}
		}
		
		u8 aircount = this.get_u8("air_count");
		
		if(!hasAir)
		if(this.hasTag("space_suit")){
			hasAir = true;
			this.set_u16("air_tank",this.get_u16("air_tank")-1);
			if(this.get_u16("air_tank") < 1){
				this.Untag("space_suit");
				if(getNet().isServer()){
					this.Sync("space_suit",true);
				}
			}
			if(getNet().isServer()){
				this.Sync("air_tank",true);
			}
		}

		this.getCurrentScript().tickFrequency = FREQ;

		if (!hasAir)
		{
			if (aircount >= FREQ)
			{
				aircount -= FREQ;
			}

			//drown damage
			if (aircount < FREQ)
			{
				this.server_Hit(this, pos, Vec2f(0, 0), 0.5f, Hitters::drown, true);
				Sound::Play("Gurgle", pos, 2.0f);
				aircount += 30;
			}
		}
		else
		{
			if (aircount < default_aircount/2)
			{
				Sound::Play("Sounds/gasp.ogg", pos, 3.0f);
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

		this.set_u8("air_count", aircount);
		this.Sync("air_count", true);
	}
}

// SPRITE renders in party indicator