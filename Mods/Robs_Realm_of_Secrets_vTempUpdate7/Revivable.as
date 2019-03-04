#include "ChangeClass.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.addCommandID("fill");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.hasTag("dead") && caller.getCarriedBlob() !is null && caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("fill"), "Desecrate", params);
		button.SetEnabled(caller.getCarriedBlob() !is this);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(getNet().isServer())
	if(this.hasTag("dead")){
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null && caller.getPlayer() !is null)
		{
			if (cmd == this.getCommandID("fill"))
			{
				CBlob@ hold = caller.getCarriedBlob();
				if(getNet().isServer()){
					
					if(hold !is null){
						if(hold.getName() == "blooddagger"){
							caller.set_s16("blood",caller.get_s16("blood")+5);
							caller.Sync("blood",true);
							this.server_Hit(this, this.getPosition(), Vec2f(0,-10), 10.0f, Hitters::suddengib, false);
							return;
						}
					}
					
					if(hold !is null){
						if(hold.getName() == "wisp"){
							if(getPlayerByUsername(this.get_string("username")) !is null)
								if(getPlayerByUsername(this.get_string("username")).getBlob() !is null)if(getPlayerByUsername(this.get_string("username")).getBlob().hasTag("ghost")){
									CBlob@ new = ChangeClass(getPlayerByUsername(this.get_string("username")).getBlob(),this.getName(),this.getPosition(),caller.getTeamNum());
									new.set_string("boss",caller.getPlayer().getUsername());
									hold.server_Die();
									this.server_Die();
								}
						}
						if(hold.getName() == "caged_wisp"){
							if(getPlayerByUsername(this.get_string("username")) !is null)
								if(getPlayerByUsername(this.get_string("username")).getBlob() !is null)if(getPlayerByUsername(this.get_string("username")).getBlob().hasTag("ghost")){
									CBlob@ new = ChangeClass(getPlayerByUsername(this.get_string("username")).getBlob(),this.getName(),this.getPosition(),caller.getTeamNum());
									new.set_string("boss",caller.getPlayer().getUsername());
									hold.Tag("no_wisp");
									hold.server_Die();
									this.server_Die();
									CBlob@ item = server_CreateBlob("cage", caller.getTeamNum(), caller.getPosition());
									caller.server_Pickup(item);
								}
						}
						if(hold.getName() == "ghost_shard"){
							if(hold.getPlayer() !is null)
								if(hold.getPlayer().getBlob() !is null){
									CBlob@ new = ChangeClass(hold.getPlayer().getBlob(),this.getName(),this.getPosition(),caller.getTeamNum());
									new.set_string("boss",caller.getPlayer().getUsername());
									new.set_s16("death",new.get_s16("life")+new.get_s16("death"));
									new.set_s16("life",0);
									hold.server_Die();
									this.server_Die();
								}
						}
						if(hold.getName() == "powerfactor"){
							CBlob@ item = server_CreateBlob("zombie", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
						}
						if(hold.getName() == "heart"){
							CBlob@ item = server_CreateBlob("blood_zombie", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
						}
						if(hold.getName() == "seed"){
							CBlob@ item = server_CreateBlob("plant_zombie", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
						}
						if(hold.getName() == "mat_gold" && hold.getQuantity() >= 50){
							CBlob@ item = server_CreateBlob("gold_zombie", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
						}
						if(hold.getName() == "steak"){
							CBlob@ item = server_CreateBlob("builder", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							item.set_u8("race",2);
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
						}
					}
				}
			}
		}
	}
}