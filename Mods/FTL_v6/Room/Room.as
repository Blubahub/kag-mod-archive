// Workbench

#include "Requirements.as"
#include "ShopCommon.as";



void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	Vec2f Pos = this.getPosition()-Vec2f(this.getSprite().getFrameWidth()/2,this.getSprite().getFrameHeight()/2);
	
	
	for(int i = 0;i < this.getSprite().getFrameWidth();i += 8)
	for(int j = 0;j < this.getSprite().getFrameHeight();j += 8){
		getMap().server_SetTile(Pos+Vec2f(i+4,j+4), CMap::tile_castle_back);
	}
	
	this.set_u16("oxygen",0);
	
	this.SetLight(true);
	this.SetLightRadius(this.getSprite().getFrameWidth()/1.5);
	
	this.Tag("room");
	
	
	
	this.set_u8("Level",1);
	this.set_u8("MaxLevel",0);
	
	this.set_f32("Power",0);
	
	this.addCommandID("upgrade");
	this.set_u8("upgrade_cost_base",25);
	this.set_u8("upgrade_cost_level",25);
	
	
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);
	this.addCommandID("shop made item");
	
	
	AddIconToken("$engine_icon$", "SystemIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$shield_icon$", "SystemIcons.png", Vec2f(32, 32), 3);
	AddIconToken("$oxy_icon$", "SystemIcons.png", Vec2f(32, 32), 9);
	AddIconToken("$cloning_icon$", "SystemIcons.png", Vec2f(32, 32), 8);
	AddIconToken("$gravity_icon$", "SystemIcons.png", Vec2f(32, 32), 10);
	AddIconToken("$eva_icon$", "SystemIcons.png", Vec2f(32, 32), 4);
	
	if(this.getName() == "onebyoneroom")
	{
		{
			ShopItem@ s = addShopItem(this, "Gravity Generator", "$gravity_icon$", "gravity_generator", "Sticks you to the floor, watch out for falling into space");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
	}

	if(this.getName() == "onebytworoom")
	{
		{
			ShopItem@ s = addShopItem(this, "Oxygen Generator", "$oxy_icon$", "oxygen_generator", "Creates oxygen to supply nearby rooms");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
	}
	
	if(this.getName() == "twobyoneroom")
	{
		{
			ShopItem@ s = addShopItem(this, "Engines", "$engine_icon$", "engine_room", "Allows FTL travel given enough time to charge");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "EVA", "$eva_icon$", "eva_room", "Provides a place to suit up for space walking");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
	}
	
	if(this.getName() == "twobytworoom")
	{
		{
			ShopItem@ s = addShopItem(this, "Shields System", "$shield_icon$", "shield_generator", "Generates a shield to protect the ship from lasers and debris");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Cloning Bay", "$cloning_icon$", "cloning_bay", "Revives dead and lost crew members");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
	}
	
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	if(this.hasTag("leaking")){
		if(this.get_u16("oxygen") > 0)this.set_u16("oxygen",this.get_u16("oxygen")-1);
	}
	
	
	if(checkForLeaks(this)){
		this.Tag("leaking");
	} else {
		this.Untag("leaking");
	}
	
	float Red = (this.get_u16("oxygen")/1000.0);
	float power = 1.0;
	if(this.get_f32("Power") < 1)power = this.get_f32("Power")*0.5+0.5;
	
	this.SetLightColor(SColor(255, 255*power, Red*255*power, Red*255*power));
	
	if(getLocalPlayerBlob() !is null){
		if(this.getTeamNum() == getLocalPlayerBlob().getTeamNum())this.SetLight(true);
		else this.SetLight(false);
	}
}

bool checkForLeaks(CBlob@ this)
{
	Vec2f Pos = this.getPosition()-Vec2f(this.getSprite().getFrameWidth()/2,this.getSprite().getFrameHeight()/2);

	for(int i = -8;i < this.getSprite().getFrameWidth()+8;i += 8)
	for(int j = -8;j < this.getSprite().getFrameHeight()+8;j += 8)
	if(i == -8 || j == -8 || j+8 >= this.getSprite().getFrameHeight()+8 || i+8 >= this.getSprite().getFrameWidth()+8){
		
		if(!getMap().isTileSolid(getMap().getTile(Pos+Vec2f(i+4,j+4)))){
		
			bool leaking = true;
			
			CBlob@[] blobs;
			
			getMap().getBlobsAtPosition(Pos+Vec2f(i+4,j+4), @blobs);
			
			for (u32 k = 0; k < blobs.length; k++)
			{
				CBlob@ blob = blobs[k];
				if(blob.getName() == "airlock")leaking = false;
			}
			
			if(leaking)return true;
		
		}
	}
	
	return false;
}

/*void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	Vec2f Pos = blob.getPosition()-Vec2f(this.getFrameWidth()/2,this.getFrameHeight()/2);
	
	GUI::DrawRectangle(getDriver().getScreenPosFromWorldPos(Pos), getDriver().getScreenPosFromWorldPos(Pos+Vec2f(this.getFrameWidth(),this.getFrameHeight())), SColor((1.0-(blob.get_u16("oxygen")/1000.0))*128.0, 235, 0, 0));
}*/

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller) && this.getTeamNum() == caller.getTeamNum())
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
		
	if(this.getName() != "onebyoneroom" &&
		this.getName() != "onebytworoom" &&
		this.getName() != "twobyoneroom" &&
		this.getName() != "twobytworoom")
			this.set_bool("shop available", false);
			
	if(this.isOverlapping(caller) && this.get_u8("Level") < this.get_u8("MaxLevel") && this.getTeamNum() == caller.getTeamNum()){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,0), this, this.getCommandID("upgrade"), "Cost to upgrade to level "+(this.get_u8("Level")+1)+": "+(this.get_u8("upgrade_cost_base")+this.get_u8("upgrade_cost_level")*this.get_u8("Level"))+" Scrap", params);
		button.SetEnabled(caller.getInventory().getCount("mat_scrap") > this.get_u8("upgrade_cost_base")+this.get_u8("upgrade_cost_level")*this.get_u8("Level"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ item = getBlobByNetworkID(params.read_netid());
		if (item !is null && caller !is null)
		{
			item.set_u16("oxygen",this.get_u16("oxygen"));
			this.getSprite().PlaySound("build_room.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
		}
	}
	
	if (cmd == this.getCommandID("upgrade"))
	{

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			if(this.get_u8("Level") < this.get_u8("MaxLevel"))
			if(caller.getInventory().getCount("mat_scrap") > this.get_u8("upgrade_cost_base")+this.get_u8("upgrade_cost_level")*this.get_u8("Level")){
			
				if(getNet().isServer()){
					caller.getInventory().server_RemoveItems("mat_scrap", this.get_u8("upgrade_cost_base")+this.get_u8("upgrade_cost_level")*this.get_u8("Level"));
					this.set_u8("Level",this.get_u8("Level")+1);
					this.Sync("Level",true);
				}
			
				this.getSprite().PlaySound("upgrade.ogg");
			}
		}
	}
}