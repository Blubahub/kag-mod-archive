// Bill Blaster logic

namespace Trampoline
{
enum State
{
    folded = 0,
    idle,
    bounce
}

enum msg
{
    msg_pack = 0
}
}

const f32 trampoline_speed = 6.0f;

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ( 252.0f );
    this.set_u8("trampolineState", Trampoline::folded);
    this.set_u32("trampolineBounceTime", 0);
    this.getShape().SetOffset( Vec2f(0.0f, 4.0f) );
    this.Tag("no falldamage");
	this.getShape().SetRotationsAllowed( false );

    if (this.hasTag("start unpacked"))
    {
        this.set_u8("trampolineState", Trampoline::idle);
    }

	this.getCurrentScript().tickFrequency = 2;
}

void onTick( CBlob@ this )
{
    if (this.get_u8("trampolineState") == Trampoline::bounce)
    {
        u32 bouncetime = getGameTime() - this.get_u32("trampolineBounceTime");

        if (bouncetime > 3) //10 ticks after bouncing
        {
            this.set_u8("trampolineState", Trampoline::idle);
        }
    }
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getDistanceTo(this) > 32.0f)
		return;
	
    u8 state = this.get_u8("trampolineState");

    if (state == Trampoline::folded)
    {
        caller.CreateGenericButton( 6, Vec2f(0,-2), this, Trampoline::msg_pack, "Unpack Trampoline" );
    }
    else
    {
        if (!this.hasTag("static")) {
            caller.CreateGenericButton( 4, Vec2f(0,-2), this, Trampoline::msg_pack, "Pack up to move" );
        }
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    string dbg = "TrampolineLogic.as: Unknown command ";
    u8 state = this.get_u8("trampolineState");

    switch( cmd )
    {
    case Trampoline::msg_pack:
        if (state != Trampoline::folded)
        {
            this.set_u8("trampolineState", Trampoline::folded);
			ShootBill( this, this.getPosition() + Vec2f(0.0f,-4.0f) );

			ParticleAnimated( "Entities/Effects/Sprites/Explosion.png",
								this.getPosition() + Vec2f(10,-4),
								Vec2f(1.0,0.0f),
								1.0f, 1.0f, 
								3, 
								0.0f, true );
        }
        else
        {
            this.set_u8("trampolineState", Trampoline::idle); //logic for completion of this this is in anim script
			ShootBill( this, this.getPosition() + Vec2f(0.0f,-4.0f) );

			ParticleAnimated( "Entities/Effects/Sprites/Explosion.png",
								this.getPosition() + Vec2f(10,-4),
								Vec2f(1.0,0.0f),
								1.0f, 1.0f, 
								3, 
								0.0f, true );
        }

        break;

    default:
        dbg += cmd;
        print( dbg );
        warn( dbg );
    }
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    u8 state = this.get_u8("trampolineState");
    return (state == Trampoline::folded);
}


void ShootBill( CBlob @this, Vec2f billPos )
{
	
	
	CBitStream params;
	f32 sign = this.isFacingLeft() ? -1.0f : 1.0f;
        
    Vec2f billVel = Vec2f(sign, 0.0f) * 2.5f;
	CBlob@ bullet_bill = server_CreateBlob( "bullet_bill", this.getTeamNum(), billPos );
		if (bullet_bill !is null)
		{
			bullet_bill.setVelocity( billVel );
		}
	this.getSprite().PlaySound( CFileMatcher("/BulletShoot.ogg").getRandom(), 1.5, 1.0);
}