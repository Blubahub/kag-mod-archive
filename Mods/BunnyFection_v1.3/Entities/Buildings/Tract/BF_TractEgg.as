//BF_TractEgg script

#include "BF_Costs.as"
#include "BF_TractCommon.as"
#include "BF_VectorWorks.as"

const u8 hatchTime = 90;

void onInit(CBlob @ this)
{
	this.Tag( "medium weight" );
    this.getCurrentScript().tickIfTag = "activated";
	this.addCommandID( "doNothing" );
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.setVelocity( Vec2f_zero );//no throw speed
    this.getSprite().SetZ( -1.0f );
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if ( caller.getTeamNum() == this.getTeamNum() && caller.getDistanceTo(this) < 20.0f && !this.hasTag("activated") )
	{
		Vec2f closestStr = closestStruct( this );
		f32 closestDist = closestStr.Length();
		bool toTheLeft = closestStr.x < 0;
		if ( closestDist < TRACT_MAX_DISTANCE && closestDist > TRACT_MAX_DISTANCE * 0.65 )
		{
			if ( this.isOnGround() && !this.isAttached() )
				caller.CreateGenericButton( 12, Vec2f(0,-8), this, this.getCommandID("activate"), "Spawn tract");
			else
				caller.CreateGenericButton( 10, Vec2f(0,-8), this, this.getCommandID("doNothing"), "Must be hatched on ground" );			
		}
		else if ( closestDist > TRACT_MAX_DISTANCE )
		{
			u8 icon = toTheLeft ? 18 : 17;
			caller.CreateGenericButton( icon , Vec2f(0,-8), this, this.getCommandID("doNothing"), "Too Far from next Tract point!" );
		}
		else 
		{
			u8 icon = toTheLeft ? 17 : 18;
			caller.CreateGenericButton( icon, Vec2f(0,-8), this, this.getCommandID("doNothing"), "Too Close to next Tract point!" );
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("activate"))
    {
		this.Tag( "activated" );
		this.Tag( "travel tunnel" );
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
	CMap@ map = getMap();
    // effects
	this.getSprite().PlaySound( "splat.ogg" );
	
	ParticleAnimated( "/BF_GooSplat.png",
                      pos, Vec2f(0,0), 0.0f, 2.5f,
                      3,
                      -0.1f, false );

    if (getNet().isServer())
	{
		//clear ground
		for ( f32 y = pos.y; y >= pos.y - 8; y -= 8 )
			for ( f32 x = pos.x - 8; x <= pos.x + 8; x += 8 )
				map.server_DestroyTile( Vec2f( x, y ), 100.0f, this );
		
		//kill flora spawn Points
		removeMarkersInRadius( "bf_spawncarrot", pos, 64.0f );
		removeMarkersInRadius( "bf_spawnshrub", pos, 64.0f );

		//kill flora
		CBlob@[] corrupted;
		map.getBlobsInRadius( pos, 20.0f, @corrupted );
		for ( int c = 0; c < corrupted.length; c++ )
			if ( corrupted[c].hasTag( "flora" ) )
				this.server_Hit( corrupted[c], corrupted[c].getPosition(), Vec2f_zero, 15.0f, 40 );
			
		server_CreateBlob( "bf_tract", 1, pos );
		this.server_Die();
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (!this.hasTag( "activated" ) && this.getTeamNum() == byBlob.getTeamNum());
}