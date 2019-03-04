
#include "Hitters.as";
#include "EquipCommon.as";
#include "HumanoidAnimCommon.as";
#include "SurgeryCommon.as";
#include "Knocked.as";
#include "LimbsCommon.as";
#include "AbilityCommon.as"


void handleDeath(CBlob @ this){
	if(this.hasTag("alive")){
		if(!bodyPartFunctioning(this,"torso") || this.get_s16("blood_amount") <= 0){
			CPlayer @hurter = getPlayerByUsername(this.get_string("last_hurter"));
			
			if(hurter !is null)if(hurter.getBlob() !is null){
				CBlob @hurterblob = hurter.getBlob();
				if(this.get_s16("dark_amount") <= hurterblob.get_s16("dark_amount"))hurterblob.set_s16("dark_amount", hurterblob.get_s16("dark_amount")+90+XORRandom(20));
			}
			
			this.Untag("alive");
			seperateSoul(this,true);
			if(getNet().isServer())if(this.getBrain() !is null)this.getBrain().server_SetActive(false);
		}
	
	}
	
	if(getNet().isServer()){
		if(this.get_s16("life_amount") <= 0 && this.get_s16("death_amount") <= 0){
			this.Untag("soul");
			this.Untag("alive");
			this.server_SetPlayer(null);
			if(getNet().isServer())if(this.getBrain() !is null)this.getBrain().server_SetActive(false);
		}
	}
}

void seperateSoul(CBlob @ this, bool convertLife){
	seperateSoul(this, convertLife, this.getPosition());
}

void seperateSoul(CBlob @ this, bool convertLife, Vec2f position){
	if(getNet().isServer()){
		if(this.getPlayer() !is null){
			CBlob @ghost = server_CreateBlob("humanoid",this.getTeamNum(),position);
			setupBody(ghost,1,1,1,1,1,1);
			
			if(convertLife)ghost.set_s16("death_amount", this.get_s16("death_amount")+Maths::Min(this.get_s16("life_amount")/2,100));
			else ghost.set_s16("death_amount", this.get_s16("death_amount"));
			
			ghost.Sync("death_amount",true);
			ghost.setVelocity(Vec2f(0,-10));
			
			
			for(int i = 1;i <= 9;i++)
			ghost.set_u8("slot_"+i,this.get_u8("slot_"+i));
			
			StartCooldown(ghost,"possess_cd",30);
			
			
			ghost.server_SetPlayer(this.getPlayer());
			ghost.set_string("player_name",this.get_string("player_name"));
			ghost.Tag("soul");
			
			ghost.set_u8("hair_index",this.get_u8("hair_index"));
			ghost.set_u8("hair_colour",this.get_u8("hair_colour"));
			ghost.Sync("hair_index",true);
			ghost.Sync("hair_colour",true);
			
			this.set_string("player_name","");
			this.server_SetPlayer(null);
			this.server_setTeamNum(-1);
		} else {
			if(this.getBrain() !is null)this.getBrain().server_SetActive(false);
		}
		
		if(convertLife){
			this.set_s16("death_amount", Maths::Min(this.get_s16("life_amount")/2,100));
			this.sub_s16("life_amount", Maths::Min(this.get_s16("life_amount"),200));
			if(this.get_s16("life_amount") > 0){
				int life = this.get_s16("life_amount")/10;
				for(int i = 0;i < life;i++){
					CBlob @e = server_CreateBlob("e",-1,this.getPosition());
					if(e !is null){
						e.setVelocity(Vec2f(XORRandom(31)-15,XORRandom(31)-15)/20);
						e.set_u8("worth",10);
						e.set_u16("created",getGameTime()+120+XORRandom(120));
					}
				}
			}
		} else {
			this.set_s16("death_amount", 0);
		}
		this.Sync("death_amount",true);
		this.Sync("life_amount",true);
		this.Untag("soul");
	}
}

void setupBody(CBlob @ this, int Head, int Torso, int MArm, int SArm, int FLeg, int BLeg){

	this.set_s8("head_type",Head);
	this.set_s8("torso_type",Torso);
	this.set_s8("main_arm_type",MArm);
	this.set_s8("sub_arm_type",SArm);
	this.set_s8("front_leg_type",FLeg);
	this.set_s8("back_leg_type",BLeg);
	
	if(Head == BodyType::Ghost || Head == BodyType::Wraith){
		this.Tag("death_knowledge");
		this.Tag("death_sight");
		
		this.getSprite().AddScript("GhostBlur.as");
	}
	
	if(isFlesh(Head)){
		this.Tag("eat_ability");
	}
	
	if(isFlesh(Torso)){
		this.Tag("alive");
		this.Tag("flesh");
		this.set_s16("life_amount", 20);
		
		this.set_s16("blood_amount", 80+XORRandom(20));
	}
	
	if(Torso == BodyType::Gold){
		this.set_s16("life_amount", 20);
	}
	if(Head == BodyType::Gold){
		this.set_u8("light_eyes", 2);
	}
	
	if(Torso == BodyType::Ghost){
		this.Tag("ghost");
	}
	
	if(Torso == BodyType::Ghost || Torso == BodyType::Wraith){
		this.Untag("flesh");
		this.set_s16("death_amount", 50+XORRandom(50));
	}
	
	if(Torso == BodyType::Shadow){
		this.set_s16("life_amount", 20);
	}
	
	this.set_f32("torso_hp",bodyPartMaxHealth(Torso,"torso"));
	this.set_f32("main_arm_hp",bodyPartMaxHealth(MArm,"main_arm"));
	this.set_f32("sub_arm_hp",bodyPartMaxHealth(SArm,"sub_arm"));
	this.set_f32("front_leg_hp",bodyPartMaxHealth(FLeg,"front_leg"));
	this.set_f32("back_leg_hp",bodyPartMaxHealth(BLeg,"back_leg"));
	
	this.set_f32("torso_hit",0.0f);
	this.set_f32("main_arm_hit",0.0f);
	this.set_f32("sub_arm_hit",0.0f);
	this.set_f32("front_leg_hit",0.0f);
	this.set_f32("back_leg_hit",0.0f);
	
	this.set_s8("sperm_head_type",Head);
	this.set_s8("sperm_torso_type",Torso);
	this.set_s8("sperm_main_arm_type",MArm);
	this.set_s8("sperm_sub_arm_type",SArm);
	this.set_s8("sperm_front_leg_type",FLeg);
	this.set_s8("sperm_back_leg_type",BLeg);
	
	this.set_s8("egg_head_type",Head);
	this.set_s8("egg_torso_type",Torso);
	this.set_s8("egg_main_arm_type",MArm);
	this.set_s8("egg_sub_arm_type",SArm);
	this.set_s8("egg_front_leg_type",FLeg);
	this.set_s8("egg_back_leg_type",BLeg);
	
	if(getNet().isServer()){
		this.SendCommand(this.getCommandID("force_reload"));
	}
}

void equipItem(CBlob @ this, CBlob @ item, string slot){

	if(this !is null && item !is null){

		CBlob @equiped = getEquippedBlob(this,slot);
		
		if(equiped !is null)if(equiped.hasTag("cursed")){
			item.server_Die();
			return;
		}
		
		if(equiped !is null && getNet().isServer()){
			this.server_PutOutInventory(equiped);
			equiped.Untag(slot);
			equiped.Sync(slot,true);
		}
		item.Tag(slot);
		item.Tag("equiptag");
		if(getNet().isServer())item.Sync(slot,true);
		
		item.SetDamageOwnerPlayer(this.getPlayer());
		
		this.Tag("reload sprites");
		if(getNet().isServer())this.Sync("reload sprites",true);
		
		this.server_PutInInventory(item);
	}
}

void equipItemTemp(CBlob @ this, CBlob @ item, string slot){

	if(getNet().isServer())item.server_SetTimeToDie(1);
	if(getEquippedBlob(this,slot) !is null){
		if(getEquippedBlob(this,slot).getName() == item.getName()){
			if(getNet().isServer())item.server_Die();
			return;
		}
	}
	equipItem(this,item,slot);
}

bool canResist(CBlob @ this){

	if(!isConscious(this))return false;
	
	if(this.hasTag("no hands"))return false;
	//if(getKnocked(this) > 0)return false;
	
	return true;
}

bool isConscious(CBlob @ this){

	bool activity = false;

	if(this.getPlayer() !is null)activity = true;
	if(this.getBrain() !is null)if(this.getBrain().isActive())activity = true;
	
	if(!bodyPartFunctioning(this, "torso"))activity = false;
	
	if(this.get_s8("torso_type") == BodyType::Ghost)activity = true;
	
	return activity;
}

f32 getAimAngle(CBlob @this){
	Vec2f vec = this.getAimPos() - this.getPosition();
	return vec.Angle();

}

void hitBodyPart(CBlob@ this, string limb, f32 damage, u8 hitter){
	
	//print("Hit "+limb+" for "+damage+" damage.");
	
	if(!getNet().isServer())return;
	if(damage <= 0.0f)return;
	
	bool Delimb = false;
	
	int Type = this.get_s8(limb+"_type");
	
	if(isExplosionHitter(hitter) && damage > 15.0f)Delimb = true;
	if(isSharp(hitter) && damage*10.0f > XORRandom(200))Delimb = true;
	
	if(limb != "torso" && Delimb && canDelimb(this,limb)){ //Delimbment
		if((this.get_f32(limb+"_hp")-damage) <= bodyPartGibHealth(Type,limb)){
			gibLimb(this,limb);
		} else {
			this.set_f32(limb+"_hp",this.get_f32(limb+"_hp")-damage);
			severLimb(this, limb);
		}
	} else {
	
		if((this.get_f32(limb+"_hp")-damage) <= bodyPartGibHealth(Type,limb)){
			gibLimb(this,limb);
		} else {
			this.set_f32(limb+"_hp",this.get_f32(limb+"_hp")-damage);
		}
	}
	
	if(XORRandom(100) == 0)
	if(limb == "torso" && (hitter == Hitters::fire || hitter == Hitters::burn)){
		if(this.get_u8("eyes") > 0){
			this.set_u8("eyes",this.get_u8("eyes")-1);
			this.set_u8("burnt_eyes",this.get_u8("burnt_eyes")+1);
			this.Sync("eyes",true);
			this.Sync("burnt_eyes",true);
		}
	}
	
	if(isSlashDamage(hitter)){
		if(bodyTypeBleeds(Type))
			this.set_f32("bleed",this.get_f32("bleed")+(damage));
	}
	if(isPierceDamage(hitter)){
		if(bodyTypeBleeds(Type))
			this.set_f32("bleed",this.get_f32("bleed")+(damage*2.0f));
	}
	
	this.Sync(limb+"_hp",true);
	this.Sync(limb+"_type",true);
	this.Sync("bleed",true);
	this.set_f32(limb+"_hit",1.0f);
	this.Sync(limb+"_hit",true);
	server_ManualSync(this,limb);
}

int HealBody(CBlob@ this, int heal, bool restore = false){
	
	//print("Hit "+limb+" for "+damage+" damage.");
	
	int heals = 0;

	for(int i = 0;i < heal;i++){
		string limb = "torso";
		float HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		
		if(this.get_f32("main_arm_hp")/bodyPartMaxHealth(this.get_s8("main_arm_type"),"main_arm") < HP && (canBeHealed(this.get_s8("main_arm_type")) || restore)){
			limb = "main_arm";
			HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		}
		if(this.get_f32("sub_arm_hp")/bodyPartMaxHealth(this.get_s8("sub_arm_type"),"sub_arm") < HP && (canBeHealed(this.get_s8("sub_arm_type")) || restore)){
			limb = "sub_arm";
			HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		}
		if(this.get_f32("front_leg_hp")/bodyPartMaxHealth(this.get_s8("front_leg_type"),"front_leg") < HP && (canBeHealed(this.get_s8("front_leg_type")) || restore)){
			limb = "front_leg";
			HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		}
		if(this.get_f32("back_leg_hp")/bodyPartMaxHealth(this.get_s8("back_leg_type"),"back_leg") < HP && (canBeHealed(this.get_s8("back_leg_type")) || restore)){
			limb = "back_leg";
			HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		}

		if(this.get_f32(limb+"_hp") < bodyPartMaxHealth(this.get_s8(limb+"_type"),limb) && (canBeHealed(this.get_s8(limb+"_type")) || restore)){
			this.set_f32(limb+"_hp",this.get_f32(limb+"_hp")+1);
			
			heals += 1;
			//print("healed limb: "+limb+" for "+heal+" HP.");
			
			if(getNet().isServer()){
				this.Sync(limb+"_hp",true);
				//this.Sync(limb+"_type",true);
				server_ManualSync(this,limb);
			}
		}
	}
	
	return heals;
}

f32 BodyMaxHp(CBlob @this){
	f32 hp = 0.0f;
	
	hp += bodyPartMaxHealth(this.get_s8("torso_type"),"torso");
	hp += bodyPartMaxHealth(this.get_s8("main_arm_type"),"main_arm");
	hp += bodyPartMaxHealth(this.get_s8("sub_arm_type"),"sub_arm");
	hp += bodyPartMaxHealth(this.get_s8("front_leg_type"),"front_leg");
	hp += bodyPartMaxHealth(this.get_s8("back_leg_type"),"back_leg");
	
	return hp;
}

f32 BodyCurrentHp(CBlob @this){
	f32 hp = 0.0f;
	
	hp += this.get_f32("torso_hp");
	hp += this.get_f32("main_arm_hp");
	hp += this.get_f32("sub_arm_hp");
	hp += this.get_f32("front_leg_hp");
	hp += this.get_f32("back_leg_hp");
	
	return hp;
}

void StarveBody(CBlob@ this, int starve){
	
	//print("Hit "+limb+" for "+damage+" damage.");

	for(int i = 0;i < starve;i++){
		string limb = "torso";
		float HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		
		if(this.get_f32("main_arm_hp")/bodyPartMaxHealth(this.get_s8("main_arm_type"),"main_arm") > HP && canBeHealed(this.get_s8("main_arm_type"))){
			limb = "main_arm";
			HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		}
		if(this.get_f32("sub_arm_hp")/bodyPartMaxHealth(this.get_s8("sub_arm_type"),"sub_arm") > HP && canBeHealed(this.get_s8("sub_arm_type"))){
			limb = "sub_arm";
			HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		}
		if(this.get_f32("front_leg_hp")/bodyPartMaxHealth(this.get_s8("front_leg_type"),"front_leg") > HP && canBeHealed(this.get_s8("front_leg_type"))){
			limb = "front_leg";
			HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		}
		if(this.get_f32("back_leg_hp")/bodyPartMaxHealth(this.get_s8("back_leg_type"),"back_leg") > HP && canBeHealed(this.get_s8("back_leg_type"))){
			limb = "back_leg";
			HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this.get_s8(limb+"_type"),limb);
		}

		if(this.get_f32(limb+"_hp") > 0){
			this.set_f32(limb+"_hp",this.get_f32(limb+"_hp")-1);
			if(this.get_f32(limb+"_hp") > bodyPartMaxHealth(this.get_s8(limb+"_type"),limb))this.set_f32(limb+"_hp",bodyPartMaxHealth(this.get_s8(limb+"_type"),limb));
			//print("healed limb: "+limb+" for "+starve+" HP.");
			
			if(getNet().isServer()){
				this.Sync(limb+"_hp",true);
				server_ManualSync(this,limb);
			}
		}
	}
}


void gibLimb(CBlob@ this, string limb){
	//print(limb+" was gibbed!");
	if(this.hasTag("flesh"))this.getSprite().PlaySound("gib"+XORRandom(3));
	
	dropItem(this,limb);
	
	if(limb == "torso"){
		if(!this.hasTag("gibbed"))
		if(getNet().isServer()){
			severLimb(this,"main_arm");
			severLimb(this,"sub_arm");
			severLimb(this,"front_leg");
			severLimb(this,"back_leg");

			if(isFlesh(this.get_s8("torso_type")))this.getSprite().Gib();
			this.Tag("gibbed");
			this.server_Die();
		}
	} else {
		if(bodyTypeBleeds(this.get_s8(limb+"_type")))this.set_f32("bleed",this.get_f32("bleed")+40.0f);
		
		this.set_f32(limb+"_hp",0);
		this.set_s8(limb+"_type",-1);
	}
}

void severLimb(CBlob@ this, string limb){
	if(bodyPartExists(this,limb)){
		if(this.get_f32(limb+"_hp") > 0)
		if(getNet().isServer()){
			
			CBlob @limblob = server_CreateBlob(BodyTypeToBlobName(this.get_s8(limb+"_type"), limb),-1,this.getPosition());
			limblob.server_SetHealth(this.get_f32(limb+"_hp"));
		}
		
		if(bodyTypeBleeds(this.get_s8(limb+"_type")))this.set_f32("bleed",this.get_f32("bleed")+40.0f);
		
		this.set_f32(limb+"_hp",0);
		this.set_s8(limb+"_type",-1);
		
		dropItem(this,limb);
		
		this.getSprite().PlaySound("dismember"+XORRandom(3));
	}
	
	reloadSpriteBody(this.getSprite(),this);
}

void attachLimb(CBlob@ this, string limb, int type, float hp){

	
	attachLimb(this, limb, type);
	this.set_f32(limb+"_hp",hp);
	
	if(getNet().isServer()){
		this.Sync(limb+"_hp",true);
		server_ManualSync(this,limb);
	}
	
	
	reloadSpriteBody(this.getSprite(),this);
	
}

void attachLimb(CBlob@ this, string limb, int type){

	this.set_s8(limb+"_type",type);
	this.set_f32(limb+"_hp",bodyPartMaxHealth(type,limb));
	
	if(getNet().isServer()){
		this.Sync(limb+"_hp",true);
		this.Sync(limb+"_type",true);
		server_ManualSync(this,limb);
	}
	
	reloadSpriteBody(this.getSprite(),this);
	
}

void dropItem(CBlob@ this, string limb){
	if(limb == "main_arm"){
		CBlob @item = getEquippedBlob(this,"main_arm");
		if(item !is null && getNet().isServer()){
			this.server_PutOutInventory(item);
			item.Untag("main_arm");
			item.Sync("main_arm",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
	}
	if(limb == "sub_arm"){
		CBlob @item = getEquippedBlob(this,"sub_arm");
		if(item !is null && getNet().isServer()){
			this.server_PutOutInventory(item);
			item.Untag("sub_arm");
			item.Sync("sub_arm",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
	}
	
	ReloadEquipment(this.getSprite(),this);
}

f32 getWalkSpeed(CBlob@ this){

	f32 Speed = 0.0f;

	if(bodyPartFunctioning(this, "front_leg"))Speed += getLegSpeed(this.get_s8("front_leg_type"));
	if(bodyPartFunctioning(this, "back_leg"))Speed += getLegSpeed(this.get_s8("back_leg_type"));

	//Should probably add crutches in here
	
	if(Speed == 0){ //If both our legs are broken, we crawl with our arms
		if(bodyPartFunctioning(this, "main_arm"))Speed += 0.2;
		if(bodyPartFunctioning(this, "sub_arm"))Speed += 0.2;
	}

	return Speed;
}

f32 getStrength(CBlob@ this, string limb){

	f32 str = 1.0f;
	
	if(this.hasTag("hemoric_strength")){
		str = 1.5f;
	}
	///Todo, give limbs different strength values
	
	return str;
}


void massSync(CBlob @this){
	if(getNet().isServer()){
		server_ManualSync(this,"main_arm");
		server_ManualSync(this,"sub_arm");
		server_ManualSync(this,"front_leg");
		server_ManualSync(this,"back_leg");
		server_ManualSync(this,"torso");
		
		this.Sync("head_type",true);
		
		//this.SendCommand(this.getCommandID("force_reload"));
	}
}

void server_ManualSync(CBlob @this,string limb){

	if(getNet().isServer()){

		CBitStream params;

		if(limb == "main_arm"){
			params.write_u8(1); //Limb
			params.write_s8(this.get_s8("main_arm_type")); //Type
			params.write_f32(this.get_f32("main_arm_hp")); //Health
		} else
		if(limb == "sub_arm"){
			params.write_u8(2); //Limb
			params.write_s8(this.get_s8("sub_arm_type")); //Type
			params.write_f32(this.get_f32("sub_arm_hp")); //Health
		} else
		if(limb == "front_leg"){
			params.write_u8(3); //Limb
			params.write_s8(this.get_s8("front_leg_type")); //Type
			params.write_f32(this.get_f32("front_leg_hp")); //Health
		} else
		if(limb == "back_leg"){
			params.write_u8(4); //Limb
			params.write_s8(this.get_s8("back_leg_type")); //Type
			params.write_f32(this.get_f32("back_leg_hp")); //Health
		} else
		if(limb == "torso"){
			params.write_u8(5); //Limb
			params.write_s8(this.get_s8("torso_type")); //Type
			params.write_f32(this.get_f32("torso_hp")); //Health
		} else {
			params.write_u8(0); //Limb
			params.write_s8(0); //Type
			params.write_f32(0.0f); //Health
		}

		
		this.SendCommand(this.getCommandID("manual_sync"),params);
	
	} else {
		print("Can't manual sync on client!");
	}



}