// Storage.as

#include "Ally.as";
#include "EquipCommon.as"

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-60); //-60 instead of -50 so sprite layers are behind ladders
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(9, 0);
	this.addCommandID("store inventory");
	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	PickupOverlap(this);
}

void PickupOverlap(CBlob@ this)
{
	if (getNet().isServer())
	{
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && blob.hasTag("material") && blob.getName() != "mat_arrows")
			{
				this.server_PutInInventory(blob);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(checkAlly(caller.getTeamNum(),this.getTeamNum()) == Team::Ally && caller.isOverlapping(this))
	{
		CInventory @inv = caller.getInventory();
		if(inv is null) return;

		if(inv.getItemsCount() > 0)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$store_inventory$", Vec2f(-3, 0), this, this.getCommandID("store inventory"), getTranslatedString("Store"), params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
		if (cmd == this.getCommandID("store inventory"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CBlob@ carried = caller.getCarriedBlob();
				if (carried !is null)
				{
					// TODO: find a better way to check and clear blocks + blob blocks || fix the fundamental problem, blob blocks not double checking requirement prior to placement.
					if (carried.hasTag("temp blob"))
					{
						carried.server_Die();
					}
				}
				CBlob @bag = getEquippedBlob(caller,"back");
				if(bag !is null)
				if(bag.hasTag("inventory")){
					CInventory @inv = bag.getInventory();
					if (inv !is null)
					{
						while (inv.getItemsCount() > 0)
						{
							CBlob @item = inv.getItem(0);
							bag.server_PutOutInventory(item);
							this.server_PutInInventory(item);
						}
					}
				}
				
			}
		}
	}
}


bool checkName(string blobName)
{
	return (blobName == "mat_stone" || blobName == "mat_wood" || blobName == "mat_gold" || blobName == "mat_bombs");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (checkAlly(forBlob.getTeamNum(),this.getTeamNum()) == Team::Ally && forBlob.isOverlapping(this));
}