

#include "Fabrics.as";
#include "AbilityCommon.as"
#include "eleven.as"
#include "HumanoidCommon.as"
#include "ep.as"

void dark_blade(CBlob @ this){
	if(CheckCooldown(this,"blade_cd") == 0){
		if(this.get_s16("dark_amount") >= 100){
			if(getNet().isServer()){
				CBlob @blade = server_CreateBlob("sword",this.getTeamNum(),this.getPosition());
				
				if(blade !is null){
					blade.set_u8("fabric",FabricID::Dark);
				}
			}
			this.sub_s16("dark_amount",100.0f/getPowerMod(this,"dark"));
			StartCooldown(this,"blade_cd",60*30);
		}
	}
}
string dark_blade_icon(CBlob @ this){
	return "DarkBlade.png";
}

void dark_growth(CBlob @ this){
	if(this.get_s16("dark_amount") >= 50){
		if(CheckCooldown(this,"restore_cd") == 0){
			int MArm = this.get_s8("main_arm_type");
			int SArm = this.get_s8("sub_arm_type");
			int FLeg = this.get_s8("front_leg_type");
			int Bleg = this.get_s8("back_leg_type");
			
			if(MArm == -1){
				attachLimb(this,"main_arm",BodyType::Shadow);
				this.sub_s16("dark_amount",50);
			}
			else if(SArm == -1){
				attachLimb(this,"sub_arm",BodyType::Shadow);
				this.sub_s16("dark_amount",50);
			}
			else if(FLeg == -1){
				attachLimb(this,"front_leg",BodyType::Shadow);
				this.sub_s16("dark_amount",50);
			}
			else if(Bleg == -1){
				attachLimb(this,"back_leg",BodyType::Shadow);
				this.sub_s16("dark_amount",50);
			}
			
			if(getNet().isServer())this.Sync("dark_amount",true);
		
			StartCooldown(this,"restore_cd",30*5);
		}
	}
}
string dark_growth_icon(CBlob @ this){
	return "DarkRegrowth.png";
}

void dark_recall(CBlob @ this){
	if(CheckCooldown(this,"recall_cd") == 0){
		if(this.get_s16("dark_amount") >= 20.0f/getPowerMod(this,"dark")){
			int i = 0;
			CMap @map = getMap();
			while(i < 1000){
				Vec2f pos = Vec2f(XORRandom(map.tilemapwidth)*8,XORRandom(map.tilemapheight-5)*8);
				Tile t = map.getTile(pos);
				if(t.light < 60 && !map.isTileSolid(pos) && !map.isInWater(pos)){
					this.setPosition(pos);
					break;
				}
				i++;
			}
			
			this.sub_s16("dark_amount",20.0f/getPowerMod(this,"dark"));
			StartCooldown(this,"recall_cd",(10.0f*30.0f)/getPowerMod(this,"dark"));
		}
	}
}
string dark_recall_icon(CBlob @ this){
	return "DarkRecall.png";
}

void dark_fade(CBlob @ this){
	if(CheckCooldown(this,"fade_cd") == 0){
		if(!this.hasTag("dark_fade")){
			if(this.get_s16("dark_amount") > 10){
				this.Tag("dark_fade");
				this.set_u32("dark_fade_start",getGameTime());
				this.sub_s16("dark_amount",10);
				if(isServer()){
					this.Sync("dark_fade",true);
					this.Sync("dark_fade_start",true);
				}
			}
		}
	}
}
string dark_fade_icon(CBlob @ this){
	return "DarkFade.png";
}

void dark_pearl(CBlob @ this){
	if(CheckCooldown(this,"orb_cd") == 0){
		if(this.get_s16("dark_amount") >= 100){
			if(getNet().isServer()){
				CBlob @orb = server_CreateBlob("co",this.getTeamNum(),this.getPosition());
				
				if(orb !is null){
					orb.set_u8("fabric",FabricID::Dark);
				}
			}
			this.sub_s16("dark_amount",100.0f);
			StartCooldown(this,"orb_cd",10*30);
		}
	}
}
string dark_pearl_icon(CBlob @ this){
	return "DarkPearl.png";
}

void dark_infuse(CBlob @ this){
	if(this.get_s16("dark_amount") >= 100){
		if(CheckCooldown(this,"transfuse_cd") == 0){
			
			CBlob @item = this.getCarriedBlob();

			if(item !is null && !item.hasScript("crpting.as")){
				item.AddScript("crpting.as");
				
				this.sub_s16("dark_amount",100);
				if(getNet().isServer()){
					this.Sync("dark_amount", true);
				}
				
				StartCooldown(this,"transfuse_cd",30*5);
			}
		}
	}
}
string dark_infuse_icon(CBlob @ this){
	return "DarkInfuse.png";
}