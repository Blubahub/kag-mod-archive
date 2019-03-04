
namespace BodyType
{
	enum type
	{
		Flesh = 0,
		Ghost,
		Peg,
		Hook,
		Wraith,
		PinkFlesh,
		Fairy,
		Gold,
		Shadow,
	};
}

string getBodyTypeName(int type){

	if(type == BodyType::Flesh)return "Human";
	if(type == BodyType::Ghost)return "Ghost";
	if(type == BodyType::Peg)return "Peg";
	if(type == BodyType::Hook)return "Hook";
	if(type == BodyType::Wraith)return "Wraith";
	if(type == BodyType::PinkFlesh)return "PinkFlesh";
	if(type == BodyType::Fairy)return "Fairy";
	if(type == BodyType::Gold)return "Gold";
	if(type == BodyType::Shadow)return "Shadow";
	
	return "None";

}

///////////Important stuff



f32 getLegSpeed(int type){

	if(isFlesh(type)){
		return 0.5;
	}
	
	if(type == BodyType::Peg){
		return 0.3;
	}
	
	if(type == BodyType::Wraith){
		return 0.5;
	}
	
	if(type == BodyType::Shadow){
		return 0.6;
	}
	
	if(type == BodyType::Gold){
		return 0.2;
	}

	return 0.0f;
}


///////////////Optional stuff


bool isFlesh(int limbtype){

	if(limbtype == BodyType::Flesh)return true;
	if(limbtype == BodyType::PinkFlesh)return true;
	if(limbtype == BodyType::Fairy)return true;
	
	return false;

}

f32 getJumpMulti(CBlob@ this){

	f32 Jump = 0.0f;

	if(bodyPartFunctioning(this, "front_leg"))Jump += getLegSpeed(this.get_s8("front_leg_type"));
	if(bodyPartFunctioning(this, "back_leg"))Jump += getLegSpeed(this.get_s8("back_leg_type"));
	
	if(!canStand(this)){
		Jump = 0.0f;
		if(bodyPartFunctioning(this, "main_arm"))Jump += 0.3f; //My right arm is a lot stronger than my left arm.
		if(bodyPartFunctioning(this, "sub_arm"))Jump += 0.2f;
	}

	return Jump;
}

bool armCanGrapple(CBlob@ this, string limb){
	
	if(this.get_s8(limb+"_type") == BodyType::Peg)return false;
	
	return bodyPartFunctioning(this,limb);
}

bool canBeHealed(int limbtype){
	if(isFlesh(limbtype))return true;
	return false;
}


f32 bodyPartMaxHealth(int Type, string limb){

	if(limb == "torso"){

		if(Type < 0)return -1.0f;

		if(Type == BodyType::Wraith)return 10.0f;
		if(Type == BodyType::Fairy)return 15.0f;
		if(Type == BodyType::Gold)return 100.0f;
		if(Type == BodyType::Shadow)return 15.0f;
		
		return 25.0f;
	}
		
	if(limb == "main_arm" || limb == "sub_arm"){

		if(Type < 0)return -1.0f;
	
		if(Type == BodyType::Peg)return 30.0f;
		if(Type == BodyType::Hook)return 25.0f;
		if(Type == BodyType::Wraith)return 10.0f;
		if(Type == BodyType::Fairy)return 5.0f;
		if(Type == BodyType::Gold)return 60.0f;
		if(Type == BodyType::Shadow)return 5.0f;
	
		return 15.0f;
	}
	
	if(limb == "front_leg" || limb == "back_leg"){

		if(Type < 0)return -1.0f;
	
		if(Type == BodyType::Peg)return 40.0f;
		if(Type == BodyType::Wraith)return 10.0f;
		if(Type == BodyType::Fairy)return 10.0f;
		if(Type == BodyType::Gold)return 80.0f;
		if(Type == BodyType::Shadow)return 10.0f;
		
		return 20.0f;
	}

	return 1.0f;
}

f32 bodyPartGibHealth(int Type, string limb){

	if(limb == "torso"){
		if(isFlesh(Type))return -15.0f;
		if(Type == BodyType::Wraith)return -100.0f;
	}
		
	if(limb == "main_arm" || limb == "sub_arm"){
		if(isFlesh(Type))return -5.0f;
		if(Type == BodyType::Wraith)return -100.0f;
	}
	
	if(limb == "front_leg" || limb == "back_leg"){
		if(isFlesh(Type))return -10.0f;
		if(Type == BodyType::Wraith)return -100.0f;
	}

	return 0.0f;
}


bool bodyPartNeedsBreath(CBlob@ this, string limb){

	int Type = this.get_s8(limb+"_type");
	
	if(limb == "torso"){

		if(isFlesh(Type))return true;
		
	}
		
	if(limb == "main_arm" || limb == "sub_arm"){

	}
	
	if(limb == "front_leg" || limb == "back_leg"){

	}

	return false;
}

bool bodyTypeBleeds(int limbtype){
	
	if(isFlesh(limbtype))return true;
	
	return false;
}


///////Generics

int getLeftEye(CBlob @this){
	int[] Eye = {0,0};
	
	int Eyes = this.get_u8("eyes");
	int BurntEyes =  this.get_u8("burnt_eyes");
	int BlindEyes =  this.get_u8("light_eyes");
	
	for(int i = 0;i < 2;i++){
		if(Eyes > 0){
			Eye[i] = 1;
			Eyes--;
		} else
		if(BurntEyes > 0){
			Eye[i] = 2;
			BurntEyes--;
		} else
		if(BlindEyes > 0){
			Eye[i] = 3;
			BlindEyes--;
		}
	}
	
	return Eye[0];
}

int getRightEye(CBlob @this){
	int[] Eye = {0,0};
	
	int Eyes = this.get_u8("eyes");
	int BurntEyes =  this.get_u8("burnt_eyes");
	int BlindEyes =  this.get_u8("light_eyes");
	
	for(int i = 0;i < 2;i++){
		if(Eyes > 0){
			Eye[i] = 1;
			Eyes--;
		} else
		if(BurntEyes > 0){
			Eye[i] = 2;
			BurntEyes--;
		} else
		if(BlindEyes > 0){
			Eye[i] = 3;
			BlindEyes--;
		}
	}
	
	return Eye[1];
}

bool bodyPartFunctioning(CBlob@ this, string limb){

	if(isFlesh(this.get_s8(limb+"_type"))){
		if(this.get_f32(limb+"_hp") <= 0.0f || !this.hasTag("alive"))return false;
		else return true;
	}
	
	if(this.get_s8(limb+"_type") == BodyType::Ghost)return false;
	
	if(this.get_s8(limb+"_type") <= -1)return false;

	if(this.get_s8(limb+"_type") == BodyType::Wraith)return true;
	
	if(this.get_s8(limb+"_type") == BodyType::Gold){
		if(this.get_s16("light_amount") > 0)return true;
		else return false;
	}
	
	return true;
}

bool canHitLimb(CBlob@ this, string limb){
	return (this.get_s8(limb+"_type") > -1) && this.get_s8(limb+"_type") != BodyType::Ghost;
}

bool canDelimb(CBlob@ this, string limb){
	return (this.get_s8(limb+"_type") > -1) && this.get_s8(limb+"_type") != BodyType::Ghost && this.get_s8(limb+"_type") != BodyType::Wraith;
}

bool bodyPartExists(CBlob@ this, string limb){
	return this.get_s8(limb+"_type") > -1 && this.get_s8(limb+"_type") != BodyType::Ghost;
}

bool canStand(CBlob@ this){

	if(bodyPartFunctioning(this, "front_leg") && bodyPartFunctioning(this, "back_leg"))return true;
	
	if(this.get_s8("torso_type") == BodyType::Ghost)return true;
	
	if(bodyPartFunctioning(this, "front_leg") && bodyPartExists(this,"back_leg"))return true;
	
	if(bodyPartFunctioning(this, "back_leg") && bodyPartExists(this,"front_leg"))return true;
	//Should probably add crutches in here

	return false;
}