#include "MakeMat.as";
#include "Requirements.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50); //-60 instead of -50 so sprite layers are behind ladders
}

class SmelterItem
{
	string resultname;
	u32 resultcount;
	string title;
	u16 image_index;
	u16 heat;
	CBitStream reqs;
	bool slag;

	SmelterItem(string resultname, u32 resultcount, string title, u16 image_index, u16 heat, bool slag)
	{
		this.resultname = resultname;
		this.resultcount = resultcount;
		this.title = title;
		this.image_index = image_index;
		this.heat = heat;
		this.slag = slag;
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_empty);
	//this.getSprite().getConsts().accurateLighting = true;
	
	if(getNet().isServer()){
		for(int i=-1;i <2;i++)
		getMap().server_SetTile(this.getPosition()+Vec2f(0,i*8), CMap::tile_castle_back);
		
		for(int i=-1;i <2;i++)
		getMap().server_SetTile(this.getPosition()+Vec2f(i*8,-16), CMap::tile_castle);
		for(int i=-1;i <2;i++)
		getMap().server_SetTile(this.getPosition()+Vec2f(i*8,16), CMap::tile_castle);
	}
	
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;
	
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.Tag("builder always hit");
	
	SmelterItem[] items;
	{
		SmelterItem i("metal_bar", 1, "Smelt Metal", 1, 500, true);
		AddRequirement(i.reqs, "blob", "metal_ore", "Metal Ore", 1);
		items.push_back(i);
	}
	{
		SmelterItem i("gold_bar", 1, "Smelt Gold", 2, 250, true);
		AddRequirement(i.reqs, "blob", "gold_ore", "Gold Ore",1);
		items.push_back(i);
	}
	{
		SmelterItem i("glass_clump", 1, "Melt Glass", 3, 200, false);
		AddRequirement(i.reqs, "blob", "mat_sand", "Sand", 10);
		items.push_back(i);
	}
	{
		SmelterItem i("metal_bar", 1, "Smelt Metal", 4, 400, false);
		AddRequirement(i.reqs, "blob", "metal_drop", "Metal Ore", 1);
		items.push_back(i);
	}
	{
		SmelterItem i("gold_bar", 1, "Smelt Gold", 5, 200, false);
		AddRequirement(i.reqs, "blob", "gold_drop", "Gold Ore", 1);
		items.push_back(i);
	}
	{
		SmelterItem i("lecit_bar", 1, "Alloy Lecit", 7, 550, false);
		AddRequirement(i.reqs, "blob", "metal_bar", "Metal Bar", 1);
		AddRequirement(i.reqs, "blob", "gold_bar", "Gold Bar", 1);
		items.push_back(i);
	}
	{
		SmelterItem i("duram_bar", 1, "Smelt Duram", 6, 1000, false);
		AddRequirement(i.reqs, "blob", "metal_bar", "Metal Bars", 2);
		items.push_back(i);
	}
	{
		SmelterItem i("mat_bullet", 6, "Cast Bullets", 8, 500, false);
		AddRequirement(i.reqs, "blob", "metal_bar", "Metal Bars", 1);
		items.push_back(i);
	}
	this.set("items", items);
	
	this.set_s8("smelting",-1);
	
	this.addCommandID("set");
}

SmelterItem[] getItems(CBlob@ this)
{
	SmelterItem[] items;
	this.get("items", items);
	return items;
}

void onTick(CBlob@ this)
{
	if(this.get_s16("heat") > 0){
		this.getSprite().SetAnimation("burning");
		this.SetLight(true);
	} else {
		this.getSprite().SetAnimation("default");
		this.SetLight(false);
	}
	
	if(getNet().isServer())this.Sync("heat",true);
	
	this.setInventoryName("Fireplace\nTemperature: "+(27+this.get_s16("heat"))+"C");
	
	int smelting = this.get_s8("smelting");

	if(smelting < 0)return;
	
	SmelterItem item = getItems(this)[smelting];
	CInventory@ inv = this.getInventory();


	CBitStream missing;
	if(this.get_s16("heat") >= (item.heat-27)){
		if (hasRequirements(inv, item.reqs, missing))
		{
			if (getNet().isServer())
			{
				CBlob @taken = server_TakeRequirementsAndReturn(inv, item.reqs);
				CBlob @mat = server_CreateBlob(item.resultname, this.getTeamNum(), this.getPosition());
				mat.server_SetQuantity(item.resultcount);

				if(item.slag)if(XORRandom(2) == 0)this.server_PutInInventory(server_CreateBlob("metal_drop_dirty", this.getTeamNum(), this.getPosition()));
				
				if(taken !is null)if(taken.hasTag("light_infused"))mat.Tag("light_infused");
				
				this.server_PutInInventory(mat);
			}

			this.getSprite().PlaySound("ProduceSound.ogg");
			this.getSprite().PlaySound("BombMake.ogg");
		} else {
			this.set_s8("smelting",-1);
			if (getNet().isServer())this.Sync("smelting",true);
		}
	}
	
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	
	if (!blob.isAttached() && blob.hasTag("material"))
	{
		if (getNet().isServer()) this.server_PutInInventory(blob);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is null && forBlob.isOverlapping(this);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params ){
	if (cmd == this.getCommandID("set"))
	{
		int order = params.read_s16();
		
		this.set_s8("smelting",order);
		if (getNet().isServer())this.Sync("smelting",true);
	}
}

void onCreateInventoryMenu( CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu ){

	this.ClearGridMenusExceptInventory();
	
	Vec2f pos = gridmenu.getUpperLeftPosition()+((gridmenu.getLowerRightPosition()-gridmenu.getUpperLeftPosition())/2);

	int options = 1;
	
	for(int i = 0;i < getItems(this).length;i++){
		SmelterItem item = getItems(this)[i];
		
		CBitStream missing;
		if (hasRequirements(this.getInventory(), item.reqs, missing)) {
			options++;
		}
	}
	
	CGridMenu@ menu = CreateGridMenu(pos + Vec2f(0.0f, -(128.0f+options*24.0f)), this, Vec2f(2, options), "Temperature: "+(27+this.get_s16("heat"))+"C");
	if (menu !is null)
	{
		{
			CBitStream params;
			params.write_s16(-1);
			
			string Selected = "";
			if(this.get_s8("smelting") == -1)Selected = "Selected";
			
			CGridButton@ button = menu.AddButton("SmelterOrders"+Selected+".png", 0, Vec2f(48,24), "Cancel Orders", this.getCommandID("set"), Vec2f(2,1), params);
		}
		
		for(int i = 0;i < getItems(this).length;i++){
			SmelterItem item = getItems(this)[i];
			
			CBitStream missing;
			if (hasRequirements(this.getInventory(), item.reqs, missing)) {
				CBitStream params;
				params.write_s16(i);
				
				string Selected = "";
				if(this.get_s8("smelting") == i)Selected = "Selected";
				
				CGridButton@ button = menu.AddButton("SmelterOrders"+Selected+".png", item.image_index, Vec2f(48,24), item.title+" ("+item.heat+"C)", this.getCommandID("set"), Vec2f(2,1), params);
				if(this.get_s16("heat") < (item.heat-27)){
					if(button !is null){
						button.SetEnabled(false);
						button.hoverText = item.title + "\nNeeds Temp: "+item.heat+"C";
					}
				}
			}
		}
	}

}