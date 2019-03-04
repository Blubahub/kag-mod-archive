void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue
}

void onInit(CBlob@ this)
{
	this.addCommandID("build");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("build"), "Use core to construct.", params);
		button.SetEnabled(caller.getCarriedBlob() !is null);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("build"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null)if(getNet().isServer()){
				if(hold.getName() == "mat_stone" && hold.getQuantity() >= 200){
					CBlob@ golem = server_CreateBlob("golem", caller.getTeamNum(), this.getPosition());
					if(this.getName() == "stone_core")golem.set_u8("core",1);
					if(this.getName() == "gold_core")golem.set_u8("core",2);
					if(hold.getQuantity() == 200)hold.server_Die();
					else hold.server_SetQuantity(hold.getQuantity()-200);
					this.server_Die();
				}
				if(hold.getName() == "mat_gold" && hold.getQuantity() >= 200){
					CBlob@ golem = server_CreateBlob("gold_golem", caller.getTeamNum(), this.getPosition());
					if(this.getName() == "stone_core")golem.set_u8("core",1);
					if(this.getName() == "gold_core")golem.set_u8("core",2);
					if(hold.getQuantity() == 200)hold.server_Die();
					else hold.server_SetQuantity(hold.getQuantity()-200);
					this.server_Die();
				}
				if(hold.getName() == "mat_wood" && hold.getQuantity() >= 200){
					CBlob@ golem = server_CreateBlob("wooden_golem", caller.getTeamNum(), this.getPosition());
					if(this.getName() == "stone_core")golem.set_u8("core",1);
					if(this.getName() == "gold_core")golem.set_u8("core",2);
					if(hold.getQuantity() == 200)hold.server_Die();
					else hold.server_SetQuantity(hold.getQuantity()-200);
					this.server_Die();
				}
			}
		}
	}
}