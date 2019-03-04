// Storage.as
void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$drop_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(23, 0); // this should be 12.0f, but inventoryButton source pos seems to differ from genericButton source pos
	this.addCommandID("drop inventory");
	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	PickupOverlap(this);
}

void PickupOverlap(CBlob@ this)
{
	if (getNet().isServer()) {
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++) {
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && blob.hasTag("material")) {
				this.server_PutInInventory(blob);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this)) {
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$drop_inventory$", Vec2f(-12, 0), this, this.getCommandID("drop inventory"), "Drop", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer()) {
		if (cmd == this.getCommandID("drop inventory")) {
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null) {
				CInventory @inv = caller.getInventory();
				if (inv !is null) {
					while (inv.getItemsCount() > 0) {
						CBlob @item = inv.getItem(0);
						caller.server_PutOutInventory(item);
					}
				}
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}