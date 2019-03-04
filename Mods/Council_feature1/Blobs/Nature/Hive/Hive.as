
void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	if(!getNet().isServer())return;
	
	
	if(this.getBlobCount("honey") < 1){
	
		CBlob@[] blobs;
			
		getBlobsByName("bee", blobs);
		
		for (u32 k = 0; k < blobs.length; k++)
		{
			CBlob@ b = blobs[k];
			if(this.getDistanceTo(b) < 64){
				b.Tag("angry");
				b.Sync("angry",true);
			}
		}
	
		if(XORRandom(10) == 0){
			CBlob @honey = server_CreateBlob("honey",-1,this.getPosition());
			this.server_PutInInventory(honey);
		}
	}
	
	
	bool BeesClose = false;
	
	{
		CBlob@[] blobs;
				
		getBlobsByName("bee", blobs);
		
		for (u32 k = 0; k < blobs.length; k++)
		{
			CBlob@ b = blobs[k];
			if(this.getDistanceTo(b) < 64){
				BeesClose = true;
			}
		}
	}
	
	if(!BeesClose){
		CBlob @bee = server_CreateBlob("bee",this.getTeamNum(),this.getPosition());
		bee.set_u16("Bee_Amount",1+XORRandom(10));
		bee.Sync("Bee_Amount",true);
	}
	
	CBlob @tree = getBlobByNetworkID(this.get_netid("tree"));
	
	if(tree is null || tree.exists("cut_down_time")){
		this.server_Die();
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){

	return false; //no

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(getNet().isServer()){
		CBlob @bee = server_CreateBlob("bee",this.getTeamNum(),this.getPosition());
		bee.set_u16("Bee_Amount",1+XORRandom(10));
		bee.Sync("Bee_Amount",true);
		bee.Tag("angry");
		bee.Sync("angry",true);
		
		CBlob@[] blobs;
			
		getBlobsByName("bee", blobs);
		
		for (u32 k = 0; k < blobs.length; k++)
		{
			CBlob@ b = blobs[k];
			if(this.getDistanceTo(b) < 128){
				b.Tag("angry");
				b.Sync("angry",true);
			}
		}
	}
	
	return damage;
}

void onDie(CBlob@ this){
	if(getNet().isServer()){
		CBlob @bee = server_CreateBlob("bee",this.getTeamNum(),this.getPosition());
		bee.set_u16("Bee_Amount",50+XORRandom(50));
		bee.Sync("Bee_Amount",true);
		bee.Tag("angry");
		bee.Sync("angry",true);
	}
}