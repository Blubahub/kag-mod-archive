#define SERVER_ONLY

#include "EquipCommon.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
}

void Take(CBlob@ this, CBlob@ item)
{
	const string blobName = item.getName();

	if((item.getDamageOwnerPlayer() is this.getPlayer()) || getGameTime() > item.get_u32("autopick time")){
		CInventory @inv = this.getInventory();

		if(inv !is null)
		for(int i = 0;i < inv.getItemsCount();i++){
			CBlob @blob = inv.getItem(i);
			if(blob !is null)
			if(blob.hasBlob(blobName, 1)){
				CInventory @bag = blob.getInventory();
				if(bag !is null){
					if(bag.canPutItem(item)){
						if(getNet().isServer())blob.server_PutInInventory(item);
						Sound::Play("PutInInventory.ogg");
					}
				}
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	Take(this, blob);
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			{
				if (blob.getShape().vellen > 1.0f)
				{
					continue;
				}

				Take(this, blob);
			}
		}
	}
}

// make ignore collision time a lot longer for auto-pickup stuff
void IgnoreCollisionLonger(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("dead"))
	{
		return;
	}

	const string blobName = blob.getName();

	blob.set_u32("autopick time", getGameTime() +  getTicksASecond() * 7);
	blob.SetDamageOwnerPlayer(blob.getPlayer());
}


void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	IgnoreCollisionLonger(this, detached);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	IgnoreCollisionLonger(this, blob);
}
