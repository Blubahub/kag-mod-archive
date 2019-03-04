
#include "Hitters.as";
#include "Health.as";
#include "EnergyCommon.as";
#include "SwapClass.as";

void onInit(CBlob@ this)
{
	this.Untag("dead");
	
	this.Tag("triggerrune");
	
	this.set_u32("CurseTarget",0);
	
	
}

void onTick(CBlob@ this)
{

	CBlob @target = getBlobByNetworkID(this.get_u32("CurseTarget"));

	if(target is null){
		this.Tag("dead");
	} else {
		this.Untag("dead");
		
		if(target.hasTag("dead"))this.set_u32("CurseTarget",0);
		
		if(getGameTime() % 60 < 30)
		for(float k = 0.0f; k < this.getDistanceTo(target)-15; k += 2){
			Vec2f direction = target.getPosition()-this.getPosition();
			direction.Normalize();
			//ParticlePixel(this.getPosition()+direction*k+Vec2f(XORRandom(7)-3,XORRandom(7)-3), direction*2.0f, SColor(255, 60+XORRandom(50), 0+XORRandom(50), 90+XORRandom(50)), true);
			if(XORRandom(30)==1)ParticleAnimated("CursePuff.png", this.getPosition()+direction*k+Vec2f(XORRandom(5)-2,XORRandom(5)-2), direction, XORRandom(360), 0.3f, 2, 0, true);
		}
		
		
	}
	
	int ID = -1;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("runeblock") && b.getShape().isStatic()){
				if(ID < b.get_s8("rune_ID"))ID = b.get_s8("rune_ID");
			}
		}
	}
	
	while(ID == 15 || ID == 11)ID = XORRandom(15);
	
	if(target !is null){
		switch(ID){
			
			case 0:{
				if(getNet().isServer()){
					if(!target.hasTag("burning"))this.server_Hit(target, target.getPosition(), this.getVelocity()*-0.5f, 0.0f, Hitters::fire, true);
				}
			break;}
			
			case 1:{
				target.AddScript("AirBubble.as");
			break;}
			
			case 2:{
				target.AddScript("StoneShield.as");
			break;}
			
			case 3:{
				target.Tag("windjump");
			break;}
			
			case 4:{
				if(getGameTime()%30 == 0)
				if(Health(target) >= MaxHealth(target) && Health(target) < MaxHealth(target)*2.0f){
					OverHeal(target,0.5);
				}
			break;}
			
			case 5:{
				target.AddScript("RegenVines.as");
			break;}
			
			case 6:{
				if(Health(target) <= MaxHealth(target)/2){
					if(!this.hasTag("recall_once")){
						CBlob@[] tents;
						getBlobsByName("hall", @tents);
						getBlobsByName("tent", @tents);
						
						target.getSprite().PlaySound("WC3_Recall", 1.00f, 1.00f);
						if (target.isMyPlayer())
						{
							SetScreenFlash(255, 255, 255, 255);
							Sound::Play("WC3_Recall");
						}
						
						for(uint i = 0; i < tents.length; i++)
						{
							if(tents[i].getTeamNum() == target.getTeamNum())
							{
								target.setPosition(tents[i].getPosition());
								target.setVelocity( Vec2f_zero );			  
								target.getShape().PutOnGround();
								
								tents[i].getSprite().PlaySound("WC3_Recall", 1.00f, 1.00f);
								
								break;
							}
						}
						this.Tag("recall_once");
					}
				} else {
					this.Untag("recall_once");
				}
			break;}
			
			case 7:{
				target.AddScript("Haste.as");
				if(getGameTime()%20 == 0)target.set_u32("haste_timer",getGameTime()+XORRandom(29*30)+30);
			break;}
			
			case 8:{
				if(!target.hasTag("Halo"))target.AddScript("DeathGuard.as");
			break;}
			
			case 9:{
				if(!target.hasTag("Barrier")){
				
					if(target.get_u32("barrier_timer") < getGameTime()-5*30){ //Has too much time passed?
					
						target.set_u32("barrier_timer",getGameTime()); //reset barrier cooldown
					
					} else 
					if(target.get_u32("barrier_timer") < getGameTime()-4*30){ //Has enough time passed?
						target.AddScript("Barrier.as");
					}
				
				}
			break;}
			
			case 10:{
				if(getGameTime()%30 == 0)
				if(Health(target) <= MaxHealth(target)*0.25f){
					Heal(target,0.5);
				}
				
				if(getGameTime() % 5 == 0)ParticleAnimated("HealParticle.png", target.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 1.0f, 5, -0.1f, true);
			break;}
			
			case 11:{
				target.AddScript("BuffOrder.as");
				target.set_u32("null_buff",getGameTime()+60);
			break;}
			
			case 12:{
				if(Health(target) <= MaxHealth(target)/2){
					swapClass(target, "mansshadow");
				}
				if(target.getVelocity().y > 1.0f || target.getVelocity().y < -1.0f || target.getVelocity().x > 1.0f || target.getVelocity().x < -1.0f)
				ParticleAnimated("DeathPuff.png", target.getPosition() + getRandomVelocity(0, 6, 360), target.getVelocity()/3, XORRandom(360), 0.5f+(XORRandom(25)/100.0f), 3, 0.0f, false);
			break;}
			
			case 13:{
				target.AddScript("ReviveSelf.as");
				target.set_string("force_class_revive","zombie");
			break;}
			
			case 14:{
				target.AddScript("Plague.as");
			break;}
		}
	}

	if(this.hasTag("dead")){
		this.getSprite().SetFrame(1);
	} else {
		if(ID == 15)ID = XORRandom(15);
		if(ID != -1)this.getSprite().SetFrame(4+ID);
		else this.getSprite().SetFrame(0);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.hasTag("flesh") && !blob.hasTag("dead"));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(getBlobByNetworkID(this.get_u32("CurseTarget")) is null)
	if(blob.hasTag("flesh") && !blob.hasTag("dead") && !blob.hasTag("RuneNullify"))
	{
		this.set_u32("CurseTarget",blob.getNetworkID());
	}	
}
