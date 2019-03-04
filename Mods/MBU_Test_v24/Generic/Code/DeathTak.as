
#include "HumanoidCommon.as";
#include "AbilityCommon.as";
#include "ep.as";
#include "eleven.as"

void onInit(CBlob @this){

	if(!this.exists("death_amount"))this.set_s16("death_amount", 0);
	
	this.Tag("death_tak");
}

void onTick(CBlob @this){

	this.getCurrentScript().tickFrequency = 100;
	
	if(this.get_s8("torso_type") == BodyType::Ghost){
		this.Tag("ghost");
	}

	int DeathAmount = this.get_s16("death_amount");

	
	
	if(DeathAmount >= 50 && !this.hasTag("deathly_possess_ability"))giveAbility(this,"deathly_possess_ability","death");
	else if(DeathAmount >= 100 && !this.hasTag("death_sight"))this.Tag("death_sight");
	else if(DeathAmount >= 100 && !this.hasTag("ethereal_sowing_ability"))giveAbility(this,"ethereal_sowing_ability","death");
	else if(DeathAmount >= 150 && !this.hasTag("deathly_manifest_ability"))giveAbility(this,"deathly_manifest_ability","death");
	else if(DeathAmount >= 200 && !this.hasTag("ethereal_illusion_ability"))giveAbility(this,"ethereal_illusion_ability","death");
	else if(DeathAmount >= 250 && !this.hasTag("summon_spirit_ability"))giveAbility(this,"summon_spirit_ability","death");
	else if(DeathAmount >= 300 && !this.hasTag("deathly_infuse_ability"))giveAbility(this,"deathly_infuse_ability","death");
	else if(DeathAmount >= 400 && !this.hasTag("ethereal_reap_ability"))giveAbility(this,"ethereal_reap_ability","death");
	
	
	
	if(DeathAmount <= 0){
		this.Untag("death_sight");
	}
	
	int wraithlimbs = 0;
	if(DeathAmount > 0 && this.get_s16("life_amount") <= 0)wraithlimbs = 1;
	
	if(this.getName() == "humanoid"){
		int MArm = this.get_s8("main_arm_type");
		int SArm = this.get_s8("sub_arm_type");
		int FLeg = this.get_s8("front_leg_type");
		int Bleg = this.get_s8("back_leg_type");
		int Tors = this.get_s8("torso_type");
		int Head = this.get_s8("head_type");
		
		if(getNet().isServer()){
			if(hasAbility(this,"deathly_manifest_ability") || Tors == BodyType::Ghost || Tors == BodyType::Wraith){
				if(checkEInterface(this,this.getPosition(),16,1)){
					if(MArm == -1)attachLimb(this,"main_arm",BodyType::Ghost);
					if(SArm == -1)attachLimb(this,"sub_arm",BodyType::Ghost);
					if(FLeg == -1)attachLimb(this,"front_leg",BodyType::Ghost);
					if(Bleg == -1)attachLimb(this,"back_leg",BodyType::Ghost);
					if(Tors == -1)attachLimb(this,"torso",BodyType::Ghost);
					if(Head == -1)attachLimb(this,"head",BodyType::Ghost);
				}
				
				if(this.hasTag("manifested")){
					if(MArm == BodyType::Ghost)attachLimb(this,"main_arm",BodyType::Wraith);
					if(SArm == BodyType::Ghost)attachLimb(this,"sub_arm",BodyType::Wraith);
					if(FLeg == BodyType::Ghost)attachLimb(this,"front_leg",BodyType::Wraith);
					if(Bleg == BodyType::Ghost)attachLimb(this,"back_leg",BodyType::Wraith);
					if(Tors == BodyType::Ghost)attachLimb(this,"torso",BodyType::Wraith);
					if(Head == BodyType::Ghost)attachLimb(this,"head",BodyType::Wraith);
					this.Untag("ghost");
				} else {
					if(MArm == BodyType::Wraith)attachLimb(this,"main_arm",BodyType::Ghost);
					if(SArm == BodyType::Wraith)attachLimb(this,"sub_arm",BodyType::Ghost);
					if(FLeg == BodyType::Wraith)attachLimb(this,"front_leg",BodyType::Ghost);
					if(Bleg == BodyType::Wraith)attachLimb(this,"back_leg",BodyType::Ghost);
					if(Tors == BodyType::Wraith)attachLimb(this,"torso",BodyType::Ghost);
					if(Head == BodyType::Wraith)attachLimb(this,"head",BodyType::Ghost);
				}
			}
			
			if(DeathAmount == 0){
				if(MArm == BodyType::Ghost || MArm == BodyType::Wraith)gibLimb(this,"main_arm");
				if(SArm == BodyType::Ghost || SArm == BodyType::Wraith)gibLimb(this,"sub_arm");
				if(FLeg == BodyType::Ghost || FLeg == BodyType::Wraith)gibLimb(this,"front_leg");
				if(Bleg == BodyType::Ghost || Bleg == BodyType::Wraith)gibLimb(this,"back_leg");
				if(Tors == BodyType::Ghost || Tors == BodyType::Wraith){
					gibLimb(this,"torso");
					server_CreateBlob("p",-1,this.getPosition());
				}
			}
		}

		int water_mod = 1;
		if(this.isInWater())water_mod = 10;
		if(MArm == BodyType::Wraith)wraithlimbs += 1*water_mod;
		if(SArm == BodyType::Wraith)wraithlimbs += 1*water_mod;
		if(FLeg == BodyType::Wraith)wraithlimbs += 1*water_mod;
		if(Bleg == BodyType::Wraith)wraithlimbs += 1*water_mod;
		if(Tors == BodyType::Wraith)wraithlimbs += 1*water_mod;
		if(Head == BodyType::Wraith)wraithlimbs += 1*water_mod;

		if(MArm == BodyType::Wraith){wraithlimbs += bodyPartMaxHealth(MArm,"main_arm") -  this.get_f32("main_arm_hp");this.set_f32("main_arm_hp",bodyPartMaxHealth(MArm,"main_arm"));}
		if(SArm == BodyType::Wraith){wraithlimbs += bodyPartMaxHealth(SArm,"sub_arm") -  this.get_f32("sub_arm_hp");this.set_f32("sub_arm_hp",bodyPartMaxHealth(SArm,"sub_arm"));}
		if(FLeg == BodyType::Wraith){wraithlimbs += bodyPartMaxHealth(FLeg,"front_leg") -  this.get_f32("front_leg_hp");this.set_f32("front_leg_hp",bodyPartMaxHealth(FLeg,"front_leg"));}
		if(Bleg == BodyType::Wraith){wraithlimbs += bodyPartMaxHealth(Bleg,"back_leg") -  this.get_f32("back_leg_hp");this.set_f32("back_leg_hp",bodyPartMaxHealth(Bleg,"back_leg"));}
		if(Tors == BodyType::Wraith){wraithlimbs += bodyPartMaxHealth(Tors,"torso") -  this.get_f32("torso_hp");this.set_f32("torso_hp",bodyPartMaxHealth(Tors,"torso"));}
	}
	
	
	if(this.hasTag("ghost_stone") && !this.isInWater())wraithlimbs = 0;
	
	if(wraithlimbs > 1)
	for(int i = 0;i < Maths::Min(wraithlimbs,DeathAmount);i++)
	ep(this.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), true, Vec2f(XORRandom(3)-1,XORRandom(3)-1)+this.getVelocity());
	
	if(getNet().isServer()){
		if(wraithlimbs > 5){
			CBlob @p = server_CreateBlob("p",-1,this.getPosition());
			if(p !is null)p.setVelocity(Vec2f(XORRandom(3)-1,XORRandom(3)-1)+this.getVelocity());
		}

		if(wraithlimbs > 0)if(XORRandom(2) == 0){
			if(!this.hasTag("death_conservative")){ //Conservative users don't expel ectoplasm, they keep it rather, though they still lose a bit over time
				CBlob @e = server_CreateBlob("e",-1,this.getPosition());
				if(e !is null)e.setVelocity(Vec2f(XORRandom(31)-15,XORRandom(31)-15)/20);
			} else {
				DeathAmount++;
			}
		}
	}
	
	DeathAmount -= wraithlimbs;
	if(DeathAmount < 0)DeathAmount = 0;

	
	this.set_s16("death_amount", DeathAmount);

	if(getNet().isServer()){
		this.Sync("death_amount",true);
		this.Sync("ghost",true);
	}
	
	if(this.hasTag("ghost_stone"))this.Untag("ghost_stone");
	
	if(getNet().isClient())
	if(getLocalPlayer() is this.getPlayer()){
		if(this.hasTag("death_sight"))getLocalPlayer().Tag("death_sight");
		else getLocalPlayer().Untag("death_sight");
	}

}
