//player grave
#include "ModName"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
}


bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return true;
}



void onTick(CBlob@ this)
{
	if(this.isOnGround())
	{
		this.getShape().SetRotationsAllowed(false);
		this.getSprite().PlaySound("FlaskOnFloor.ogg");
		this.server_Die();
	}
	else
	{
		this.getShape().SetAngleDegrees(this.getShape().getAngleDegrees() + (this.getVelocity().x + this.getVelocity().y));
	}
}

void onDie(CBlob@ this)
{
	
}
