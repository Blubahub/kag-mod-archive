// BF_Minion1Egg script

const u8 hatchTime = 60;
const u8 SPAWN_COUNT = 3;

void onInit(CBlob @ this)
{
    this.getCurrentScript().tickIfTag = "activated";
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
    this.getSprite().SetZ( -1.0f );
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if ( caller.getTeamNum() == this.getTeamNum() && caller.getDistanceTo(this) < 10.0f && !this.hasTag("activated") )
		caller.CreateGenericButton( 12, Vec2f(0,-8), this, this.getCommandID("activate"), "Hatch eggs");
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("activate"))
    {
		this.Tag( "activated" );
        CSprite@ sprite = this.getSprite();
        sprite.SetAnimation("hatching");
		sprite.PlaySound("/branches1.ogg", 1.5f, 0.65f);
        this.SetLightRadius(5.0f);
        this.SetLightColor(SColor(255, 128, 200, 0 ));
        this.SetLight(true);
    }
}

void onTick(CBlob@ this)
{
    if (!this.exists("hatchTimer"))
    {
        this.set_s32("hatchTimer", getGameTime() + hatchTime);
        //print("Initialize     : hatchTimer = " + this.get_s32("hatchTimer"));
    }
    s32 Timer = this.get_s32("hatchTimer") - getGameTime();
   // print("Countdown      :     Timer = " + Timer);
    if (Timer <= 0)
    {
		Hatch(this);
		//print("Explode        :     Timer = " + Timer);
    }
}

void Hatch(CBlob@ this)
{
	Vec2f pos = this.getPosition();
    // effects
	this.getSprite().PlaySound( "splat.ogg" );
	
	ParticleAnimated( "/BF_GooSplat.png",
                      pos, Vec2f(0,0), 0.0f, 1.5f,
                      3,
                      -0.1f, false );

    if (getNet().isServer())
	{
		u16 owner = this.get_netid( "owner" );
		for ( u8 i = 0; i < SPAWN_COUNT; i++ )
		{
			CBlob@ minion = server_CreateBlobNoInit( "bf_minion1" );
			if ( minion !is null )
			{
				minion.server_setTeamNum( this.getTeamNum() );
				minion.setPosition( pos );
				minion.set_netid( "owner", owner );
				minion.Init();
			}
		}	
	
		this.server_Die();
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (this.getTeamNum() == byBlob.getTeamNum());
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return !this.hasTag("activated");
}