
#include "AbilityCommon.as"
#include "eleven.as"
#include "HumanoidCommon.as"

void hemoric_healing(CBlob @ this){
	if(this.get_s16("blood_amount") > 50){
		if(!this.hasTag("hemoric_healing"))this.Tag("hemoric_healing");
		else this.Untag("hemoric_healing");
	} else this.Untag("hemoric_healing");
}
string hemoric_healing_icon(CBlob @ this){
	if(!this.hasTag("hemoric_healing"))return "HemoricHealing.png";
	else return "HemoricHealingOn.png";
}

void hemoric_growth(CBlob @ this){
	if(this.get_s16("blood_amount") >= 100){
		if(CheckCooldown(this,"restore_cd") == 0){
			int MArm = this.get_s8("main_arm_type");
			int SArm = this.get_s8("sub_arm_type");
			int FLeg = this.get_s8("front_leg_type");
			int Bleg = this.get_s8("back_leg_type");
			
			if(MArm == -1){
				attachLimb(this,"main_arm",BodyType::PinkFlesh);
				this.sub_s16("blood_amount",50);
			}
			else if(SArm == -1){
				attachLimb(this,"sub_arm",BodyType::PinkFlesh);
				this.sub_s16("blood_amount",50);
			}
			else if(FLeg == -1){
				attachLimb(this,"front_leg",BodyType::PinkFlesh);
				this.sub_s16("blood_amount",50);
			}
			else if(Bleg == -1){
				attachLimb(this,"back_leg",BodyType::PinkFlesh);
				this.sub_s16("blood_amount",50);
			}
			
			if(getNet().isServer())this.Sync("blood_amount",true);
		
			StartCooldown(this,"restore_cd",30*5);
		}
	}
}
string hemoric_growth_icon(CBlob @ this){
	return "HemoricGrowth.png";
}

void hemoric_strength(CBlob @ this){
	if(this.get_s16("blood_amount") > 50){
		if(!this.hasTag("hemoric_strength"))this.Tag("hemoric_strength");
		else this.Untag("hemoric_strength");
	} else this.Untag("hemoric_strength");
}
string hemoric_strength_icon(CBlob @ this){
	if(!this.hasTag("hemoric_strength"))return "HemoricStrength.png";
	else return "HemoricStrengthOn.png";
}


void hemoric_yank(CBlob @this){

	if(CheckCooldown(this,"yank_cd") == 0){
		
		bool succed = false;
		
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f*getPowerMod(this,"blood"), @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				
				if(b !is null && b !is this){
				
					if(b.get_f32("bleed") > 0){
					
						Vec2f Dir = b.getPosition()-this.getPosition();
						Dir.Normalize();
					
						for(int j = 0;j < Maths::Min(b.get_f32("bleed"),10.0f);j++){
							if(b.get_s16("blood_amount") > 0){
								b.sub_s16("blood_amount",1);
							
								if(getNet().isServer()){
									CBlob @bl = server_CreateBlob("b",-1,b.getPosition()+Vec2f(XORRandom(11)-5,XORRandom(11)-5)-Dir*16.0f);
									if(bl !is null)bl.setVelocity((Vec2f(XORRandom(33)-16,XORRandom(33)-16)/16.0f)-Dir*3.0f);
								}
							
							} else break;
						}
						
						b.setVelocity(b.getVelocity()-Dir*5.0f);
						
						succed = true;
					}
				}
			}
		}

		if(succed)StartCooldown(this,"yank_cd",30*5);
	}

}
string hemoric_yank_icon(CBlob @this){
	return "HemoricYank.png";
}

void hemoric_armour(CBlob @ this){
	if(CheckCooldown(this,"armour_cd") == 0){
		if(this.get_s16("blood_amount") > 50){
			if(getEquippedBlob(this,"torso") is null){
				if(getNet().isServer())equipItemTemp(this, server_CreateBlob("blood_shirt",-1,this.getPosition()), "torso");
				this.sub_s16("blood_amount",50);
				StartCooldown(this,"armour_cd",30*10);
			}
		}
		
		if(this.get_s16("blood_amount") > 50){
			if(getEquippedBlob(this,"legs") is null){
				if(getNet().isServer())equipItemTemp(this, server_CreateBlob("blood_pants",-1,this.getPosition()), "legs");
				this.sub_s16("blood_amount",50);
				StartCooldown(this,"armour_cd",30*10);
			}
		}
	}
}
string hemoric_armour_icon(CBlob @ this){
	return "HemoricArmour.png";
}

void hemoric_wings(CBlob @ this){
	if(CheckCooldown(this,"armour_cd") == 0){
		if(this.get_s16("blood_amount") > 200){
			if(getNet().isServer())equipItemTemp(this, server_CreateBlob("rw",-1,this.getPosition()), "back");
			this.sub_s16("blood_amount",200);
			StartCooldown(this,"armour_cd",30*10);
		}
	}
}
string hemoric_wings_icon(CBlob @ this){
	return "HemoricWings.png";
}



void hemoric_infuse(CBlob @this){

	if(this.get_s16("blood_amount") > 20){
		if(CheckCooldown(this,"transfuse_cd") == 0){
			
			CBlob @item = this.getCarriedBlob();

			if(item !is null && !item.hasTag("cursed")){
				item.Tag("cursed");
				
				this.sub_s16("blood_amount",20);
				if(getNet().isServer()){
					this.Sync("blood_amount", true);
					item.Sync("cursed", true);
				}
				
				StartCooldown(this,"transfuse_cd",30*5);
			}
		}
	}

}
string hemoric_infuse_icon(CBlob @this){
	return "HemoricInfusion.png";
}

void hemoric_spikes(CBlob @ this){
	
	if(CheckCooldown(this,"spikes_cd") == 0){
		
		int spikes = 0;
		
		{
			CBlob@[] s;
			getBlobsByName("pnn", s);
			for(int i = 0;i<s.length;i++){
				CBlob @pnn = s[i];
				if(pnn !is null){
					if(pnn.get_u16("owner") == this.getNetworkID())spikes += 1;
				}
			}
		}
		
		if((CheckCooldown(this,"first_cast_spikes_cd") == 0 && spikes == 0) || (CheckCooldown(this,"first_cast_spikes_cd") > 0)){
			if(this.get_s16("blood_amount") >= 50){
					
				if(getNet().isServer()){
					CBlob @s = server_CreateBlob("pnn",this.getTeamNum(),this.getPosition());
					
					if(s !is null){

						Vec2f RayHitPos = this.getAimPos();
						getMap().rayCastSolidNoBlobs(this.getPosition(),this.getAimPos(),RayHitPos);
						
						s.set_Vec2f("guard",RayHitPos);
						s.set_u16("owner",this.getNetworkID());
					}
				}
				this.sub_s16("blood_amount",5+spikes);
				StartCooldown(this,"first_cast_spikes_cd",30*1);
			}
		} else {
		
			if(spikes > 0){
			
				CBlob@[] s;
				getBlobsByName("pnn", s);
				for(int i = 0;i<s.length;i++){
					CBlob @pnn = s[i];
					if(pnn !is null){
						if(pnn.get_u16("owner") == this.getNetworkID()){
							pnn.server_Die();
						}
					}
				}
			
				StartCooldown(this,"spikes_cd",30*10);
			}
		
		}
	
	}
}
string hemoric_spikes_icon(CBlob @ this){
	int spikes = 0;
		
	{
		CBlob@[] s;
		getBlobsByName("pnn", s);
		for(int i = 0;i<s.length;i++){
			CBlob @pnn = s[i];
			if(pnn !is null){
				if(pnn.get_u16("owner") == this.getNetworkID()){
					spikes += 1;
					break;
				}
			}
		}
	}
	
	if((CheckCooldown(this,"first_cast_spikes_cd") == 0 && spikes == 0) || (CheckCooldown(this,"first_cast_spikes_cd") > 0))return "HemoricSpikes.png";
	else return "PinsAndNeedles.png";
}

#include "copy.as"

void hemoric_morph(CBlob @this){

	if(getNet().isServer()){
	
		CBlob @mouse = server_CreateBlob("mouse",this.getTeamNum(),this.getPosition());
		
		if(mouse !is null){
		
			mouse.server_PutInInventory(this);
			
			mouse.server_SetPlayer(this.getPlayer());
			
			copy(this,mouse,true, true, true ,true, true, true, true, true );
		}
	
	
	}

}
string hemoric_morph_icon(CBlob @this){
	return "HemoricInfusion.png";
}