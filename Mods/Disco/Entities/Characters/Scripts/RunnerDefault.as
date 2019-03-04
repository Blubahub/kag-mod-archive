#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
#include "FireCommon.as"
#include "Help.as"

//CTF REMAKE COMMENT: ALL OF THIS IS VANILLA CODE UNTIL THE / SPAM EXCEPT FOR LINE 32 (CALLING CUSTOM FUNCTION)

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
	setSpawnLocation(this);
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
	return this.hasTag("migrant") || this.hasTag("dead");
}


/////////////////////////////////////////////////////////////////////////////// CUSTOM CODE STARTS HERE

const string[] spawns = { "newtent", "ballista" };

void setSpawnLocation(CBlob@ this)
{
	CBlob@[] overlapping;
	this.getOverlapping(@overlapping);

	for (int i = 0; i < overlapping.length(); i++)
	{
		for (int j = 0; j < spawns.length(); j++)
		{
			if (overlapping[i].getName() == spawns[j] && this.getPlayer() != null && overlapping[i].getTeamNum() == this.getTeamNum())
			{
				this.getPlayer().set_u16("spawn point network id", overlapping[i].getNetworkID());
			}
		}
	}
}