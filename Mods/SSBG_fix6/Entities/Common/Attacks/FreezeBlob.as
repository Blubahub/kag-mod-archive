// Knockback on hit - put before any damaging things but after any scalers
#include "Hitters.as"
#include "Knocked_SSBG.as"

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.set_u32( "hit time", getGameTime() );
	if (hitterBlob.getPlayer() !is null)
		this.set_string("attacker", hitterBlob.getPlayer().getUsername());
	
	f32 currentHealth = this.getHealth();
	f32 initialHealth = this.getInitialHealth();
	f32 fractionHealth = (initialHealth - currentHealth)/initialHealth;
	
    f32 x_side = 0.0f;
    f32 y_side = 0.0f;
    //if (hitterBlob !is null)
    {
        //Vec2f dif = hitterBlob.getPosition() - this.getPosition();
        if (velocity.x > 0.7) {
            x_side = 1.0f;
        }
        else if (velocity.x < -0.7) {
            x_side = -1.0f;
        }

        if (velocity.y > 0.5) {
            y_side = 1.0f;
        }
        else {
            y_side = -1.0f;
        }
    }
    f32 scale = 1.0f + 40.0f * fractionHealth;

    //scale per hitter
    switch(customData)
    {
    case Hitters::fall:
		scale = 0.0f; break;
		
    case Hitters::drown:
    case Hitters::burn:
		scale = 4.0f; break;
		
    case Hitters::crush:
    case Hitters::spikes:
        scale = 2.0f + 40.0f * fractionHealth; break;

    case Hitters::arrow:
        scale = 40.0f * fractionHealth; break;
	
	case Hitters::keg:
        scale = 2.0f + 50.0f * fractionHealth; break;

    default: break;
    }

    Vec2f f( x_side, y_side );

    if (damage > 0.125f) 
	{	
		this.set_Vec2f( "force", f * 40.0f * scale * Maths::Log(2.0f*(10.0f+(damage*2.0f))));
		
		this.set_u8("knocked", scale*2.0f );
		this.set_u8( "frozen", 1 );
		
		if (scale > 15){
			Sound::Play("/Homerun.ogg", worldPoint);
		}
    }

    return damage; //damage not affected
}

void onTick( CBlob@ this )
{
	if (this.get_u8( "frozen" ) == 1)
	{
		this.setVelocity( Vec2f(0, 0));
		if ( ( getPlayerByUsername( this.get_string("attacker") ) ) !is null 
				&& ( !getPlayerByUsername( this.get_string("attacker") ).isBot() ))
			{
			getPlayerByUsername( this.get_string("attacker") ).getBlob().setVelocity( Vec2f(0, 0));
			}
	
		const u32 gametime = getGameTime();
		u32 hitTime = this.get_u32("hit time");
		int ticksTillUnfreeze = this.get_u8("knocked")*0.5;
		int diff = gametime - hitTime;
		if (diff > ticksTillUnfreeze)
		{
			this.AddForce( this.get_Vec2f("force") );
		
			this.set_u8( "frozen", 0 );
		}
	}
}	
