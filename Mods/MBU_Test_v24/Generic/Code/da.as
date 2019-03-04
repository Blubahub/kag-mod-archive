
#include "ep.as"
#include "AbilityCommon.as"
#include "eleven.as"
#include "HumanoidCommon.as"

void deathly_manifest(CBlob @ this){
	if(this.get_s16("death_amount") > 0)
	if(CheckCooldown(this,"manifest_cd") == 0){
		if(!this.hasTag("manifested")){
			this.Tag("manifested");
			
			if(this.get_s8("main_arm_type") == BodyType::Ghost)attachLimb(this,"main_arm",BodyType::Wraith);
			if(this.get_s8("sub_arm_type") == BodyType::Ghost)attachLimb(this,"sub_arm",BodyType::Wraith);
			if(this.get_s8("front_leg_type") == BodyType::Ghost)attachLimb(this,"front_leg",BodyType::Wraith);
			if(this.get_s8("back_leg_type") == BodyType::Ghost)attachLimb(this,"back_leg",BodyType::Wraith);
			if(this.get_s8("torso_type") == BodyType::Ghost)attachLimb(this,"torso",BodyType::Wraith);
			this.Untag("ghost");

		} else {
			int WraithLimbs = 0;
			
			if(this.get_s8("main_arm_type") == BodyType::Wraith){attachLimb(this,"main_arm",BodyType::Ghost);WraithLimbs++;}
			if(this.get_s8("sub_arm_type") == BodyType::Wraith){attachLimb(this,"sub_arm",BodyType::Ghost);WraithLimbs++;}
			if(this.get_s8("front_leg_type") == BodyType::Wraith){attachLimb(this,"front_leg",BodyType::Ghost);WraithLimbs++;}
			if(this.get_s8("back_leg_type") == BodyType::Wraith){attachLimb(this,"back_leg",BodyType::Ghost);WraithLimbs++;}
			if(this.get_s8("torso_type") == BodyType::Wraith){
				attachLimb(this,"torso",BodyType::Ghost);
				this.Tag("ghost");
				WraithLimbs++;
			}
			
			for(int i = 0;i < WraithLimbs*4;i++)
			ep(this.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), false, Vec2f(XORRandom(3)-1,XORRandom(3)-1)+this.getVelocity());
			
			this.Untag("manifested");
		}
		StartCooldown(this,"manifest_cd",30);
	}
}
string deathly_manifest_icon(CBlob @ this){
	if(!this.hasTag("manifested"))return "DeathlyManifestIcon.png";
	else return "DeathlyFadeIcon.png";
}

void deathly_possess(CBlob @ this){
	if(this.get_s16("death_amount") > 0)
	if(this.getPlayer() !is null)
	if(CheckCooldown(this,"possess_cd") == 0){
		if(checkEInterface(this,this.getPosition(),16,10)){
			if(!this.hasTag("ghost") && this.get_s8("torso_type") != BodyType::Wraith){
				seperateSoul(this, false);
			} else {
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(!b.hasTag("soul") && b.getName() == "humanoid"){
						
							b.server_SetPlayer(this.getPlayer());
							b.Tag("soul");
							b.set_s16("death_amount", b.get_s16("death_amount")+this.get_s16("death_amount"));
							b.set_s16("life_amount", b.get_s16("life_amount")+this.get_s16("life_amount"));
							
							StartCooldown(b,"possess_cd",30);
							
							for(int i = 1;i <= 9;i++)
							b.set_u8("slot_"+i,this.get_u8("slot_"+i));
							
							if(getNet().isServer()){
								b.server_setTeamNum(this.getTeamNum());
								this.server_SetPlayer(null);
								this.server_Die();
							}
						}
					}
				}
			}
			StartCooldown(this,"possess_cd",30);
		}
	}
}
string deathly_possess_icon(CBlob @ this){
	if(this.hasTag("ghost"))return "PossessIcon.png";
	else return "VacateIcon.png";
}


void ethereal_sowing(CBlob @ this){
	if(this.get_s16("death_amount") >= 10)
	if(CheckCooldown(this,"sow_cd") == 0){
		if(checkEInterface(this,this.getPosition(),16,10)){
			
			if(getNet().isServer()){
				CBlob @ds = server_CreateBlob("ds",-1,this.getPosition());
				
				if(ds !is null){
					ds.setVelocity(Vec2f(0,1));
				}
			}
		}
		this.sub_s16("death_amount",10);
		StartCooldown(this,"sow_cd",30*5);
	}
}
string ethereal_sowing_icon(CBlob @ this){
	return "EtherealSowing.png";
}

void ethereal_reap(CBlob @ this){
	if(CheckCooldown(this,"reap_cd") == 0){

		string player_name = "";
		if(this.getPlayer() !is null)player_name = this.getPlayer().getUsername();
		
		bool found = false;
	
		CBlob@[] s;
		getBlobsByName("si", s);
		
		int pay = 100;
		
		for(int i = 0;i<s.length;i++){
			CBlob @si = s[i];
			if(si !is null){
				if(si.get_string("owner_name") == player_name){
					if(!si.isInInventory()){
						si.set_u16("reap_time",getGameTime()+30);
						si.Tag("reaping");
						Vec2f aim = this.getAimPos()-si.getPosition();
						aim.Normalize();
						si.setVelocity(aim*15.0f);
						
						found = true;
					} else {
						if(getNet().isServer()){
							si.server_Die();
						}
					}
					pay = 0;
				}
			}
		}
	
		if(!found)
		if(this.get_s16("death_amount") > pay)
		if(getNet().isServer()){
			CBlob @si = server_CreateBlob("si",this.getTeamNum(),this.getPosition());
			
			if(si !is null){
				si.setVelocity(Vec2f(0,1));
				si.set_u16("owner",this.getNetworkID());
				si.set_string("owner_name",player_name);
				
				si.set_u16("reap_time",getGameTime()+30);
				si.Tag("reaping");
				Vec2f aim = this.getAimPos()-si.getPosition();
				aim.Normalize();
				si.setVelocity(aim*15.0f);
				
				this.sub_s16("death_amount",pay);
			}
		}
		
		
	
		if(pay < 100)StartCooldown(this,"reap_cd",30*5);
		else StartCooldown(this,"reap_cd",30*10);
	}
}
string ethereal_reap_icon(CBlob @ this){
	return "si_icon.png";
}



void ethereal_illusion(CBlob @ this){
	
	bool spawn_illusion = true;
		
	CBlob@[] ill;
	getBlobsByName("c", ill);
	
	for(int i = 0;i<ill.length;i++){
		CBlob @C = ill[i];
		if(C !is null){
			if(C.get_u16("owner") == this.getNetworkID()){
				Vec2f temp = this.getPosition();
				this.setPosition(C.getPosition());
				C.setPosition(temp);
				
				this.setVelocity(Vec2f(0,0));
				C.setVelocity(Vec2f(0,0));
				
				spawn_illusion = false;
			}
		}
	}
	
	if(spawn_illusion){
		if(CheckCooldown(this,"illusion_hidden_cd") == 0){
			if(this.get_s16("death_amount") >= 10){
				if(checkEInterface(this,this.getPosition(),32,10)){
					
					if(getNet().isServer()){
						CBlob @c = server_CreateBlob("c",-1,this.getPosition());
						
						if(c !is null){
							c.set_u16("owner",this.getNetworkID());
						}
					}
				}
				this.sub_s16("death_amount",10);
				StartCooldown(this,"illusion_hidden_cd",30*15);
			}
		} else {
			StartCooldown(this,"illusion_cd",CheckCooldown(this,"illusion_hidden_cd"));
		}
	}
}
string ethereal_illusion_icon(CBlob @ this){
	return "EtherealIllusion.png";
}


void summon_spirit(CBlob @ this){
	if(CheckCooldown(this,"spirit_cd") == 0){
		if(this.get_s16("death_amount") >= 50){
			if(checkEInterface(this,this.getPosition(),32,50)){
				
				if(getNet().isServer()){
					CBlob @s = server_CreateBlob("srt",-1,this.getPosition());
					
					if(s !is null){
						s.set_Vec2f("guard",this.getAimPos());
						if(this.getPlayer() !is null)s.set_string("owner_name",this.getPlayer().getUsername());
					}
				}
			}
			this.sub_s16("death_amount",50);
			StartCooldown(this,"spirit_cd",30*15);
		}
	}
}
string summon_spirit_icon(CBlob @ this){
	return "SummonSpirit.png";
}


void deathly_infuse(CBlob @this){

	if(this.get_s16("death_amount") >= 50){
		if(CheckCooldown(this,"transfuse_cd") == 0){
			
			CBlob @item = this.getCarriedBlob();

			if(item !is null && !item.hasTag("death_infused")){
				item.Tag("death_infused");
				
				this.sub_s16("death_amount",50);
				if(getNet().isServer())this.Sync("death_amount", true);
				
				StartCooldown(this,"transfuse_cd",30*5);
			}
		}
	}

}
string deathly_infuse_icon(CBlob @this){
	return "DeathlyInfusion.png";
}