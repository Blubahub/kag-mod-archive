
//drowning for all characters

#include "/Entities/Common/Attacks/Hitters.as"

//config vars

const int FREQ = 10;
const s8 default_aircount = 60;

void onInit( CBlob@ this )
{
    this.set_s8("air_count", default_aircount);
    this.set_u8("drown_timer", 2);
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = FREQ; // opt
}

void onTick( CBlob@ this )
{
	if (this.getShape().isStatic()) // TEMP: don't drown migrants its annoying
		return;

	Vec2f pos = this.getPosition();
    const bool inwater = this.isInWater() && this.getMap().isInWater( pos + Vec2f(0.0f, -this.getRadius()*0.66f ));
    
    s8 aircount = this.get_s8("air_count");
    u8 drown_timer = this.get_u8("drown_timer");

	this.getCurrentScript().tickFrequency = FREQ;

    if (inwater)
    {
        if (aircount > -100) {
            aircount -= this.getCurrentScript().tickFrequency*0.75f;
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
				this.server_Hit( this, pos, Vec2f(0,0), 0.5f, Hitters::drown, true );
				Sound::Play( "Gurgle", pos, 2.0f );
				drown_timer++;
			}
		}
    }
    else
	{
	//	printf("ar " + aircount + " drown_timer " + drown_timer );
		if (aircount < -95 && drown_timer >= 12) {
			Sound::Play( "Sounds/gasp.ogg", pos, 3.0f );
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
			
				if (aircount == 0) {
					Sound::Play( "Sounds/gasp.ogg", pos, 3.0f );
				}

				aircount += this.getCurrentScript().tickFrequency;
			}
		}
	}


	//printf("aircount " + aircount + " drown_timer " + drown_timer );

	this.set_u8("drown_timer", drown_timer);
	this.set_s8("air_count", aircount);
}


// SPRITE

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(!blob.isMyPlayer()) return;
	
    s8 aircount = blob.get_s8("air_count");	   	
	if (aircount < 30)
    {
        SetScreenFlash( -(aircount - 30) * 1.0, 12, 0, 30 );
    }
}
