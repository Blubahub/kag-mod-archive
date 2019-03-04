
//drowning for all characters

#include "/Entities/Common/Attacks/Hitters.as"

//config vars

const int FREQ = 10;
const s8 default_aircount = 60;

//is the air value sinking? defined by cave story pack
bool loosingAir = false;
s8 lastAir = 0;

void onInit(CBlob@ this)
{
	this.set_s8("air_count", default_aircount);
	this.set_u8("drown_timer", 2);
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = FREQ; // opt
}

void onTick(CBlob@ this)
{
	if (this.getShape().isStatic()) // TEMP: don't drown migrants its annoying
		return;

	Vec2f pos = this.getPosition();
	const bool inwater = this.isInWater() && this.getMap().isInWater(pos + Vec2f(0.0f, -this.getRadius() * 0.66f));

	s8 aircount = this.get_s8("air_count");
	u8 drown_timer = this.get_u8("drown_timer");

	loosingAir = lastAir > aircount || (0.63 * aircount + 62.5 <= 0 && inwater);
	lastAir = aircount;

	this.getCurrentScript().tickFrequency = FREQ;

	if (inwater)
	{
		if (aircount > -100)
		{
			aircount -= this.getCurrentScript().tickFrequency * 0.75f;
		}

		//drown damage
		if (aircount < -90)
		{
			if (drown_timer == 0)
				drown_timer = 2;

			if (this.getCurrentScript().tickFrequency == 1)
			{
				if (getGameTime() % FREQ == 0)
					drown_timer++;
			}
			else
				drown_timer++;

			if (drown_timer % 5 == 0)
			{
				this.server_Hit(this, pos, Vec2f(0, 0), 0.5f, Hitters::drown, true);
				Sound::Play("Gurgle", pos, 2.0f);
				drown_timer++;
			}
		}
	}
	else
	{
		//	printf("ar " + aircount + " drown_timer " + drown_timer );
		if (aircount < -95 && drown_timer >= 12)
		{
			Sound::Play("Sounds/gasp.ogg", pos, 3.0f);
		}

		//if (this.isOnGround() || this.isOnLadder())
		{
			if (drown_timer > 0)
			{
				if (drown_timer > 10)
					drown_timer = 10;
				drown_timer--;
			}
			else if (aircount < default_aircount)
			{
				drown_timer = 0;

				if (aircount == 0)
				{
					Sound::Play("Sounds/gasp.ogg", pos, 3.0f);
				}

				aircount += this.getCurrentScript().tickFrequency;

				// detach picked up drowning man
				CBlob@ blob = this.getCarriedBlob();
				if (blob !is null && blob.hasTag("player"))
					this.server_DetachFrom(blob);
			}
		}
	}


	//printf("aircount " + aircount + " drown_timer " + drown_timer );

	this.set_u8("drown_timer", drown_timer);
	this.set_s8("air_count", aircount);
}

// picked drowning man

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	if (blob.getTeamNum() == this.getTeamNum() && blob.hasTag("player") && !blob.hasTag("dead") && this.getCarriedBlob() is null)
	{
		const u8 drown_timer = this.get_u8("drown_timer");
		const u8 blob_drown_timer = blob.get_u8("drown_timer");
		if (blob_drown_timer > 31 && drown_timer < 19)
		{
			this.server_Pickup(blob);
		}
	}
}


// SPRITE

void onRender(CSprite@ this)
{
	string countNumbers = "Entities/Common/GUI/HealthCountNumbers.png";
	Vec2f aircountPosition = Vec2f(Vec2f(getScreenWidth() / 2, getScreenHeight() / 2 - 128));

	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer()) return;

	//s8 aircount = blob.get_s8("air_count");
	s8 csCount = 0.63 * blob.get_s8("air_count") + 62.5;

	if (csCount < 0)
		csCount = 0;
	else if (csCount > 100)
		csCount = 100;
	
	if (csCount < 100)
	{
		GUI::DrawIcon("Entities/Common/GUI/AirText.png", loosingAir && getGameTime() / 5 % 3 != 0?0:1,
							 Vec2f(64, 16), aircountPosition + Vec2f(-128 - 64, 0));
		GUI::DrawIcon(countNumbers, (csCount - csCount % 10) / 10, Vec2f(16, 17), aircountPosition + Vec2f(64, 0));
		GUI::DrawIcon(countNumbers, csCount % 10, Vec2f(16, 17), aircountPosition + Vec2f(32 + 64, 0));
		//GUI::DrawText("" + csCount, Vec2f(getScreenWidth() / 2, getScreenHeight() / 2), SColor(255, 255, 255, 255));
	}
}
