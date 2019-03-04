
void onInit(CBlob@ this)
{
	this.getSprite().animation.frame = XORRandom(4);
	this.server_setTeamNum(-1);
	
	this.addCommandID("use");
	
	this.set_u8("equip_slot", 3);
}


void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("use"), "Use", params);
	}
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
					/*if(hold.getName() == "mat_stone"){
						if(caller.hasBlob("mat_stone", 20)){
							server_CreateBlob("axe", -1, this.getPosition());
							caller.TakeBlob("mat_stone", 20);
							this.server_Die();
						}
					}*/
					if(hold.getName() == "stick"){
						server_CreateBlob("stickfire", -1, this.getPosition());
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "axehead"){
						server_CreateBlob("axe", -1, this.getPosition());
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "hachethead"){
						server_CreateBlob("hachet", -1, this.getPosition());
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "pickhead"){
						server_CreateBlob("pick", -1, this.getPosition());
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "stone_blade"){
						server_CreateBlob("crude_knife", -1, this.getPosition());
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "hammerhead"){
						server_CreateBlob("hammer", -1, this.getPosition());
						hold.server_Die();
						this.server_Die();
					}
				}
			}
		}
	}
}