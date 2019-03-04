
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
	if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("runeblock") && b.getShape().isStatic()){
				if(ID < b.get_s8("rune_ID"))ID = b.get_s8("rune_ID");
			}
		}
	}
	
	
	
	bool wasFree = false;
	
	Vec2f vec = Vec2f(1,0);
	for(int r = 0; r < 360; r += 20){
		
		vec.RotateBy(20);
		
		bool free = !getMap().rayCastSolidNoBlobs(this.getPosition()+vec*8, this.getPosition()+vec*64);
		
		if(free)if(XORRandom(10) == 0){
			ParticleAnimated("HolyParticle.png", this.getPosition()+vec*(XORRandom(160)+7)+(Vec2f(XORRandom(11)-5,XORRandom(11)-5)/5), vec*(XORRandom(7)+1)+(Vec2f(XORRandom(11)-5,XORRandom(11)-5)/30), XORRandom(360), 0.5f+(XORRandom(50)/100.0f), 3+XORRandom(2), 0.0f, true);
		}
		
		if(!free && wasFree){
			//vec.RotateBy(-10);
			ParticleAnimated("HolyParticle.png", this.getPosition()+vec*(XORRandom(3)+7)+(Vec2f(XORRandom(11)-5,XORRandom(11)-5)/5), vec*(XORRandom(7)+1)+(Vec2f(XORRandom(11)-5,XORRandom(11)-5)/30), XORRandom(360), 0.5f+(XORRandom(50)/100.0f), 3+XORRandom(2), 0.0f, true);
			//vec.RotateBy(+10);
		}
		
		
		
		vec.Normalize();
		
		wasFree = free;
	}
	
	wasFree = false;
	
	vec = Vec2f(1,0);
	for(int r = 0; r < 360; r += 20){
		
		vec.RotateBy(-20);
		
		bool free = !getMap().rayCastSolidNoBlobs(this.getPosition()+vec*8, this.getPosition()+vec*64);
		
		if(!free && wasFree){
			//vec.RotateBy(+10);
			ParticleAnimated("HolyParticle.png", this.getPosition()+vec*(XORRandom(3)+7)+(Vec2f(XORRandom(11)-5,XORRandom(11)-5)/5), vec*(XORRandom(7)+1)+(Vec2f(XORRandom(11)-5,XORRandom(11)-5)/30), XORRandom(360), 0.5f+(XORRandom(50)/100.0f), 3+XORRandom(2), 0.0f, true);
			//vec.RotateBy(-10);
		}
		
		vec.Normalize();
		
		wasFree = free;
	}
	
	int runs = XORRandom(2);
	int runID = ID;
	
	//if(ID == 15)runs = XORRandom(2);
	
	for(int r = 0; r < runs; r++){
		runID = ID;
		if(runID == 15)while(runID == 15 || runID == 11)runID = XORRandom(15);
		CBlob@[] blobs;	   
		if (getBlobs(@blobs)) 
		{
			for (uint i = 0; i < blobs.length; i += 1+XORRandom(20))
			{
				CBlob@ blob = blobs[i];
				if(blob !is null && !blob.hasTag("RuneNullify"))
				if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), blob.getPosition())){
				
					switch(runID){
					
						case 0:{
						
							if(getNet().isServer()){
								if(blob.getShape() !is null)
								if(blob.getShape().getConsts() !is null)
								if(blob.getShape().getConsts().isFlammable)if(!blob.hasTag("burning"))this.server_Hit(blob, blob.getPosition(), blob.getVelocity()*-0.5f, 0.0f, Hitters::fire, true);
							}
						
						break;}
					
						case 1:{
						
							if(getNet().isServer()){
								if(blob.hasTag("flesh"))if(XORRandom(10) == 0){
									CBlob @gey = server_CreateBlob("geyser",-1,blob.getPosition());
									gey.set_u8("Push",5);
								}
							}
						
						break;}
						
						case 2:{
							
							if(blob.hasTag("flesh")){
								if(XORRandom(20) == 0){
									if(getNet().isServer()){
										CBlob @meteor = server_CreateBlob("meteor",-1,Vec2f(blob.getPosition().x,0));
									}
								}
							}
							
						break;}
					
						case 3:{
							if(blob.hasTag("flesh"))
							{
								Vec2f vec = Vec2f(XORRandom(10)+5,0);
								vec.RotateBy(XORRandom(360));
								blob.setVelocity(vec+blob.getVelocity());
							}
						break;}

						case 4:{
							
							if(blob.hasTag("flesh")){
								if(XORRandom(2) == 0){
									{
									
										this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, 1.0f, Hitters::suddengib, true);
									
										Vec2f vec = Vec2f(64,0);
										vec.RotateBy(XORRandom(360));
										Vec2f dir = blob.getPosition()-(blob.getPosition()+vec);
										dir.Normalize();
										Vec2f pos = blob.getPosition()+dir*XORRandom(64)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
										
										if(getNet().isServer())server_CreateBlob("heart",-1,pos);
									}
								} else {
									if(Health(blob) < MaxHealth(blob)+2.0f){
										OverHeal(blob,1.0);
									}
								}
								if(Health(blob) > 1.0f)if(XORRandom(3) == 0)makeGibParticle("mini_gibs.png", blob.getPosition()+Vec2f(XORRandom(17)-8,XORRandom(17)-8), Vec2f(XORRandom(5)-2,-XORRandom(5)), 0, 1+XORRandom(4), Vec2f(8, 8), 2.0f, 20, "BodyGibFall1.ogg", this.getTeamNum());
							}
						break;}
						
						case 5:{
							
							if(blob.hasTag("flesh")){
								if(XORRandom(2) == 0)blob.AddScript("RegenVines.as");
								else {
									blob.AddScript("Root.as");
									blob.set_u32("root_timer",getGameTime()+30.0f*3.0f);
								}
							}
							
						break;}
						
						case 7:{
							
							if(blob.hasTag("flesh")){
								if(!blob.hasTag("Slowed") && !blob.hasTag("Hasted")){
									if(XORRandom(2) == 0){
										blob.AddScript("Slow.as");
										blob.set_u32("slow_timer",getGameTime()+120);
										blob.set_u32("slow_time_amount",120);
										blob.set_f32("slow_amount",0.5);
										if(getNet().isServer())blob.Sync("slow_timer",true);
									} else {
										blob.AddScript("Haste.as");
										blob.set_u32("haste_timer",getGameTime()+120);
										if(getNet().isServer())blob.Sync("haste_timer",true);
									}
								}
							}
							
						break;}
						
						case 8:{
							
							if(blob.hasTag("undead") || blob.hasTag("evil")){
								blob.server_Hit(blob, blob.getPosition(), Vec2f(0.0f,0.0f), 1.0f, Hitters::suddengib, false);
								for(int i = 0; i < 5; i += 1){
									ParticleAnimated("HolyParticle.png", blob.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
								}
							}
							
						break;}
						
						case 9:{
							
							if(blob.hasTag("flesh")){
								if(XORRandom(10) < 7){
									if(getEnergy(blob) > 0){
									
										addEnergy(blob,-1);
									
										Vec2f vec = Vec2f(64,0);
										vec.RotateBy(XORRandom(360));
										Vec2f dir = blob.getPosition()-(blob.getPosition()+vec);
										dir.Normalize();
										Vec2f pos = blob.getPosition()+dir*XORRandom(64)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
										
										if(getNet().isServer()){
											CBlob @orb = server_CreateBlob("energyorb",-1,pos);
											orb.server_SetTimeToDie(0.0f);
										}
									}
								} else {
									blob.AddScript("Barrier.as");
								}
							}
						break;}
						
						case 10:{
							if(blob.hasTag("flesh")){
								Heal(blob, 1.0f);
								Vec2f vec = Vec2f(12,0);
								for(int r = 0; r < 360; r += 20){
									vec.RotateBy(20);
									Vec2f dir = blob.getPosition()-(blob.getPosition()+vec);
									dir.Normalize();
									ParticleAnimated("HealParticle.png", blob.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
									ParticleAnimated("HealParticle.png", blob.getPosition()+vec, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
								}
							}
						break;}
						
						case 11:{
							if(blob.hasTag("flesh") && !blob.hasTag("dead"))
							{
								blob.AddScript("BuffOrder.as");
								blob.set_u32("null_buff",getGameTime()+10);
							}
							if(blob.hasTag("can_dispell")){
								blob.server_Die();
							}
						break;}
						
						case 12:{
							if(blob.hasTag("flesh") && !blob.hasTag("dead"))
							{
								blob.AddScript("Invisibility.as");
							}
						break;}
						
						case 13:{
							if(blob.hasTag("dead") && !blob.hasTag("rezzed") && blob.getName() != "necro" && blob.hasTag("flesh"))
							{
								for(int j = 0; j < getPlayerCount(); j ++){
									CPlayer @player = getPlayer(j);
									if(player.getTeamNum() == blob.getTeamNum())
									if(player.getBlob() is null){
										
										Sound::Play("ZombieHit.ogg", this.getPosition());
										
										//NO RESPAWN FOR YOU, MWAHAHAHAHA XD
										if(getNet().isServer()){
											
											string type = "zombie";
											
											if(blob.getName() == "ghoul")type = "ghoul";
											
											if(blob.getName() == "zombie")type = "skeleton";
											
											CBlob @zombie = server_CreateBlob(type,this.getTeamNum(),blob.getPosition());
											zombie.server_SetPlayer(player);
											blob.Tag("rezzed");
											blob.server_Die();
										}
										
										break;
									}
								}
							
							}
						break;}
						
						case 14:{
							if(blob.hasTag("dead") && blob.hasTag("flesh"))
							{
								server_CreateBlob("plague",-1,blob.getPosition());
							}
							if(!blob.hasTag("dead") && blob.hasTag("flesh")){
								if(XORRandom(2) == 0){
									if(getNet().isServer()){
										CBlob @plague = server_CreateBlob("plague",-1,Vec2f(blob.getPosition().x,0));
										plague.setVelocity(Vec2f(0,5));
									}
								}
								if(Health(blob) <= 1)Heal(blob,1);
							}
						break;}
					
					
					}
				}
			}
		}
		
		switch(runID){
				
			case 0:{
				for(int i = 0; i < 100; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){
					
						if(XORRandom(2) == 0)makeSteamParticle(this, Vec2f(), "SmallSmoke" + (1 + XORRandom(2)),vec);
						else if(XORRandom(2) == 0) makeSteamParticle(this, Vec2f(), "SmallFire" + (1 + XORRandom(2)),vec);
						else if(XORRandom(2) == 0) makeSteamParticle(this, Vec2f(), "SmallExplosion" + (1 + XORRandom(3)),vec);
						else if(XORRandom(2) == 0) makeSteamParticle(this, Vec2f(), "Explosion.png",vec);
						else makeSteamParticle(this, Vec2f(), "LargeSmoke.png",vec);
					}
				}
			break;}
			
			case 1:{

				for(int i = 0; i < 1; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){
						if(getNet().isServer()){
							server_CreateBlob("waterbubble",-1,vec);
						}
					}
				}
				
			break;}

			case 3:{
				for(int i = 0; i < 100; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){
					
						makeSteamParticle(this, Vec2f(), "SmallSteam.png",vec);
					}
				}
			break;}
			
			case 4:{
				for(int i = 0; i < 25; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){

						makeGibParticle("mini_gibs.png", vec+Vec2f(XORRandom(17)-8,XORRandom(17)-8), Vec2f(XORRandom(5)-2,-XORRandom(5)), 0, 1+XORRandom(4), Vec2f(8, 8), 2.0f, 20, "BodyGibFall1.ogg", this.getTeamNum());
					
						if(XORRandom(2) == 0)makeSteamParticle(this, Vec2f(XORRandom(7)-3,XORRandom(3)+3), "BloodSplat.png",vec);
						else if(XORRandom(2) == 0) makeSteamParticle(this, Vec2f(XORRandom(7)-3,XORRandom(3)+3), "BloodSplatBigger.png",vec);
						else makeSteamParticle(this, Vec2f(XORRandom(7)-3,XORRandom(3)+3), "BloodSquirt.png",vec);
					}
				}
			break;}
			
			case 5:{
				for(int i = 0; i < 25; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){

						makeGibParticle("GenericGibs.png", vec+Vec2f(XORRandom(17)-8,XORRandom(17)-8), Vec2f(XORRandom(5)-2,-XORRandom(2)), 7, 1+XORRandom(4), Vec2f(8, 8), 0.5f, 20, "Gurgle2", this.getTeamNum());
					}
				}
			break;}
			
			
			case 6:{

				for(int i = 0; i < 1; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){
						if(getNet().isServer()){
							CBlob @tele = server_CreateBlob("teleportal",-1,vec);
							
							tele.server_SetTimeToDie(10.0f);
						}
					}
				}
				
			break;}
			
			
			case 8:{

				for(int i = 0; i < 2; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){
						if(getNet().isServer()){
							CBlob @orb = server_CreateBlob("lightorb",-1,vec);
							
							orb.server_SetTimeToDie(10.0f);
						}
					}
				}
				
			break;}
			
			
			case 9:{
				for(int i = 0; i < 50; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){

						ParticleAnimated("EnergyParticle.png", vec, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 1.0f, 5, -0.1f, true);
					}
				}
			break;}
			
			case 10:{
				for(int i = 0; i < 50; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){

						ParticleAnimated("HealParticle.png", vec, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 1.0f, 5, -0.1f, true);
					}
				}
			break;}

			case 11:{
				for(int i = 0; i < 100; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){

						ParticleAnimated("OrderParticle.png", vec, Vec2f(0,0), 0, 1.0f, 4, 0.0f, true);
					}
				}
			break;}		
			
			case 12:{

				for(int i = 0; i < 1; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){
						if(getNet().isServer()){
							CBlob @shroud = server_CreateBlob("shroud",-1,vec);
							
							shroud.set_u32("timer",getGameTime()+30*10);
						}
					}
				}
				
			break;}
			
			case 13:{
				for(int i = 0; i < 50; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){

						ParticleAnimated("DeathPuff.png", vec, Vec2f(0,0), XORRandom(360), 1.0f, 2, 0, true);
					}
				}
			break;}
			
			case 14:{
				for(int i = 0; i < 75; i += 1){
					Vec2f vec = Vec2f(XORRandom(getMap().tilemapwidth*8),XORRandom(getMap().tilemapheight*8));
					if(!getMap().rayCastSolidNoBlobs(this.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5), vec)){

						ParticleAnimated("PlagueParticle.png", vec, Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, 0, 1.0f, 6, 0.0f, true);
					}
				}
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

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam", Vec2f pos = Vec2f(0,0))
{
	if (!getNet().isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), pos + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}