#include "ChangeClass.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.addCommandID("fill");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.hasTag("dead") && caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		string butt = "Eat";
		if(caller.getCarriedBlob() !is null)butt = "Interact";
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("fill"), butt, params);
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
						if(hold.getName() == "wisp"){
							if(getPlayerByUsername(this.get_string("username")) !is null)
								if(getPlayerByUsername(this.get_string("username")).getBlob() !is null)if(getPlayerByUsername(this.get_string("username")).getBlob().hasTag("ghost")){
									CBlob@ new = ChangeClass(getPlayerByUsername(this.get_string("username")).getBlob(),this.getName(),this.getPosition(),caller.getTeamNum());
									new.set_string("boss",caller.getPlayer().getUsername());
									hold.server_Die();
									this.server_Die();
								}
							return;
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
							return;
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
							return;
						}
						if(hold.getName() == "powerfactor"){
							CBlob@ item = server_CreateBlob("zombie", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
							return;
						}
						if(hold.getName() == "heart"){
							CBlob@ item = server_CreateBlob("blood_zombie", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
							return;
						}
						if(hold.getName() == "seed"){
							CBlob@ item = server_CreateBlob("plant_zombie", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
							return;
						}
						if(hold.getName() == "mat_gold" && hold.getQuantity() >= 50){
							CBlob@ item = server_CreateBlob("gold_zombie", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
							return;
						}
						if(hold.getName() == "steak"){
							CBlob@ item = server_CreateBlob("builder", caller.getTeamNum(), caller.getPosition());
							item.set_string("boss",caller.getPlayer().getUsername());
							item.set_u8("race",2);
							caller.server_Pickup(item);
							hold.server_Die();
							this.server_Die();
							return;
						}
						if(hold.getName() == "blooddagger"){
							caller.set_s16("blood",caller.get_s16("blood")+5);
							caller.Sync("blood",true);
							caller.server_Hit(this, this.getPosition(), Vec2f(0,-10), 10.0f, Hitters::suddengib, false);
							return;
						}
					}
				}
				
				if(hold is null){
				
					if(caller.getPlayer() !is null)
					if(caller.getPlayer().isMyPlayer()){
						
						string warning = "You ate a dead body...?";
						
						switch(XORRandom(5)){
						
							case 0:{
								warning = "You... you ate it... HOW COULD YOU EAT THE DEAD?";
							break;}
						
							case 1:{
								warning = "Did you just...? Eat a body...? Ewww.";
							break;}
							
							case 2:{
								warning = "Eating a dead body, you've already lost yourself to madness...";
							break;}
							
							case 3:{
								warning = "Eating a dead body, you've strayed so far from the path of the right...";
							break;}
							
							case 4:{
								warning = "How could you just... eat someone?";
							break;}
							
						}
						
						if(caller.get_u8("flesh_hunger")+4 > 20){
							warning = "YOU LOSE CONTROL OF YOUR MIND";
						}
						
						client_AddToChat(warning, SColor(255, 100, 50, 50));
					}
					
					if(getNet().isServer()){
						caller.set_u8("flesh_hunger",caller.get_u8("flesh_hunger")+4);
						
						caller.set_f32("food",100);
						caller.Sync("food",true);
						
						if(!caller.hasTag("ghoultransform"))
						if(caller.get_u8("flesh_hunger") > 20){
							ChangeClass(caller, "ghoul", caller.getPosition(), -1);
							caller.Tag("ghoultransform");
						}
						this.server_Hit(this, this.getPosition(), Vec2f(0,-10), 10.0f, Hitters::suddengib, false);
					}
				
				}
			}
		}
	}
}