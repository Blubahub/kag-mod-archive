// Storage.as
#include "MakeMat.as";
void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(12, 0);
	this.addCommandID("store inventory");
	this.getCurrentScript().tickFrequency = 60;
}
void onTick(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	int goldnum = inv.getCount("mat_gold");
	array<string> blobname = {"mat_wood","mat_stone"}; // An array of integers with 3 elements with specific values
	int ran = XORRandom(blobname.length);
	MakeMat(this, this.getPosition(), blobname[ran], goldnum/35 + 1);
}

bool checkName(string blobName)
{
	return (blobName == "mat_stone" || blobName == "mat_wood" || blobName == "mat_gold" || blobName == "mat_bombs" || blobName == "lantern");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}