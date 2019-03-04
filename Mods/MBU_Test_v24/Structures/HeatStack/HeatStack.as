// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_empty);
	//this.getSprite().getConsts().accurateLighting = true;
	
	if(getNet().isServer()){
		for(int i=-1;i <2;i++)
		getMap().server_SetTile(this.getPosition()+Vec2f(0,i*8), CMap::tile_castle_back);
	}
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Upgrade");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	AddIconToken("$fireplace_icon$", "Hearth.png", Vec2f(24, 24), 0);
	AddIconToken("$smelter_icon$", "Smelter.png", Vec2f(24, 24), 0);
	AddIconToken("$chimney_icon$", "Chimney.png", Vec2f(24, 24), 0);
	AddIconToken("$generator_icon$", "Generator.png", Vec2f(24, 24), 3);
	
	{
		ShopItem@ s = addShopItem(this, "Fireplace", "$fireplace_icon$", "hearth", "Keeps you warm, generates heat and smoke.\nActs as a heat source for heat stacks above.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Chimney", "$chimney_icon$", "chimney", "Dispels smokes from the heat stacks below without taking heat.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Smelter", "$smelter_icon$", "smelter", "Smelts metals and alloys.\nRequires a heat source underneath it, for example: fire place.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Thermo-Generator", "$generator_icon$", "generator", "Converts heat into electricity when above 100C.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
		AddRequirement(s.requirements, "blob", "mat_machine_parts", "Machine Parts", 4);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
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
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();

			// open factory upgrade menu immediately
			if (item.getName() == "factory")
			{
				CBitStream factoryParams;
				factoryParams.write_netid(caller.getNetworkID());
				item.SendCommand(item.getCommandID("upgrade factory menu"), factoryParams);
			}
		}
	}
}
