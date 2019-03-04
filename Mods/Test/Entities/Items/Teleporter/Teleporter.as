// Princess brain

#include "Hitters.as";
#include "Knocked.as";

const f32 radius = 96.0f;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 3;
	this.getCurrentScript().runFlags |= Script::tick_not_ininventory | Script::tick_not_attached;
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("fieldgenerator_loop.ogg");
	this.SetEmitSoundVolume(0.0f);
	this.SetEmitSoundSpeed(0.0f);
	
	this.SetEmitSoundPaused(false);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && GetFuel(this) == 0;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CBlob@ carried = forBlob.getCarriedBlob();
	return (carried is null ? true : carried.getConfig() == "mat_mithril");
}

u8 GetFuel(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) return inv.getItem(0).getQuantity();
	}
	
	return 0;
}

void SetFuel(CBlob@ this, u8 amount)
{
	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) inv.getItem(0).server_SetQuantity(amount);
	}
}

void onTick(CBlob@ this)
{	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
	{
		
	}
}