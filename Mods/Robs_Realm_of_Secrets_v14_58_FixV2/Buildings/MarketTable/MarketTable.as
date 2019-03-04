
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("buy");
	this.addCommandID("sell");
	this.addCommandID("retrieve");
	this.addCommandID("set_price");
	
	this.addCommandID("set_price_25");
	this.addCommandID("set_price_50");
	this.addCommandID("set_price_75");
	this.addCommandID("set_price_100");
	
	this.addCommandID("set_price_250");
	this.addCommandID("set_price_500");
	this.addCommandID("set_price_750");
	this.addCommandID("set_price_1000");
	
	this.set_s16("price",1000);
	
	this.inventoryButtonPos = Vec2f(0, -24);
	
	this.Tag("building");
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	if(!this.hasAttached()){
		CInventory@ inv = this.getInventory();
		for (int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ item = inv.getItem(i);
			const string name = item.getName();
			if(name != "mat_gold"){
				item.server_RemoveFromInventories();
				this.server_AttachTo(item, "STALL");
				break;
			}
		}
	}
}


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	bool isOwner = false;
	
	if(caller.getPlayer() !is null)
		if(this.get_string("builder") == caller.getPlayer().getUsername())
			isOwner = true;
	
	bool hasItem = this.hasAttached();
	
	if(isOwner && hasItem){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(16, Vec2f(-4,-6), this, this.getCommandID("retrieve"), "Retrieve your item.", params);
		button.SetEnabled(caller.getCarriedBlob() is null);
	}
	
	if(isOwner && !hasItem){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(19, Vec2f(-4,-6), this, this.getCommandID("sell"), "Sell an item at this table", params);
		button.SetEnabled(caller.getCarriedBlob() !is null);
	}
	
	if(isOwner){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(26, Vec2f(4,-6), this, this.getCommandID("set_price"), "Set a price", params);
	}
	
	if(hasItem){
	
		string Name = "item";
	
		if(this.getAttachments() !is null)
		if(this.getAttachments().getAttachedBlob("STALL") !is null){
			Name = this.getAttachments().getAttachedBlob("STALL").getInventoryName();
		}
	
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(25, Vec2f(0,0), this, this.getCommandID("buy"), "Buy "+Name+" for " + this.get_s16("price") + " Gold.", params);
		button.SetEnabled(caller.getBlobCount("mat_gold") >= this.get_s16("price"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sell"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null)
		{
			if(getNet().isServer()){
				CBlob @carried = caller.getCarriedBlob();
				caller.DropCarried();
				
				this.server_AttachTo(carried, "STALL");
			}
		}
	}
	
	if (cmd == this.getCommandID("retrieve"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null)
		{
			if(getNet().isServer()){
				
				if(this.getAttachments() !is null)
				if(this.getAttachments().getAttachedBlob("STALL") !is null){
					caller.server_Pickup(this.getAttachments().getAttachedBlob("STALL"));
					this.server_DetachFrom(this.getAttachments().getAttachedBlob("STALL"));
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("set_price"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null)
		{
			if(caller.isMyPlayer()){
				CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(4, 2), "Set Price (Current Price:"+this.get_s16("price")+")");
				if (menu !is null)
				{
					AddIconToken("$gold_small_icon$", "Materials.png", Vec2f(16, 16), 2);
					AddIconToken("$gold_normal_icon$", "Materials.png", Vec2f(16, 16), 2+8);
					AddIconToken("$gold_big_icon$", "Materials.png", Vec2f(16, 16), 2+16);
					AddIconToken("$gold_huge_icon$", "Materials.png", Vec2f(16, 16), 2+24);
					
					menu.AddButton("$gold_small_icon$", "25 Gold", this.getCommandID("set_price_25"));
					menu.AddButton("$gold_small_icon$", "50 Gold", this.getCommandID("set_price_50"));
					menu.AddButton("$gold_small_icon$", "75 Gold", this.getCommandID("set_price_75"));
					menu.AddButton("$gold_normal_icon$", "100 Gold", this.getCommandID("set_price_100"));
					
					menu.AddButton("$gold_normal_icon$", "250 Gold", this.getCommandID("set_price_250"));
					menu.AddButton("$gold_big_icon$", "500 Gold", this.getCommandID("set_price_500"));
					menu.AddButton("$gold_big_icon$", "750 Gold", this.getCommandID("set_price_750"));
					menu.AddButton("$gold_huge_icon$", "1000 Gold", this.getCommandID("set_price_1000"));
				}
			}
		}
	}
	
	if(cmd == this.getCommandID("set_price_25"))this.set_s16("price",25);
	if(cmd == this.getCommandID("set_price_50"))this.set_s16("price",50);
	if(cmd == this.getCommandID("set_price_75"))this.set_s16("price",75);
	if(cmd == this.getCommandID("set_price_100"))this.set_s16("price",100);
	
	if(cmd == this.getCommandID("set_price_250"))this.set_s16("price",250);
	if(cmd == this.getCommandID("set_price_500"))this.set_s16("price",500);
	if(cmd == this.getCommandID("set_price_750"))this.set_s16("price",750);
	if(cmd == this.getCommandID("set_price_1000"))this.set_s16("price",1000);
	
	if (cmd == this.getCommandID("buy"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null)
		{
			caller.TakeBlob("mat_gold", this.get_s16("price"));
			
			if(getNet().isServer()){
				
				if(this.getAttachments() !is null)
				if(this.getAttachments().getAttachedBlob("STALL") !is null){
					caller.server_Pickup(this.getAttachments().getAttachedBlob("STALL"));
					this.server_DetachFrom(this.getAttachments().getAttachedBlob("STALL"));
				}
				
				MakeMat(this, this.getPosition(), "mat_gold", this.get_s16("price"));
				
			}
			this.getSprite().PlaySound("goldsack_take.ogg");
		}
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(2);
		planks.SetOffset(Vec2f(12.0f, 0.0f));
		planks.SetRelativeZ(-100);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if(forBlob.getPlayer() !is null)
		if(this.get_string("builder") == forBlob.getPlayer().getUsername())
	return true;
	
	return false;
}