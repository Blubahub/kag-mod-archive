#include "EquipCommon.as";

void onInit(CSprite @this){

	this.RemoveSpriteLayer("front_sleeve");
	CSpriteLayer@ frontarm = this.addSpriteLayer("front_sleeve", "flax_Main_Arm.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontarm !is null)
	{
		Animation@ anim = frontarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		Animation@ anim1 = frontarm.addAnimation("punch", 0, false);
		anim1.AddFrame(2);
		Animation@ anim2 = frontarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(3);
		Animation@ anim3 = frontarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(4);
		Animation@ anim4 = frontarm.addAnimation("point", 0, false);
		anim4.AddFrame(5);
		Animation@ anim5 = frontarm.addAnimation("broken", 0, false);
		anim5.AddFrame(6);
		frontarm.SetRelativeZ(3.1f);
	}
	
	this.RemoveSpriteLayer("back_sleeve");
	CSpriteLayer@ backarm = this.addSpriteLayer("back_sleeve", "flax_Sub_Arm.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		Animation@ anim1 = backarm.addAnimation("punch", 0, false);
		anim1.AddFrame(2);
		Animation@ anim2 = backarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(3);
		Animation@ anim3 = backarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(4);
		Animation@ anim4 = backarm.addAnimation("point", 0, false);
		anim4.AddFrame(5);
		Animation@ anim5 = backarm.addAnimation("broken", 0, false);
		anim5.AddFrame(6);
		backarm.SetRelativeZ(-2.9f);
	}
	
	this.RemoveSpriteLayer("shirt");
	CSpriteLayer@ body = this.addSpriteLayer("shirt", "flax_Male_Chest.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (body !is null)
	{
		Animation@ anim1 = body.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		anim1.AddFrame(1);
		anim1.AddFrame(2);
		anim1.AddFrame(3);
		body.SetRelativeZ(0.24f);
	}
	
	this.RemoveSpriteLayer("pants");
	CSpriteLayer@ pants = this.addSpriteLayer("pants", "flax_Pants.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (pants !is null)
	{
		Animation@ anim1 = pants.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		anim1.AddFrame(1);
		anim1.AddFrame(2);
		anim1.AddFrame(3);
		pants.SetRelativeZ(0.23f);
	}

}

void onTick(CSprite @this){
	CBlob @blob = this.getBlob();
	
	string sex = "_Male";
	if(blob.getSexNum() == 1)sex = "_Female";

	CSpriteLayer @FArm = this.getSpriteLayer("frontarm");
	CSpriteLayer @BArm = this.getSpriteLayer("backarm");
	
	CSpriteLayer @FArmC = this.getSpriteLayer("front_sleeve");
	CSpriteLayer @BArmC = this.getSpriteLayer("back_sleeve");
	
	if(FArm !is null && FArmC !is null){
		FArmC.SetOffset(FArm.getOffset());
		FArmC.SetVisible(blob.get_s8("main_arm_type") >= 0 && FArm.isVisible());
	}
	
	if(BArm !is null && BArmC !is null){
		BArmC.SetOffset(BArm.getOffset());
		BArmC.SetVisible(blob.get_s8("sub_arm_type") >= 0 && BArmC.isVisible());
	}
	
	CSpriteLayer @shirt = this.getSpriteLayer("shirt");
	
	if(shirt !is null){
		shirt.SetFrameIndex(this.getFrameIndex());
		shirt.SetVisible(this.isVisible());
		shirt.SetOffset(this.getOffset());
	}
	
	CSpriteLayer @pants = this.getSpriteLayer("pants");
	
	if(pants !is null){
		pants.SetFrameIndex(this.getFrameIndex());
		pants.SetVisible(this.isVisible());
		pants.SetOffset(this.getOffset());
	}
	
	CBlob @shirtBlob = getEquippedBlob(blob,"torso");
	string shirtequipname = getSpritePrefix(blob.get_string("equipment_torso_name"));
	int shirtTeam = 7;
	
	if(shirtBlob !is null)shirtTeam = shirtBlob.getTeamNum();
	
	if(shirtequipname == ""){
		if(FArmC !is null)FArmC.SetVisible(false);
		if(BArmC !is null)BArmC.SetVisible(false);
		if(shirt !is null)shirt.SetVisible(false);
	} else {
		if(FArmC !is null){
			if(FArmC.getFilename() != shirtequipname+"_Main_Arm.png")
				FArmC.ReloadSprite(shirtequipname+"_Main_Arm.png", 32, 32, shirtTeam, 0);
		}
		if(BArmC !is null){
			if(BArmC.getFilename() != shirtequipname+"_Sub_Arm.png")
				BArmC.ReloadSprite(shirtequipname+"_Sub_Arm.png", 32, 32, shirtTeam, 0);
		}
		if(shirt !is null){
			if(shirt.getFilename() != shirtequipname+sex+"_Chest.png")
				shirt.ReloadSprite(shirtequipname+sex+"_Chest.png", 32, 32, shirtTeam, 0);
		}
	}
	
	string legsequipname = getSpritePrefix(blob.get_string("equipment_legs_name"));
	
	int legsTeam = 7;
	
	CBlob @legsBlob = getEquippedBlob(blob,"legs");
	if(legsBlob !is null)legsTeam = legsBlob.getTeamNum();
	
	if(legsequipname == ""){
		if(pants !is null)pants.SetVisible(false);
	} else {
		if(pants !is null){
			if(pants.getFilename() != legsequipname+"_Pants.png")
				pants.ReloadSprite(legsequipname+"_Pants.png", 32, 32, legsTeam, 0);
		}
	}

}