
#include "Hitters.as";
#include "EquipCommon.as";
#include "HumanoidAnimCommon.as";
#include "SurgeryCommon.as";

namespace BodyType
{
	enum type
	{
		Flesh = 0,
		Ghost,
		Peg
	};
}

void handleDeath(CBlob @ this){
	if(!bodyPartFunctioning(this,"torso") && this.get_s8("torso_type") != 1){
		seperateSoul(this);
	}
}

void seperateSoul(CBlob @ this){
	seperateSoul(this,this.getPosition());
}

void seperateSoul(CBlob @ this, Vec2f position){
	if(getNet().isServer()){
		if(this.getPlayer() !is null){
			CBlob @ghost = server_CreateBlob("humanoid",this.getTeamNum(),position);
			setupBody(ghost,1,1,1,1,1,1);
			ghost.Untag("flesh");
			ghost.Tag("ghost");
			
			ghost.server_SetPlayer(this.getPlayer());
			ghost.set_string("player_name",this.get_string("player_name"));
			this.set_string("player_name","");
			this.server_SetPlayer(null);
		}
		
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
	
	this.set_f32("torso_hp",bodyPartMaxHealth(this,"torso"));
	this.set_f32("main_arm_hp",bodyPartMaxHealth(this,"main_arm"));
	this.set_f32("sub_arm_hp",bodyPartMaxHealth(this,"sub_arm"));
	this.set_f32("front_leg_hp",bodyPartMaxHealth(this,"front_leg"));
	this.set_f32("back_leg_hp",bodyPartMaxHealth(this,"back_leg"));
	
	this.set_f32("limb_hit",0.0f);
	this.set_f32("main_arm_hit",0.0f);
	this.set_f32("sub_arm_hit",0.0f);
	this.set_f32("front_leg_hit",0.0f);
	this.set_f32("back_leg_hit",0.0f);
}

bool canResist(CBlob @ this){

	if(!isConscious(this))return false;
	
	if(!bodyPartFunctioning(this,"main_arm") && !bodyPartFunctioning(this,"sub_arm"))return false;
	
	return true;
}

bool isConscious(CBlob @ this){

	if(this.getPlayer() is null)return false;
	
	return true;
}

f32 getAimAngle(CBlob @this){

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f vec = aimpos - pos;
	return vec.Angle();

}

bool bodyPartFunctioning(CBlob@ this, string limb){
	return (this.get_s8(limb+"_type") > -1) && (this.get_f32(limb+"_hp") > 0.0f  && this.get_s8(limb+"_type") != 1);
}

bool bodyPartExists(CBlob@ this, string limb){
	return this.get_s8(limb+"_type") > -1 && this.get_s8(limb+"_type") != 1;
}

bool armCanGrapple(CBlob@ this, string limb){
	
	if(this.get_s8(limb+"_type") == BodyType::Peg)return false;
	
	return bodyPartFunctioning(this,limb);
}

bool canHitLimb(CBlob@ this, string limb){
	return (this.get_s8(limb+"_type") > -1) && this.get_s8(limb+"_type") != 1;
}

bool isSharp(u8 customData){
	if(customData == Hitters::sword || customData == Hitters::saw || customData == Hitters::spikes || customData == Hitters::stab || customData == Hitters::builder)return true;
	return false;
}

void hitBodyPart(CBlob@ this, string limb, f32 damage, u8 hitter){
	
	//print("Hit "+limb+" for "+damage+" damage.");
	
	bool Delimb = false;
	
	if(isExplosionHitter(hitter) && damage > 15.0f)Delimb = true;
	if(isSharp(hitter) && damage*10.0f > XORRandom(200))Delimb = true;
	
	if(limb != "torso" && Delimb){ //Delimbment
		if((this.get_f32(limb+"_hp")-damage) <= bodyPartGibHealth(this,limb)){
			gibLimb(this,limb);
		} else {
			this.set_f32(limb+"_hp",this.get_f32(limb+"_hp")-damage);
			severLimb(this, limb);
		}
	} else {
	
		if((this.get_f32(limb+"_hp")-damage) <= bodyPartGibHealth(this,limb)){
			gibLimb(this,limb);
		} else {
			this.set_f32(limb+"_hp",this.get_f32(limb+"_hp")-damage);
		}
	
	}
	
	this.set_f32(limb+"_hit",1);//Red GUI flash

	if(getNet().isServer()){
		this.Sync(limb+"_hp",true);
		this.Sync(limb+"_hit",true);
		this.Sync(limb+"_type",true);
	}
}

void HealBody(CBlob@ this, int heal){
	
	//print("Hit "+limb+" for "+damage+" damage.");
	
	
	
	string limb = "torso";
	float HP = this.get_f32(limb+"_hp")/bodyPartMaxHealth(this,limb);
	
	if(this.get_f32("main_arm_hp")/bodyPartMaxHealth(this,"main_arm") < HP && bodyPartFunctioning(this,"main_arm")){
		HP = this.get_f32("main_arm_hp")/bodyPartMaxHealth(this,"main_arm");
		limb = "main_arm";
	}
	if(this.get_f32("sub_arm_hp")/bodyPartMaxHealth(this,"sub_arm") < HP && bodyPartFunctioning(this,"sub_arm")){
		HP = this.get_f32("sub_arm_hp")/bodyPartMaxHealth(this,"sub_arm");
		limb = "sub_arm";
	}
	if(this.get_f32("front_leg_hp")/bodyPartMaxHealth(this,"front_leg") < HP && bodyPartFunctioning(this,"front_leg")){
		HP = this.get_f32("front_leg_hp")/bodyPartMaxHealth(this,"front_leg");
		limb = "front_leg";
	}
	if(this.get_f32("back_leg_hp")/bodyPartMaxHealth(this,"back_leg") < HP && bodyPartFunctioning(this,"back_leg")){
		HP = this.get_f32("back_leg_hp")/bodyPartMaxHealth(this,"back_leg");
		limb = "back_leg";
	}

	this.set_f32(limb+"_hp",this.get_f32(limb+"_hp")+heal);
	if(this.get_f32(limb+"_hp") > bodyPartMaxHealth(this,limb))this.set_f32(limb+"_hp",bodyPartMaxHealth(this,limb));
	
	print("healed limb: "+limb+" for "+heal+" HP.");
	
	if(getNet().isServer()){
		this.Sync(limb+"_hp",true);
		//this.Sync(limb+"_type",true);
	}
}

void gibLimb(CBlob@ this, string limb){
	//print(limb+" was gibbed!");
	this.set_f32(limb+"_hp",0);
	this.set_s8(limb+"_type",-1);
	
	this.getSprite().PlaySound("gib"+XORRandom(3));
	
	dropItem(this,limb);
	
	if(getNet().isServer()){
		if(limb == "torso"){
			
			if(canHitLimb(this,"main_arm")){
				CBlob @limblob = server_CreateBlob("main_arm",-1,this.getPosition());
				if(limblob !is null)limblob.set_s8("type",this.get_s8("main_arm_type"));
			}
			if(canHitLimb(this,"sub_arm")){
				CBlob @limblob = server_CreateBlob("sub_arm",-1,this.getPosition());
				if(limblob !is null)limblob.set_s8("type",this.get_s8("sub_arm_type"));
			}
			if(canHitLimb(this,"front_leg")){
				CBlob @limblob = server_CreateBlob("front_leg",-1,this.getPosition());
				if(limblob !is null)limblob.set_s8("type",this.get_s8("front_leg_type"));
			}
			if(canHitLimb(this,"back_leg")){
				CBlob @limblob = server_CreateBlob("back_leg",-1,this.getPosition());
				if(limblob !is null)limblob.set_s8("type",this.get_s8("back_leg_type"));
			}
			
			seperateSoul(this);
			this.getSprite().Gib();
			this.server_Die();
		}
	}
}

void severLimb(CBlob@ this, string limb){
	if(bodyPartExists(this,limb)){
		if(this.get_f32(limb+"_hp") > 0)
		if(getNet().isServer()){
			
			CBlob @limblob = server_CreateBlob(BodyTypeToBlobName(this.get_s8(limb+"_type"), limb),-1,this.getPosition());
			limblob.server_SetHealth(this.get_f32(limb+"_hp"));
		}
		
		this.set_f32(limb+"_hp",0);
		this.set_s8(limb+"_type",-1);
		
		if(getNet().isServer()){
			this.Sync(limb+"_hp",true);
			this.Sync(limb+"_type",true);
		}
		
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
	}
	
	reloadSpriteBody(this.getSprite(),this);
	
}

void attachLimb(CBlob@ this, string limb, int type){

	this.set_s8(limb+"_type",type);
	this.set_f32(limb+"_hp",bodyPartMaxHealth(this,limb));
	
	if(getNet().isServer()){
		this.Sync(limb+"_hp",true);
		this.Sync(limb+"_type",true);
	}
	
	reloadSpriteBody(this.getSprite(),this);
	
}

void dropItem(CBlob@ this, string limb){
	if(limb == "main_arm"){
		CBlob @item = getEquippedBlob(this,"main_arm");
		if(item !is null && getNet().isServer()){
			this.server_PutOutInventory(item);
			item.Untag("main_arm");
			this.set_string("equipment_main_arm_name","");
			
			item.Sync("main_arm",true);
			this.Sync("equipment_main_arm_name",true);
			
			this.Tag("reload sprites");
			this.Sync("reload sprites",true);
		}
	}
	if(limb == "sub_arm"){
		CBlob @item = getEquippedBlob(this,"sub_arm");
		if(item !is null && getNet().isServer()){
			this.server_PutOutInventory(item);
			item.Untag("sub_arm");
			this.set_string("equipment_sub_arm_name","");
			
			item.Sync("sub_arm",true);
			this.Sync("equipment_sub_arm_name",true);
			
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
		if(bodyPartFunctioning(this, "main_arm"))Speed += 0.1;
		if(bodyPartFunctioning(this, "sub_arm"))Speed += 0.1;
	}

	return Speed;
}

f32 getLegSpeed(int type){

	if(type == BodyType::Flesh){
		return 0.5;
	}
	
	if(type == BodyType::Peg){
		return 0.3;
	}

	return 0.0f;
}

bool canStand(CBlob@ this){

	if(bodyPartFunctioning(this, "front_leg") && bodyPartFunctioning(this, "back_leg"))return true;
	
	if(this.get_s8("front_leg_type") == 1 || this.get_s8("back_leg_type") == 1)return true;
	
	if(bodyPartFunctioning(this, "front_leg") && bodyPartExists(this,"back_leg"))return true;
	
	if(bodyPartFunctioning(this, "back_leg") && bodyPartExists(this,"front_leg"))return true;
	//Should probably add crutches in here

	return false;
}

f32 getJumpMulti(CBlob@ this){

	f32 Jump = 1.0f;

	if(!bodyPartFunctioning(this, "front_leg") || !bodyPartFunctioning(this, "back_leg"))Jump = 0.5f;
	
	if(!canStand(this))Jump = 0.4f;

	return Jump;
}

///////////I should probably make a file that stores body part stats like hp, use, ect

f32 bodyPartMaxHealth(CBlob@ this, string limb){

	if(limb == "torso"){
		int TorsoType = this.get_s8("torso_type");
		
		if(TorsoType < 0)return -1.0f;
		
		if(TorsoType == BodyType::Peg)return 50.0f;
		
		return 25.0f;
	}
		
	if(limb == "main_arm"){
		int MainArmType = this.get_s8("main_arm_type");
	
		if(MainArmType < 0)return -1.0f;
	
		if(MainArmType == BodyType::Peg)return 30.0f;
	
		return 15.0f;
	}
	
	if(limb == "sub_arm"){
		int SubArmType = this.get_s8("sub_arm_type");
		
		if(SubArmType < 0)return -1.0f;
	
		if(SubArmType == BodyType::Peg)return 30.0f;
	
		return 15.0f;
	}
	
	if(limb == "front_leg"){
		int FrontLegType = this.get_s8("front_leg_type");
		
		if(FrontLegType < 0)return -1.0f;
		
		if(FrontLegType == BodyType::Peg)return 40.0f;
		
		return 20.0f;
	}
	
	if(limb == "back_leg"){
		int BackLegType = this.get_s8("back_leg_type");
		
		if(BackLegType < 0)return -1.0f;
	
		if(BackLegType == BodyType::Peg)return 40.0f;
		
		return 20.0f;
	}

	return 1.0f;
}

f32 bodyPartGibHealth(CBlob@ this, string limb){

	if(limb == "torso"){
		int TorsoType = this.get_s8("torso_type");
		
		if(TorsoType < 0)return 0;
		
		if(TorsoType == BodyType::Peg)return 0;
		
		return -15.0f;
	}
		
	if(limb == "main_arm"){
		int MainArmType = this.get_s8("main_arm_type");
	
		if(MainArmType < 0)return 0;
	
		if(MainArmType == BodyType::Peg)return 0;
		
		return -5.0f;
	}
	
	if(limb == "sub_arm"){
		int SubArmType = this.get_s8("sub_arm_type");
		
		if(SubArmType < 0)return 0;
	
		if(SubArmType == BodyType::Peg)return 0;
		
		return -5.0f;
	}
	
	if(limb == "front_leg"){
		int FrontLegType = this.get_s8("front_leg_type");
		
		if(FrontLegType < 0)return 0;
		
		if(FrontLegType == BodyType::Peg)return 0;
		
		return -10.0f;
	}
	
	if(limb == "back_leg"){
		int BackLegType = this.get_s8("back_leg_type");
		
		if(BackLegType < 0)return 0;
		
		if(BackLegType == BodyType::Peg)return 0;
		
		return -10.0f;
	}

	return 0.0f;
}

bool bodyPartNeedsBreath(CBlob@ this, string limb){

	if(limb == "torso"){
		int TorsoType = this.get_s8("torso_type");
		
		if(TorsoType == 0)return true;
		
		return false;
	}
		
	if(limb == "main_arm"){
		int MainArmType = this.get_s8("main_arm_type");
	
		return false;
	}
	
	if(limb == "sub_arm"){
		int SubArmType = this.get_s8("sub_arm_type");
	
		return false;
	}
	
	if(limb == "front_leg"){
		int FrontLegType = this.get_s8("front_leg_type");
	
		return false;
	}
	
	if(limb == "back_leg"){
		int BackLegType = this.get_s8("back_leg_type");
	
		return false;
	}

	return false;
}

void massSync(CBlob @this){
	if(getNet().isServer()){
		this.Sync("front_leg_hp",true);
		this.Sync("front_leg_hit",true);
		this.Sync("front_leg_type",true);
		
		this.Sync("back_leg_hp",true);
		this.Sync("back_leg_hit",true);
		this.Sync("back_leg_type",true);
		
		this.Sync("main_arm_hp",true);
		this.Sync("main_arm_hit",true);
		this.Sync("main_arm_type",true);
		
		this.Sync("sub_arm_hp",true);
		this.Sync("sub_arm_hit",true);
		this.Sync("sub_arm_type",true);
		
		this.Sync("torso_hp",true);
		this.Sync("torso_hit",true);
		this.Sync("torso_type",true);
		
		this.Sync("head_type",true);
		
		this.SendCommand(this.getCommandID("force_reload"));
	}
}