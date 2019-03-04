

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_empty);
	this.getShape().getConsts().mapCollisions = false;
	
	this.addCommandID("sacrifice");
	
	this.Tag("nobackneeded");
}

#include "Table.as";

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	if(caller.getCarriedBlob() !is null)
	if(caller.getCarriedBlob().hasTag("dead"))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("sacrifice"), "Sacrifice the body", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
		if (cmd == this.getCommandID("sacrifice"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				if(caller.getCarriedBlob() !is null)
				if(caller.getCarriedBlob().hasTag("dead") && caller.getCarriedBlob().getTeamNum() != caller.getTeamNum()){
					caller.getCarriedBlob().server_Die();
					int random = XORRandom(20)+(32-(getRules().get_u8("blob")/2));
					
					if(random <= 12){
						switch(XORRandom(7)){
						
							case 0:{
								server_CreateBlob("mat_bombs",-1,this.getPosition());
							break;}
							
							case 1:{
								server_CreateBlob("mat_firearrows",-1,this.getPosition());
							break;}
							
							case 2:{
								server_CreateBlob("mat_waterarrows",-1,this.getPosition());
							break;}
							
							case 3:{
								server_CreateBlob("drill",-1,this.getPosition());
							break;}
							
							case 4:{
								server_CreateBlob("saw",this.getTeamNum(),this.getPosition());
							break;}
							
							case 5:{
								CBlob @stone = server_CreateBlob("mat_stone",-1,this.getPosition());
								stone.server_SetQuantity(50);
							break;}
							
							case 6:{
								CBlob @wood = server_CreateBlob("mat_wood",-1,this.getPosition());
								wood.server_SetQuantity(50);
							break;}
						
						}
					} else if(random <= 18){
						switch(XORRandom(5)){
						
							case 0:{
								server_CreateBlob("minikeg",-1,this.getPosition());
							break;}
							
							case 1:{
								server_CreateBlob("mat_bombarrows",-1,this.getPosition());
							break;}
							
							case 2:{
								CBlob @gold = server_CreateBlob("mat_gold",-1,this.getPosition());
								gold.server_SetQuantity(25);
							break;}
							
							case 3:{
								CBlob @stone = server_CreateBlob("mat_stone",-1,this.getPosition());
								stone.server_SetQuantity(100);
							break;}
							
							case 4:{
								server_CreateBlob("mine",caller.getTeamNum(),this.getPosition());
							break;}
						
						}
					} else if(random <= 20) {
						switch(XORRandom(5)){
						
							case 0:{
								server_CreateBlob("keg",-1,this.getPosition());
							break;}
							
							case 1:{
								server_CreateBlob("ultratrampoline",-1,this.getPosition());
							break;}
							
							case 2:{
								server_CreateBlob("ultradrill",-1,this.getPosition());
							break;}
						
							case 3:{
								server_CreateBlob("handlauncher",-1,this.getPosition());
							break;}
							
							case 4:{
								server_DropCoins(this.getPosition(), 100);
							break;}
						
						}
					} else {
						print("s");
						print("c");
						print("r");
						print("e");
						print("w");
						print(" ");
						print("y");
						print("o");
						print("u");
						blob();
					}
				}
			}
		}
	}
}


void onDie(CBlob@ this)
{

}