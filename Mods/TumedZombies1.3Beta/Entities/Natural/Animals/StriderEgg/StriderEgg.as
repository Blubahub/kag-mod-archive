// BF_Minion2Egg script

const u8 hatchTime = 120;
const u8 SPAWN_COUNT = 1;

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

    if (getNet().isServer())
	{
			CBlob@ minion = server_CreateBlobNoInit( "Strider" );
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
