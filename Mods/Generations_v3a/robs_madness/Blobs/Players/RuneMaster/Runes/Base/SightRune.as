
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
	
	int Radius = 64;
	
	bool[] runes = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false};
	
	int teleportalID = 0;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("runeblock") && b.getShape().isStatic()){
				if(XORRandom(2) == 0 || ID < 0)ID = b.get_s8("rune_ID");
				if(b.get_s8("rune_ID") >= 0 && b.get_s8("rune_ID") <= 24){
					runes[b.get_s8("rune_ID")] = true;
				}
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
	
	for (uint i = getGameTime() % 2; i < 24; i += 2){
	
		if(runes[6] && i != 6)continue;
	
		if(runes[i] || (runes[15] && (XORRandom(15) == i && i != 11)))
		switch(i){
			
			case 0:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("RuneNullify"))
						{
							if(!b.hasTag("burning"))this.server_Hit(b, b.getPosition(), this.getVelocity()*-0.5f, 0.0f, Hitters::fire, true);
						}
					}
				}
				
				
				Vec2f vec = Vec2f(Radius,0);
				for(int r = 0; r < 360; r += 20){
					vec.RotateBy(r+XORRandom(20));
					Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					dir.Normalize();
					Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
					//makeSteamParticle(this, Vec2f(), XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)),pos);
					makeSteamParticle(this, Vec2f(), "SmallSmoke" + (1 + XORRandom(2)),pos);
				}
			break;}
			
			case 1:{

				if(XORRandom(75) == 0){
			
					Vec2f vec = Vec2f(Radius,0);
					vec.RotateBy(XORRandom(360));
					Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					dir.Normalize();
					Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);

					if(getNet().isServer())server_CreateBlob("waterbubble",-1,pos);
				
				}
				
			break;}
			
			case 2:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("RuneNullify"))
						{
							//if(!b.hasTag("burning"))this.server_Hit(b, b.getPosition(), this.getVelocity()*-0.5f, 0.0f, Hitters::fire, true);
							if(XORRandom(5) == 0){
								if(XORRandom(2) == 0)makeGibParticle("GenericGibs.png", b.getPosition(), Vec2f(XORRandom(5)-2,-XORRandom(5)), 0, 1+XORRandom(4), Vec2f(8, 8), 1.0f, 20, "dig_dirt2.ogg", this.getTeamNum());
								else makeGibParticle("GenericGibs.png", b.getPosition(), Vec2f(XORRandom(5)-2,-XORRandom(5)), 2, 1+XORRandom(4), Vec2f(8, 8), 1.0f, 20, "dig_dirt2.ogg", this.getTeamNum());
								
								this.server_Hit(b, b.getPosition(), this.getVelocity()*-0.5f, 0.05f, Hitters::crush, true);
							}
						}
					}
				}
				
				
				Vec2f vec = Vec2f(XORRandom(Radius),0);
				vec.RotateBy(XORRandom(360));
				Vec2f pos = this.getPosition()+vec+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
				if(XORRandom(2) == 0)makeGibParticle("GenericGibs.png", pos, Vec2f(XORRandom(5)-2,-XORRandom(5)), 0, 1+XORRandom(4), Vec2f(8, 8), 1.0f, 20, "dig_dirt2.ogg", this.getTeamNum());
				else makeGibParticle("GenericGibs.png", pos, Vec2f(XORRandom(5)-2,-XORRandom(5)), 2, 1+XORRandom(4), Vec2f(8, 8), 1.0f, 20, "dig_dirt2.ogg", this.getTeamNum());
			break;}
			
			case 3:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("RuneNullify"))
						{
							if(XORRandom(10) == 0){
								Vec2f vec = Vec2f(XORRandom(5)+2,0);
								vec.RotateBy(XORRandom(360));
								b.setVelocity(vec+b.getVelocity());
							}
						}
					}
				}
				
				
				Vec2f vec = Vec2f(Radius,0);
				for(int r = 0; r < 360; r += 20){
					vec.RotateBy(r+XORRandom(20));
					Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					dir.Normalize();
					Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
					makeSteamParticle(this, Vec2f(), "SmallSteam.png",pos);
				}
			break;}
			
			case 4:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("RuneNullify"))
						{
							if(XORRandom(50) == 0){
								if(Health(b) > 1.0f){
								
									this.server_Hit(b, b.getPosition(), this.getVelocity()*-0.5f, 1.0f, Hitters::suddengib, true);
								
									Vec2f vec = Vec2f(Radius,0);
									vec.RotateBy(XORRandom(360));
									Vec2f dir = this.getPosition()-(this.getPosition()+vec);
									dir.Normalize();
									Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
									
									if(getNet().isServer())server_CreateBlob("heart",-1,pos);
								}
							}
							if(Health(b) > 1.0f)if(XORRandom(3) == 0)makeGibParticle("mini_gibs.png", b.getPosition()+Vec2f(XORRandom(17)-8,XORRandom(17)-8), Vec2f(XORRandom(5)-2,-XORRandom(5)), 0, 1+XORRandom(4), Vec2f(8, 8), 2.0f, 20, "BodyGibFall1.ogg", this.getTeamNum());
						}
					}
				}
				
				
				Vec2f vec = Vec2f(Radius,0);
				for(int r = 0; r < 360; r += 90){
					vec.RotateBy(r+XORRandom(90));
					Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					dir.Normalize();
					Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
					ParticleAnimated("HealParticle.png", pos, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
				}
			break;}
			
			case 5:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("RuneNullify"))
						{
							if(XORRandom(100) == 0){
								b.AddScript("Root.as");
								b.set_u32("root_timer",getGameTime()+30.0f*5.0f);
							}
						}
					}
				}
				
				if(XORRandom(3) == 0){
					Vec2f vec = Vec2f(Radius,0);
					for(int r = 0; r < 360; r += 360){
						vec.RotateBy(r+XORRandom(360));
						Vec2f dir = this.getPosition()-(this.getPosition()+vec);
						dir.Normalize();
						Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
						makeGibParticle("GenericGibs.png", pos, Vec2f(XORRandom(5)-2,-XORRandom(2)), 7, 1+XORRandom(4), Vec2f(8, 8), 0.5f, 20, "Gurgle2", this.getTeamNum());
					}
				}
			break;}
			
			case 6:{

				bool canSpawn = true;
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getName() == "teleportal"){
							canSpawn = false;
						}
					}
				}
				
				if(canSpawn){
					//Vec2f vec = Vec2f(Radius/64,0);
					//vec.RotateBy(XORRandom(360));
					//Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					//dir.Normalize();
					//Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);

					Vec2f pos = Vec2f(0,0);
					
					if(!getMap().isTileSolid(getMap().getTile(this.getPosition()+Vec2f(0,-24)))){
						pos = this.getPosition()+Vec2f(0,-24);
					} else
					if(!getMap().isTileSolid(getMap().getTile(this.getPosition()+Vec2f(0,24)))){
						pos = this.getPosition()+Vec2f(0,24);
					} else
					if(!getMap().isTileSolid(getMap().getTile(this.getPosition()+Vec2f(24,0)))){
						pos = this.getPosition()+Vec2f(24,0);
					} else 
					if(!getMap().isTileSolid(getMap().getTile(this.getPosition()+Vec2f(-24,0)))){
						pos = this.getPosition()+Vec2f(-24,0);
					}
					
					
					if(getNet().isServer()){
						CBlob @tele = server_CreateBlob("teleportal",-1,pos);
						tele.set_u16("teleportal_id",teleportalID);
						tele.Sync("teleportal_id",true);
						tele.server_SetTimeToDie(5.0f);
					}
				}
				
			break;}
			
			case 7:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("RuneNullify"))
						{
							
							if(!b.hasTag("Slowed") && !b.hasTag("Hasted")){
								if(XORRandom(2) == 0){
									b.AddScript("Slow.as");
									b.set_u32("slow_timer",getGameTime()+30);
									b.set_u32("slow_time_amount",30);
									b.set_f32("slow_amount",0.7);
									if(getNet().isServer())b.Sync("slow_timer",true);
								} else {
									b.AddScript("Haste.as");
									b.set_u32("haste_timer",getGameTime()+5);
									if(getNet().isServer())b.Sync("haste_timer",true);
								}
							}
							
						}
					}
				}
			break;}
			
			case 8:{
				
				if(getGameTime() % 3 == 0){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b.getName() == "mansshadow" && !b.hasTag("RuneNullify")){
								Vec2f dir = b.getPosition()-this.getPosition();
								dir.Normalize();
								b.AddForce(dir*400);
								for(float k = 0.0f; k < this.getDistanceTo(b); k += 2){
									Vec2f direction = b.getPosition()-this.getPosition();
									direction.Normalize();
									ParticleAnimated("HolyParticle.png", this.getPosition()+direction*k+Vec2f(XORRandom(7)-3,XORRandom(7)-3), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.1f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
								}
							}
							if(b.getName() == "deathorb"){
								Vec2f dir = b.getPosition()-this.getPosition();
								dir.Normalize();
								b.AddForce(dir*2);
								for(float k = 0.0f; k < this.getDistanceTo(b); k += 2){
									Vec2f direction = b.getPosition()-this.getPosition();
									direction.Normalize();
									ParticleAnimated("HolyParticle.png", this.getPosition()+direction*k+Vec2f(XORRandom(7)-3,XORRandom(7)-3), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.1f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
								}
								
							}
							if(b.hasTag("undead")){
								b.server_Hit(b, b.getPosition(), Vec2f(0.0f,0.0f), 0.5f, Hitters::suddengib, false);
								ParticleAnimated("HolyParticle.png", b.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
							}
						}
					}
				}
				
				if(XORRandom(2) == 0){
					Vec2f vec = Vec2f(XORRandom(Radius),0);
					vec.RotateBy(XORRandom(360));
					Vec2f pos = this.getPosition()+vec+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
					ParticleAnimated("HolyParticle.png", pos, Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.1f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 3, 0.0f, true);
				}
			break;}
			
			case 9:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("RuneNullify"))
						{
							if(XORRandom(10) == 0){
								if(getEnergy(b) > 0){
								
									addEnergy(b,-1);
								
									Vec2f vec = Vec2f(Radius,0);
									vec.RotateBy(XORRandom(360));
									Vec2f dir = this.getPosition()-(this.getPosition()+vec);
									dir.Normalize();
									Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
									
									if(getNet().isServer())server_CreateBlob("energyorb",-1,pos);
								}
							}
							if(getEnergy(b) > 0)ParticleAnimated("EnergyParticle.png", b.getPosition()+Vec2f(XORRandom(17)-8,XORRandom(17)-8), Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
						}
					}
				}
				
				if(XORRandom(2) == 0){
					Vec2f vec = Vec2f(Radius,0);
					for(int r = 0; r < 360; r += 180){
						vec.RotateBy(r+XORRandom(180));
						Vec2f dir = this.getPosition()-(this.getPosition()+vec);
						dir.Normalize();
						Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
						ParticleAnimated("EnergyParticle.png", pos, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
					}
				}
			break;}
			
			case 10:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("RuneNullify"))
						{
							Heal(b, 0.1f);
						}
					}
				}
				
				
				Vec2f vec = Vec2f(Radius,0);
				for(int r = 0; r < 360; r += 90){
					vec.RotateBy(r+XORRandom(90));
					Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					dir.Normalize();
					Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
					ParticleAnimated("HealParticle.png", pos, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
				}
			break;}
			
			case 11:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead"))
						{
							b.AddScript("BuffOrder.as");
							b.set_u32("null_buff",getGameTime()+10);
						}
						if(b.hasTag("can_dispell")){
							b.server_Die();
						}
					}
				}
				
				
				Vec2f vec = Vec2f(Radius,0);
				for(int r = 0; r < 360; r += 60){
					vec.RotateBy(r+XORRandom(60));
					Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					dir.Normalize();
					Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
					ParticleAnimated("OrderParticle.png", pos, Vec2f(0,0), 0, 0.5f, 4, 0.0f, true);
					
					ParticleAnimated("OrderParticle.png", this.getPosition()+vec, Vec2f(0,0), 0, 0.5f, 4, 0.0f, true);
				}
			break;}
			
			case 12:{
				
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("flesh") && !b.hasTag("dead"))
						{
							b.AddScript("Invisibility.as");
						}
					}
				}
			break;}
			
			case 13:{
				
				if(getGameTime() % 30 == 0){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), Radius, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b.hasTag("dead") && !b.hasTag("rezzed") && b.hasTag("flesh"))
							{
								for(int j = 0; j < getPlayerCount(); j ++){
									CPlayer @player = getPlayer(j);
									if(player.getTeamNum() == b.getTeamNum())
									if(player.getBlob() is null){
										
										Sound::Play("ZombieHit.ogg", this.getPosition());
										
										//NO RESPAWN FOR YOU, MWAHAHAHAHA XD
										if(getNet().isServer()){
											
											string type = "zombie";
											
											if(b.getName() == "ghoul")type = "ghoul";
											
											if(b.getName() == "zombie")type = "skeleton";
											
											if(b.getName() == "necro")type = "necro";
											
											CBlob @zombie = server_CreateBlob(type,this.getTeamNum(),b.getPosition());
											zombie.server_SetPlayer(player);
											b.Tag("rezzed");
											b.server_Die();
										}
										
										break;
									}
								}
							
							}
						}
					}
				}
				
				Vec2f vec = Vec2f(Radius,0);
				for(int r = 0; r < 360; r += 30){
					vec.RotateBy(r+XORRandom(30));
					Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					dir.Normalize();
					Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
					ParticleAnimated("DeathPuff.png", pos, Vec2f(0,0), XORRandom(360), 1.0f, 2, 0, true);
					//ParticleAnimated("OrderParticle.png", this.getPosition()+vec, Vec2f(0,0), 0, 0.5f, 4, 0.0f, true);
				}
			break;}
			
			case 14:{
				
				
				if(XORRandom(100) == 0){
					
					Vec2f vec = Vec2f(Radius,0);
					vec.RotateBy(XORRandom(360));
					Vec2f dir = this.getPosition()-(this.getPosition()+vec);
					dir.Normalize();
					Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
					
					if(getNet().isServer()){
						CBlob @plague = server_CreateBlob("plague",-1,pos);
						plague.server_SetTimeToDie(1.0f);
					}
				}
				
				if(XORRandom(2) == 0){
					Vec2f vec = Vec2f(Radius,0);
					for(int r = 0; r < 360; r += 180){
						vec.RotateBy(r+XORRandom(180));
						Vec2f dir = this.getPosition()-(this.getPosition()+vec);
						dir.Normalize();
						Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
						ParticleAnimated("PlagueParticle.png", pos, Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, 0, 1.0f, 6, 0.0f, true);
					}
				}
			break;}
		}
	
	}
	
}



void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam", Vec2f pos = Vec2f(0,0))
{
	if (!getNet().isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), pos + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}