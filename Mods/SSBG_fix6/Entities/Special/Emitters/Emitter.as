//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"

int openRecursion = 0;

void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.Tag("place norotate");
    
    //block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;		 
}

void onTick( CBlob@ this )
{
	this.getShape().SetGravityScale( 0.0f );
	if (this.getTouchingCount() == 0)
	{
		CBlob@ blob = server_CreateBlob("grav_block", this.getTeamNum(), this.getPosition());
	}
}

//TODO: fix flags sync and hitting
/*void onDie( CBlob@ this )
{
	SetSolidFlag(this, false);
}*/

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
