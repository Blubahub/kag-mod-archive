#include "Hitters.as"

#include "FireCommon.as"
int hidden = 0;
void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(128) > 64);
	
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = true;
    
    CShape@ shape = this.getShape();
    shape.SetOffset(Vec2f(0,-3));
    shape.AddPlatformDirection( Vec2f(0,-1), 70, false );
    shape.SetRotationsAllowed( false );
    
	this.getSprite().SetZ(-50);
    this.set_s16( burn_duration , 300 );
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);
	 hidden = 0;
}

void onTick( CBlob@ this )
{
	CBlob@[] blobsInRadius;
	CBlob@ b;
	if (this.getMap().getBlobsInRadius( this.getPosition(), 25.0f, @blobsInRadius )) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			@b = blobsInRadius[i];
			if (b.getTeamNum() != this.getTeamNum() && b.hasTag("flesh") && b !is null)
			{
				this.getSprite().SetAnimation("hidden");
				hidden = 1;
				this.getSprite().SetZ(-50);
			}
			
		}
	}
	else this.getSprite().SetAnimation("default");
}
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{	
	if (hidden == 0 && blob.isKeyPressed(key_down)) return false;
	else if (hidden == 0) return true;
	else if (hidden == 1) return false;
	else return true;
}

/*void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point )
{
	if (hidden = 1)
	{
		this.getSprite().SetAnimation("hidden");
		hidden = 1;
	}
}*/
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}
