
#include "Hitters.as";
#include "Health.as";
#include "EnergyCommon.as";

void onInit(CBlob@ this)
{
	this.Untag("dead");
	
	this.Tag("triggerrune");
	
	this.set_u32("recharge",getGameTime()+(2*30));
}

void onTick(CBlob@ this)
{

	if(!this.getShape().isStatic())return;

	int ID = -1;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("runeblock") && b.getShape().isStatic()){
				if(b.get_s8("rune_ID") != 8)
				if(ID < b.get_s8("rune_ID"))ID = b.get_s8("rune_ID");
			}
		}
	}

	if(this.hasTag("dead")){
		this.getSprite().SetFrame(1);
	} else {
		if(ID == 15)ID = XORRandom(15);
		if(ID != -1)this.getSprite().SetFrame(4+ID);
		else this.getSprite().SetFrame(0);
	}
	
	if(getGameTime() > this.get_u32("recharge")){
		this.Tag("dead");
		if(getNet().isServer()){
			this.Sync("dead",true);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.hasTag("flesh") && !blob.hasTag("dead"));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(!this.getShape().isStatic())return;
	
	if(blob.hasTag("flesh") && !blob.hasTag("dead") && !blob.hasTag("RuneNullify") && this.hasTag("dead"))
	{
		this.set_u32("recharge",getGameTime()+(2*30));
		
		int ID = -1;
	
		int power = 1;
	
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("runeblock") && b.getShape().isStatic()){
					if(b.get_s8("rune_ID") != 8){
						if(ID < b.get_s8("rune_ID"))ID = b.get_s8("rune_ID");
					} else power += 1;
				}
			}
		}
		
		bool recharge_discount = false;
		if(ID == 15){
			ID = XORRandom(15);
			recharge_discount = true;
		}
		
		//print("block id:"+ID);
		
		switch(ID){
		
			case 0:{
				if(getNet().isServer()){
					this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, 0.5f*power, Hitters::fire, true);
				}
			break;}
			
			case 1:{
				if(getNet().isServer()){
					this.set_u32("recharge",getGameTime()+(10*30));
					
					bool canSpawn = true;
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b.getName() == "geyser"){
								canSpawn = false;
							}
						}
					}
					
					if(canSpawn){
						CBlob @gey = server_CreateBlob("geyser", this.getTeamNum(), blob.getPosition());
						gey.set_f32("MaxHeight",90*power);
						gey.set_u8("Push",5*power);
					}
				}
			break;}
			
			case 2:{
				blob.AddScript("StoneShield.as");
			break;}
			
			case 3:{
				Vec2f dir = blob.getPosition()-this.getPosition();
				dir.Normalize();
				blob.setVelocity(dir*10*power+blob.getVelocity());
			break;}
			
			case 4:{
				if(Health(blob) < MaxHealth(blob)*1.4){
					OverHeal(blob,0.5*power);
				
					Vec2f vec = Vec2f(8,0);
					for(int r = 0; r < 360; r += 10){
						vec.RotateBy(r);
						Vec2f dir = blob.getPosition()-(blob.getPosition()+vec);
						dir.Normalize();
						makeGibParticle("mini_gibs.png", blob.getPosition()+vec+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5)-2), 0, 1+XORRandom(4), Vec2f(8, 8), 2.0f, 20, "BodyGibFall1.ogg", this.getTeamNum());
					}
				}
			break;}
			
			case 5:{
				blob.AddScript("RegenVines.as");
			break;}
			
			case 6:{
				Vec2f vel = blob.getOldVelocity();
				vel.Normalize;
				blob.setPosition(blob.getPosition()+vel*50*power);
			break;}
			
			case 7:{
				blob.AddScript("Slow.as");
				float time = 30.0f*20*power;
				blob.set_u32("slow_timer",getGameTime()+(time+1));
				blob.set_u32("slow_time_amount",(time+1));
				blob.set_f32("slow_amount",0.4f);
			break;}
			
			case 9:{
				addEnergy(blob, 1*power);
				for(int i = 0; i < 10;i++)
				ParticleAnimated("EnergyParticle.png", blob.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), blob.getVelocity()/10+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.2, XORRandom(360), 1.0f, 3, -0.01, true);
				this.set_u32("recharge",getGameTime()+(10*30*power));
			break;}
			
			case 10:{
				Heal(blob,1.0f*power);
				
				Vec2f vec = Vec2f(16,0);
				for(int r = 0; r < 360; r += 10){
					vec.RotateBy(r);
					Vec2f dir = blob.getPosition()-(blob.getPosition()+vec);
					dir.Normalize();
					ParticleAnimated("HealParticle.png", blob.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
					ParticleAnimated("HealParticle.png", blob.getPosition()+vec, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
				}
			break;}
			
			case 11:{
				blob.AddScript("BuffOrder.as");
				blob.set_u32("null_buff",getGameTime()+60*power);
			break;}
			
			case 12:{
				if(getNet().isServer()){
					this.set_u32("recharge",getGameTime()+(10*30));
					
					bool canSpawn = true;
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b.getName() == "shroud"){
								canSpawn = false;
							}
						}
					}
					
					if(canSpawn){
						CBlob @shr = server_CreateBlob("shroud", this.getTeamNum(), this.getPosition());
						shr.set_f32("scale",0.5f+power*0.3f);
					}
				}
			break;}
			
			case 13:{
				if(getNet().isServer()){
					this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, 2.0f*power, Hitters::suddengib, true);
				}
				for(int i = 0; i < 5; i++)
				ParticleAnimated("DeathOrbPuff.png", blob.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4, XORRandom(360), 1.0f, 5, -0.01, true);
			break;}
			
			case 14:{
				blob.AddScript("Plague.as");
			break;}
		
		}
		
		if(recharge_discount)this.set_u32("recharge",getGameTime()+(15));
		
		this.Untag("dead");
		if(getNet().isServer()){
			this.Sync("dead",true);
			this.Sync("recharge",true);
		}
	}	
}
