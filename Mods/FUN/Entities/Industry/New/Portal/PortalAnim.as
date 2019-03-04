#include "WARCosts.as";
#include "PortalCommon.as"
//sprite
void onInit( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ sign = this.addSpriteLayer( "sign", this.getFilename() , 40, 24, blob.getTeamNum(), blob.getSkinNum() );
	
	if(sign !is null)
	{
		Animation@ anim = sign.addAnimation( "default", 1, true );
		anim.AddFrame(1);
		sign.SetOffset(Vec2f(0,0));
		sign.SetRelativeZ( 10 );
		sign.SetVisible(false);
	}
	
	CSpriteLayer@ background = this.addSpriteLayer( "background", this.getFilename() , 40, 24, blob.getTeamNum(), blob.getSkinNum() );
	
	if(background !is null)
	{
		Animation@ anim = background.addAnimation( "default", 5, true );
		anim.AddFrame(5);
		background.SetOffset(Vec2f(0,0));
		background.SetRelativeZ( -10 );
		background.SetVisible(false);
	}
	
	CSpriteLayer@ wall = this.addSpriteLayer( "wall", this.getFilename() , 40, 24, blob.getTeamNum(), blob.getSkinNum() );
	
	if(wall !is null)
	{
		Animation@ anim = wall.addAnimation( "default", 2, true );
		anim.AddFrame(2);
		wall.SetOffset(Vec2f(0,0));
		wall.SetRelativeZ( 5 );
		wall.SetVisible(true);
	}
	
	CSpriteLayer@ portal = this.addSpriteLayer( "portal", this.getFilename() , 40, 24, blob.getTeamNum(), blob.getSkinNum() );
	
	if(portal !is null)
	{
		Animation@ anim = portal.addAnimation( "default", 3, true );
		anim.AddFrame(4);
		portal.SetOffset(Vec2f(0,0));
		portal.SetRelativeZ( -5 );
		portal.SetVisible(false);
	}
	
	CSpriteLayer@ zombiePortal = this.addSpriteLayer( "zombiePortal", this.getFilename() , 40, 24, blob.getTeamNum(), blob.getSkinNum() );
	
	if(zombiePortal !is null)
	{
		Animation@ anim = zombiePortal.addAnimation( "default", 4, true );
		anim.AddFrame(3);
		zombiePortal.SetOffset(Vec2f(0,0));
		zombiePortal.SetRelativeZ( -5 );
		zombiePortal.SetVisible(false);
	}

	this.getCurrentScript().tickFrequency = 1; // opt
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ wall = this.getSpriteLayer( "wall" );
	CSpriteLayer@ sign = this.getSpriteLayer( "sign" );
	CSpriteLayer@ portal = this.getSpriteLayer( "portal" );
	CSpriteLayer@ zombiePortal = this.getSpriteLayer( "zombiePortal" );
	if (wall is null || sign is null || portal is null || zombiePortal is null) return;
	
	if (blob.hasTag("activated")) {
		CBlob@[] list;
		if(getPortals(this.getBlob(), list))
		{
			wall.SetVisible(false);
			sign.SetVisible(false);
			portal.SetVisible(true);
			if (blob.hasTag("corrupted"))
			{
				portal.SetVisible(false);
				zombiePortal.SetVisible(true);
				zombiePortal.RotateBy(4.3435, Vec2f(Vec2f_zero.x + 1.5, Vec2f_zero.y));
			}
			else
			{
				portal.SetVisible(true);
				portal.RotateBy(4.3435, Vec2f(Vec2f_zero.x + 1.5, Vec2f_zero.y));
			}
		}
		else
		{
			sign.SetVisible(true);
			wall.SetVisible(true);
			portal.SetVisible(false);
		}
	}
}