
#include "ContainerCommon.as";

void onInit(CBlob @this){

	this.set_u8("max_amount", 200);
	this.set_u8("heat", 0);
	
	//Normal
	this.set_u8("water_amount", 0);
	this.set_u8("starch_amount", 0);
	this.set_u8("meat_amount", 0);
	this.set_u8("burn_amount", 0);
	
	//Stupid
	this.set_u8("wood_amount", 0);
	this.set_u8("stone_amount", 0);
	this.set_u8("gold_amount", 0);
	this.set_u8("sap_amount", 0);
	
	//Bizzare
	this.set_u8("life_amount", 0);
	this.set_u8("death_amount", 0);
	this.set_u8("corruption_amount", 0);
	//for(uint i = 0; i < 100; i += 1)this.set_u8("potion["+i+"]_amount", 0);
	//0 = dough/porridge
	//1 = bread
	
	this.addCommandID("dump");
	this.addCommandID("insert");
	
	this.getCurrentScript().tickFrequency = 20;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.Tag("open");
}

void onTick(CBlob @this){
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getName() == "fireplace")
			{
				if(this.get_u8("heat") < 100)this.set_u8("heat", this.get_u8("heat")+2);
			}
		}
	}
	if(XORRandom(this.get_u8("stone_amount")+this.get_u8("gold_amount")) == 0)if(this.get_u8("heat") > 0)this.set_u8("heat", this.get_u8("heat")-1);
	
	if(this.isInWater())if(this.get_u8("heat") >= 5)this.set_u8("heat", this.get_u8("heat")-5);
	
	int Heat = this.get_u8("heat");
	
	if(Heat > 75){ //Heat is high enough to cook things
		if(this.get_u8("water_amount") > 0){ //Check for water
			adjustChem(this,"water_amount",-1); //Evaporate water
		} else { //If there is no water, start burning what's in the pot
			if(this.get_u8("sap_amount") > 0){
				adjustChem(this,"sap_amount",-1);
				adjustChem(this,"burn_amount",1);
			}
			if(this.get_u8("meat_amount") > 0){
				adjustChem(this,"meat_amount",-1);
				adjustChem(this,"burn_amount",1);
			}
			if(this.get_u8("starch_amount") > 0){
				adjustChem(this,"starch_amount",-1);
				adjustChem(this,"burn_amount",1);
			}
		}
		
		//Cooking/brewing
		
		if(this.get_u8("potion[0]_amount") > 0){
			adjustChem(this,"potion[0]_amount",-1);
			adjustChem(this,"potion[1]_amount",1);
		}
		
		
	} else {
		if(this.get_u8("starch_amount") > 0)
		if(this.get_u8("water_amount") > 0){
			adjustChem(this,"starch_amount",-1);
			adjustChem(this,"water_amount",-1);
			adjustChem(this,"potion[0]_amount",2);
		}
	}
	
	if(getNet().isServer())
	if(this.hasTag("open")){
		if(Heat < 75){
			if(XORRandom(2) == 0){
				if(this.get_u8("sap_amount") >= 20)
				if(this.get_u8("life_amount") >= 10){
					server_CreateBlob("slime", -1, this.getPosition()+Vec2f(0,-8));
					adjustChem(this,"sap_amount",-20);
					adjustChem(this,"life_amount",-10);
				}
			} else {
				if(this.get_u8("sap_amount") >= 10)
				if(this.get_u8("life_amount") >= 5){
					CBlob @slime = server_CreateBlob("slime", -1, this.getPosition()+Vec2f(0,-8));
					slime.Tag("baby");
					adjustChem(this,"sap_amount",-10);
					adjustChem(this,"life_amount",-5);
				}
			}
			
			if(this.get_u8("potion[1]_amount") >= 10){
				server_CreateBlob("bread", -1, this.getPosition()+Vec2f(0,-8));
				adjustChem(this,"potion[1]_amount",-10);
			}
		}
	}
	
	if(getAmount(this) > this.get_u8("max_amount")){
		if(this.get_u8("water_amount") > 0){ //Check for water
			for(int i = 0; i < 100; i += 1)if(this.get_u8("water_amount") > 0)adjustChem(this,"water_amount",-1); //Spill Water first
		} else
		Spill(this,getAmount(this)-this.get_u8("max_amount"));
	}
	
	if(getNet().isServer()){
		//Normal
		this.Sync("water_amount",true);
		this.Sync("starch_amount",true);
		this.Sync("meat_amount",true);
		this.Sync("burn_amount",true);
		
		//Stupid
		this.Sync("wood_amount",true);
		this.Sync("stone_amount",true);
		this.Sync("gold_amount",true);
		this.Sync("sap_amount",true);
		
		//Bizzare
		this.Sync("life_amount",true);
		this.Sync("death_amount",true);
		this.Sync("corruption_amount",true);
		for(uint i = 0; i < 100; i += 1)if(this.get_u8("potion["+i+"]_amount") > 0)this.Sync("potion["+i+"]_amount",true);
	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{	
	if (cmd == this.getCommandID("dump")){
		if (getNet().isServer()){
			Dump(this);
		}
	}
	
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("insert")){
			if (getNet().isServer()){
				if(caller.getCarriedBlob() !is null){
					addIngrediant(this, caller.getCarriedBlob());
				}
			}
		}
	}
}