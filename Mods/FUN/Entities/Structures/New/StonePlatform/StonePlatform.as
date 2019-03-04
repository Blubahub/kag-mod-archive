#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(128) > 64);
	
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = true;
    
    CShape@ shape = this.getShape();
    shape.SetOffset(Vec2f(0,-3));
    shape.AddPlatformDirection( Vec2f(0,-1), 70, false );
    shape.SetRotationsAllowed( false );
    
    this.server_setTeamNum(-1); //allow anyone to break them
	
	this.Tag("blocks sword");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::sword:
		dmg = 0.0f;
		break;

	case Hitters::arrow:
		dmg = 0.0f;
		break;
	}		
	return dmg;
}
