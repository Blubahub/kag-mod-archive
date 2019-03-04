

bool bodyPartFunctioning(CBlob@ this, string limb){
	return (this.get_s8(limb+"_type") > -1) && (this.get_f32(limb+"_hp") > 0.0f);
}

void hitBodyPart(CBlob@ this, string limb, f32 damage){
	this.set_f32(limb+"_hp",this.get_f32(limb+"_hp")-damage);
	
	print("Hit "+limb+" for "+damage+" damage.");
	
	if(getNet().isServer()){
		this.Sync(limb+"_hp",true);
	}
}

f32 bodyPartMaxHealth(CBlob@ this, string limb){

	int TorsoType = this.get_s8("torso_type");
	int FrontLegType = this.get_s8("front_leg_type");
	int BackLegType = this.get_s8("back_leg_type");
	int MainArmType = this.get_s8("main_arm_type");
	int SubArmType = this.get_s8("sub_arm_type");

	if(limb == "torso"){
		
		if(TorsoType < 0)return 0;
		
		return 25.0f;
	}
		
	if(limb == "main_arm"){
	
		if(MainArmType < 0)return 0;
	
		return 15.0f;
	}
	
	if(limb == "sub_arm"){
	
		if(SubArmType < 0)return 0;
	
		return 15.0f;
	}
	
	if(limb == "front_leg"){
	
		if(FrontLegType < 0)return 0;
	
		return 20.0f;
	}
	
	if(limb == "back_leg"){
	
		if(BackLegType < 0)return 0;
	
		return 20.0f;
	}

	return 20.0f;
}