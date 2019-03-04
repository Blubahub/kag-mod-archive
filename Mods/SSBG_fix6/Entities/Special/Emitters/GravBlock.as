//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"

int openRecursion = 0;

void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.server_SetTimeToDie( 20 );
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 2.0f;
    
    //block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;	

	this.set_f32("y position", this.getPosition().y);	
}

void onTick( CBlob@ this )
{
	f32 yPos = this.get_f32("y position");

	this.getShape().SetGravityScale( 0.0f );
	
	this.setVelocity(Vec2f(-6.0f, 0));
	this.setPosition(Vec2f(this.getPosition().x, yPos));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal )
{
	if (blob !is null && blob.getPlayer() !is null)
	{
		if (blob.getVelocity().x > this.getVelocity().x)
			blob.AddForce(Vec2f(this.getVelocity().x*30.0f, 0.0f));
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
