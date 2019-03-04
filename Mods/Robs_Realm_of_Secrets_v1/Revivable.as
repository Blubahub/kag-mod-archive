#include "ChangeClass.as";

void onInit(CBlob@ this)
{
	this.addCommandID("fill");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.hasTag("dead")){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("fill"), "Desecrate.", params);
		button.SetEnabled(caller.getCarriedBlob() !is null && caller.getCarriedBlob() !is this);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(getNet().isServer())
	if(this.hasTag("dead")){
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if (cmd == this.getCommandID("fill"))
			{
				CBlob@ hold = caller.getCarriedBlob();
				if(hold !is null){
					if(hold.getName() == "wisp"){
						if(getPlayerByUsername(this.get_string("username")) !is null)
							if(getPlayerByUsername(this.get_string("username")).getBlob() !is null)if(getPlayerByUsername(this.get_string("username")).getBlob().hasTag("ghost")){
								CBlob@ new = ChangeClass(getPlayerByUsername(this.get_string("username")).getBlob(),this.getName(),this.getPosition(),caller.getTeamNum());
								new.set_u8("race",2);
								hold.server_Die();
								this.server_Die();
							}
					}
					if(hold.getName() == "caged_wisp"){
						if(getPlayerByUsername(this.get_string("username")) !is null)
							if(getPlayerByUsername(this.get_string("username")).getBlob() !is null)if(getPlayerByUsername(this.get_string("username")).getBlob().hasTag("ghost")){
								CBlob@ new = ChangeClass(getPlayerByUsername(this.get_string("username")).getBlob(),this.getName(),this.getPosition(),caller.getTeamNum());
								new.set_u8("race",2);
								hold.Tag("no_wisp");
								hold.server_Die();
								this.server_Die();
								CBlob@ item = server_CreateBlob("cage", caller.getTeamNum(), caller.getPosition());
								caller.server_Pickup(item);
							}
					}
					if(hold.getName() == "heart"){
						CBlob@ item = server_CreateBlob("blood_zombie", caller.getTeamNum(), caller.getPosition());
						caller.server_Pickup(item);
						caller.Tag("evil_potential");
						caller.Sync("evil_potential",true);
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "seed"){
						CBlob@ item = server_CreateBlob("plant_zombie", caller.getTeamNum(), caller.getPosition());
						caller.server_Pickup(item);
						caller.Tag("evil_potential");
						caller.Sync("evil_potential",true);
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "mat_gold" && hold.getQuantity() >= 50){
						CBlob@ item = server_CreateBlob("gold_zombie", caller.getTeamNum(), caller.getPosition());
						caller.server_Pickup(item);
						hold.server_Die();
						this.server_Die();
					}
				}
			}
		}
	}
}