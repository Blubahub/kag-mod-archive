
void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
	
	this.addCommandID("use");
}


void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this && caller.getCarriedBlob() !is null){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("use"), "Use", params);
	}
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob ){
	return forBlob.getCarriedBlob() is null;
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "metal_ore"){
						
						string name = "metal_drop";
						if(XORRandom(2) == 0)name = "metal_drop_small";
						
						CBlob @item = server_CreateBlob(name, -1, this.getPosition());
						this.server_PutInInventory(item);
						hold.server_Die();
					}
					if(hold.getName() == "mat_dirt"){
						
						int amount = hold.getQuantity();
						
						CBlob @item = server_CreateBlob("mat_sand", -1, this.getPosition());
						item.server_SetQuantity(amount);
						this.server_PutInInventory(item);
						hold.server_Die();
					}
				}
			}
		}
	}
}