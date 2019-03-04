
#include "AbilityCommon.as"
#include "eleven.as"
#include "HumanoidCommon.as"
#include "ep.as"
#include "li.as"


void light_heal(CBlob @ this){
	if(CheckCooldown(this,"heal_cd") == 0){
		if(this.get_s16("light_amount") >= 50){
			if(checkEInterface(this,this.getPosition(),16,20)){
				restore(this,this,10.0f*getPowerMod(this,"light"));
				Vec2f offset = Vec2f(1,0);
				for(int i = 0;i < 8;i++){
					offset.RotateBy(45);
					ltp(this.getPosition()+(offset*8.0f),-(offset/2.0f)+this.getVelocity());
				}
			}
			this.sub_s16("light_amount",50.0f);
			StartCooldown(this,"heal_cd",8);
		}
	}
}
string light_heal_icon(CBlob @ this){
	return "LightHeal.png";
}


void light_orb(CBlob @ this){
	if(CheckCooldown(this,"orb_cd") == 0){
		if(this.get_s16("light_amount") >= 50){
			if(getNet().isServer()){
				CBlob @lo = server_CreateBlob("lo",this.getTeamNum(),this.getPosition());
				
				if(lo !is null){
					Vec2f vec = this.getAimPos()-this.getPosition();
					CControls @control = this.getControls();
					//if(control !is null)vec = control.getMouseWorldPos()-this.getPosition();
					vec.Normalize();
					lo.setVelocity(vec*2.0f);
				}
			}
			this.sub_s16("light_amount",50.0f/getPowerMod(this,"light"));
			StartCooldown(this,"orb_cd",60*30);
		}
	}
}
string light_orb_icon(CBlob @ this){
	return "lo_icon.png";
}


void light_wisp(CBlob @ this){
	if(CheckCooldown(this,"seeker_cd") == 0){
		if(this.get_s16("light_amount") >= 100){
			if(getNet().isServer()){
				CBlob @lo = server_CreateBlob("lw",this.getTeamNum(),this.getPosition());
				
				if(lo !is null){
					Vec2f vec = this.getAimPos()-this.getPosition();
					CControls @control = this.getControls();
					//if(control !is null)vec = control.getMouseWorldPos()-this.getPosition();
					vec.Normalize();
					lo.setVelocity(vec*1.0f);
				}
			}
			this.sub_s16("light_amount",100.0f/getPowerMod(this,"light"));
			StartCooldown(this,"seeker_cd",60*30);
		}
	}
}
string light_wisp_icon(CBlob @ this){
	return "LightWisp.png";
}

void light_recall(CBlob @ this){
	if(CheckCooldown(this,"recall_cd") == 0){
		if(this.get_s16("light_amount") >= 100){
			if(getLocalPlayerBlob() is this){
				CBlob@[] blobs;	   
				getBlobsByName("altar", @blobs);
				getBlobsByName("gorb", @blobs);
				getBlobsByName("gold_bar", @blobs);
				getBlobsByName("gold_ore", @blobs);
				CBlob @best = null;
				int score = 0;
				for (uint i = 0; i < blobs.length; i++)
				{
					CBlob@ b = blobs[i];
					if(b !is null){
						if(b.getName() == "altar"){
							if(b.get_u8("type") == 1){
								if(20 > score){
									@best = b;
									score = 20;
								}
							}
						}
						if(b.getName() == "gold_bar"){
							if(10 > score){
								@best = b;
								score = 10;
							}
						}
						if(b.getName() == "gold_ore"){
							if(5 > score){
								@best = b;
								score = 5;
							}
						}
						if(b.getName() == "gorb"){
							if(b.get_u16("gold_amount") > score){
								@best = b;
								score = b.get_u16("gold_amount");
							}
						}
					}
				}
				
				if(best !is null){
					this.setPosition(best.getPosition());
				}
			}
			this.sub_s16("light_amount",100.0f/getPowerMod(this,"light"));
			StartCooldown(this,"recall_cd",30);
		}
	}
}
string light_recall_icon(CBlob @ this){
	return "LightRecall.png";
}

void light_invis(CBlob @ this){
	if(isServer()){
		if(CheckCooldown(this,"illusion_cd") == 0){
			if(!this.hasTag("light_invisibility")){
				if(this.get_s16("light_amount") >= 5){
					
					this.Tag("light_invisibility");
					
					this.Sync("light_invisibility",true);
				}
			} else {
				this.Untag("light_invisibility");
				if(isServer()){
					this.Sync("light_invisibility",true);
				}
				StartCooldown(this,"illusion_cd",10*30);
			}
		}
	}
}
string light_invis_icon(CBlob @ this){
	return "LightInvis.png";
}



void light_redemption(CBlob @ this){
	if(CheckCooldown(this,"redemption_cd") == 0){
		if(this.get_s16("light_amount") >= 100){
			if(getNet().isServer()){
				CBlob @lo = server_CreateBlob("rmp",this.getTeamNum(),this.getPosition());
				
				if(lo !is null){
					Vec2f vec = this.getAimPos()-this.getPosition();
					CControls @control = this.getControls();
					//if(control !is null)vec = control.getMouseWorldPos()-this.getPosition();
					vec.Normalize();
					lo.setVelocity(vec*6.0f);
				}
			}
			this.sub_s16("light_amount",100.0f/getPowerMod(this,"light"));
			StartCooldown(this,"redemption_cd",60*30);
		}
	}
}
string light_redemption_icon(CBlob @ this){
	return "LightRedeem.png";
}



void light_infuse(CBlob @this){
	if(this.get_s16("light_amount") >= 100)
	if(CheckCooldown(this,"transfuse_cd") == 0){
		
		CBlob @item = this.getCarriedBlob();

		if(item !is null){
			item.Tag("light_infused");
			item.Untag("death_infused");
			item.Untag("dark_infused");
			item.Untag("cursed");
			
			this.sub_s16("light_amount",100);
			if(getNet().isServer())this.Sync("life_amount", true);
			
			StartCooldown(this,"transfuse_cd",30*5);
		}
	}

}
string light_infuse_icon(CBlob @this){
	return "LightInfuse.png";
}

void light_fish(CBlob @ this){
	if(CheckCooldown(this,"fish_cd") == 0){
		if(this.get_s16("light_amount") >= 500){
			if(getNet().isServer()){
				CBlob @lo = server_CreateBlob("golden_fishy",this.getTeamNum(),this.getPosition());
				
				if(lo !is null){
					Vec2f vec = this.getAimPos()-this.getPosition();
					CControls @control = this.getControls();
					//if(control !is null)vec = control.getMouseWorldPos()-this.getPosition();
					vec.Normalize();
					lo.setVelocity(vec*1.0f);
				}
			}
			this.sub_s16("light_amount",500.0f/getPowerMod(this,"light"));
			StartCooldown(this,"fish_cd",(50*30)/getPowerMod(this,"light"));
		}
	}
}
string light_fish_icon(CBlob @ this){
	return "LightFishy.png";
}