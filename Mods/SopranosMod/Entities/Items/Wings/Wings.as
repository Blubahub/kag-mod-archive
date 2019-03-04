#include "Hitters.as";
#include "DecayCommon.as"

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if (attachedPoint.name == "BACK") // wings only work on your back
		attached.set_bool("hasWings", true);

	if (attachedPoint !is null)
	{
		attachedPoint.SetKeysToTake(key_taunts);
	}

	//custom wings
	if (!this.hasTag("appliedCustomSkin"))
	{
		CPlayer@ player = attached.getPlayer();
		if (player !is null)
		{
			string playersprite = "../Mods/SopranosSandbox/Entities/Items/Wings/Custom/Wings_" + player.getUsername() + ".png";
			CFileImage@ image = CFileImage(playersprite);
			if (image.getSizeInPixels() == (140*80))//wings are 140 * 80 pixels in size
			{
				this.getSprite().ReloadSprite(playersprite);
			}
			this.Tag("appliedCustomSkin");
		}
	}

	//for despawning
	this.set_bool("beenAttached", true);
}

void onInit(CBlob@ this)
{
	this.set_u32("outsideSince", getGameTime());
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (attachedPoint.name == "BACK") // wings only work on your back
		detached.set_bool("hasWings", false);
}

void onTick(CBlob@ this)
{
	//dequipping
	if (IsPointOccupied(this, "BACK"))
	{
		AttachmentPoint@ back = this.getAttachments().getAttachmentPointByName("BACK");
		if (back !is null)
		{
			CBlob@ player = back.getOccupied();
			if (player !is null)
			{
				if (back.isKeyJustReleased(key_taunts) && getNet().isServer())
				{
					player.server_DetachFrom(this);
					//if something is in pickup already, this will just be dropped (which is fine)
					player.server_AttachTo(this, "PICKUP");
					player.getShape().getConsts().collidable = true;

					//in front of player
					this.getSprite().SetRelativeZ(0.0f);
				}
			}
		}
	}
	//equipping
	else if (IsPointOccupied(this, "PICKUP"))
	{
		AttachmentPoint@ pickup = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (pickup !is null)
		{
			CBlob@ player = pickup.getOccupied();
			if (player !is null)
			{
				if (pickup.isKeyJustReleased(key_taunts) && getNet().isServer())
				{
					player.server_DetachFrom(this);
					player.server_AttachTo(this, "BACK");
					player.getShape().getConsts().collidable = false;

					//behind player
					this.getSprite().SetRelativeZ(-10.0f);
				}
			}
		}
	}
	//despawning
	else if ((this.get_bool("beenAttached") || getGameTime() > this.get_u32("outsideSince") + 500) 
		&& !dissalowDecaying(this))
	{
		this.server_Die();
	}

	//update animation
	CBlob@ player = this.getAttachments().getAttachmentPointByName("BACK").getOccupied();
	if (player !is null)
	{
		const bool inair = (!player.isOnGround() && !player.isOnLadder());
		if (player.isKeyPressed(key_down))
			this.getSprite().SetAnimation("falling");
		else if (inair)
			this.getSprite().SetAnimation("flying");
		else
			this.getSprite().SetAnimation("default");

		//behind player
		this.getSprite().SetRelativeZ(-10.0f);
	}
	else
		this.getSprite().SetAnimation("falling");
}

//returns whether or not there's a blob attached to pointName
bool IsPointOccupied(CBlob@ this, string pointName)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName(pointName);
	if (ap !is null)
	{
		CBlob@ player = ap.getOccupied();
		return player !is null;
	}

	return false;
}