﻿// A script by TFlippy

void onInit(CSprite@ this)
{
	this.SetZ(-60);
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 30;
	this.Tag("builder always hit");
	
	this.server_setTeamNum(-1);
	
	this.set_string("Owner", "");
	this.addCommandID("sv_setowner");
	this.addCommandID("sv_store");
}

void onTick(CBlob@ this)
{
	PickupOverlap(this);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	if (caller.isOverlapping(this) && this.get_string("Owner") == "")
	{	
		CButton@ buttonOwner = caller.CreateGenericButton(9, Vec2f(0, 0), this, this.getCommandID("sv_setowner"), "Claim", params);
	}
	
	if(caller.getPlayer().getUsername() == this.get_string("Owner"))
	{
		CInventory @inv = caller.getInventory();
		if(inv is null) return;

		if(inv.getItemsCount() > 0)
		{
			params.write_u16(caller.getNetworkID());
			CButton@ buttonOwner = caller.CreateGenericButton(9, Vec2f(0, 8), this, this.getCommandID("sv_store"), "Store", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
		if (cmd == this.getCommandID("sv_setowner"))
		{
			if (this.get_string("Owner") != "") return;
		
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			CPlayer@ player = caller.getPlayer();

			this.set_string("Owner", player.getUsername());
			this.server_setTeamNum(player.getTeamNum());
			this.Sync("Owner", true);

			// print("Set owner to " + this.get_string("Owner") + "; Team: " + this.getTeamNum());
		}
		
		if (cmd == this.getCommandID("sv_store"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CInventory @inv = caller.getInventory();
				if (caller.getConfig() == "builder")
				{
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
					{
						if (carried.hasTag("temp blob"))
						{
							carried.server_Die();
						}
					}
				}
				if (inv !is null)
				{
					while (inv.getItemsCount() > 0)
					{
						CBlob @item = inv.getItem(0);
						caller.server_PutOutInventory(item);
						this.server_PutInInventory(item);
					}
				}
			}
		}
	}
}

void PickupOverlap(CBlob@ this)
{

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage * (hitterBlob.getPlayer().getUsername() == this.get_string("Owner") ? 4.0f : 1.0f);
}

void onDie(CBlob@ this)
{
	if (this.get_string("Owner") != "") client_AddToChat("" + this.get_string("Owner") + "'s Personal Safe has been destroyed!");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getPlayer().getUsername() == this.get_string("Owner");
}