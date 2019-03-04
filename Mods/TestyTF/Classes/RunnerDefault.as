#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
#include "FireCommon.as"
#include "Help.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.Tag("medium weight");

	//default player minimap dot - not for migrants
	if (this.getName() != "migrant")
	{
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8, 8));
	}

	this.set_s16(burn_duration , 130);

	//fix for tiny chat font
	this.SetChatBubbleFont("hud");
	this.maxChatBubbleLines = 4;

	setKnockable(this);
}

void onTick(CBlob@ this)
{
	DoKnockedUpdate(this);
	
	// print("me: " + this.getPosition().x + "; map: " + getMap().tilemapwidth * 8);
	
	// if (this.getPosition().x >= (getMap().tilemapwidth * 8) - 8)
	// {
		// u32 x = 24;
		// this.setPosition(Vec2f(x, -8 + getMap().getLandYAtX(x / 8) * 8));
		
		// getCamera().setPosition(this.getPosition());
	// }
	// else if (this.getPosition().x <= 8)
	// {
		// u32 x = (getMap().tilemapwidth * 8) - 24;
		// this.setPosition(Vec2f(x, -8 + getMap().getLandYAtX(x / 8) * 8));
		
		// getCamera().setPosition(this.getPosition());
	// } 

	// f32 rot = (getGameTime() * 0.5f % 360);
	// getCamera().setRotation(0, 0, 0);
	
	// getCamera().mousecamstyle = 2;
	// getCamera().setPosition(this.getPosition());
}

// pick up efffects
// something was picked up

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().PlaySound("/PutInInventory.ogg");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getSprite().PlaySound("/Pickup.ogg");

	if (getNet().isClient())
	{
		RemoveHelps(this, "help throw");

		if (!attached.hasTag("activated"))
			SetHelp(this, "help throw", "", "$" + attached.getName() + "$" + "Throw    $KEY_C$", "", 2);
	}

	// check if we picked a player - don't just take him out of the box
	/*if (attached.hasTag("player"))
	this.server_DetachFrom( attached ); CRASHES*/
}

// set the Z back
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.getSprite().SetZ(0.0f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob !is this && (this.hasTag("migrant") || this.hasTag("dead"));
}
