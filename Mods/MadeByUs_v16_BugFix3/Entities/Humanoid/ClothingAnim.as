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
	
	this.RemoveSpriteLayer("front_legging");
	CSpriteLayer@ frontleg = this.addSpriteLayer("front_legging", "flax_Front_Leg.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontleg !is null)
	{
		Animation@ anim1 = frontleg.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		Animation@ anim = frontleg.addAnimation("run", 3, true);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		Animation@ anim2 = frontleg.addAnimation("lie", 3, true);
		anim2.AddFrame(5);
		anim2.AddFrame(5);
		anim2.AddFrame(5);
		anim2.AddFrame(5);
		Animation@ anim3 = frontleg.addAnimation("broken", 0, false);
		anim3.AddFrame(6);
		frontleg.SetRelativeZ(0.23f);
	}
	
	this.RemoveSpriteLayer("back_legging");
	CSpriteLayer@ backleg = this.addSpriteLayer("back_legging", "flax_Back_Leg.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backleg !is null)
	{
		Animation@ anim1 = backleg.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		Animation@ anim = backleg.addAnimation("run", 3, true);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		Animation@ anim2 = backleg.addAnimation("lie", 3, true);
		anim2.AddFrame(5);
		anim2.AddFrame(5);
		anim2.AddFrame(5);
		anim2.AddFrame(5);
		Animation@ anim3 = backleg.addAnimation("broken", 0, false);
		anim3.AddFrame(6);
		backleg.SetRelativeZ(-0.9f);
	}
	
	this.RemoveSpriteLayer("shirt");
	CSpriteLayer@ body = this.addSpriteLayer("shirt", "flax_Chest.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (body !is null)
	{
		Animation@ anim1 = body.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		anim1.AddFrame(1);
		anim1.AddFrame(2);
		anim1.AddFrame(3);
		body.SetRelativeZ(0.24f);
	}

}

void onTick(CSprite @this){
	CBlob @blob = this.getBlob();

	CSpriteLayer @FArm = this.getSpriteLayer("frontarm");
	CSpriteLayer @BArm = this.getSpriteLayer("backarm");
	CSpriteLayer @FLeg = this.getSpriteLayer("frontleg");
	CSpriteLayer @BLeg = this.getSpriteLayer("backleg");
	
	CSpriteLayer @FArmC = this.getSpriteLayer("front_sleeve");
	CSpriteLayer @BArmC = this.getSpriteLayer("back_sleeve");
	CSpriteLayer @FLegC = this.getSpriteLayer("front_legging");
	CSpriteLayer @BLegC = this.getSpriteLayer("back_legging");
	
	if(FArm !is null && FArmC !is null){
		FArmC.SetOffset(FArm.getOffset());
		
		FArmC.SetVisible(blob.get_s8("main_arm_type") >= 0);
	}
	
	if(BArm !is null && BArmC !is null){
		BArmC.SetOffset(BArm.getOffset());
		
		BArmC.SetVisible(blob.get_s8("sub_arm_type") >= 0);
	}
	
	if(FLeg !is null && FLegC !is null){
		FLegC.SetOffset(FLeg.getOffset());
		FLegC.SetFrameIndex(FLeg.getFrameIndex());
		
		FLegC.SetVisible(blob.get_s8("front_leg_type") >= 0);
	}
	
	if(BLeg !is null && BLegC !is null){
		BLegC.SetOffset(BLeg.getOffset());
		BLegC.SetFrameIndex(BLeg.getFrameIndex());
		
		BLegC.SetVisible(blob.get_s8("back_leg_type") >= 0);
	}
	
	CSpriteLayer @shirt = this.getSpriteLayer("shirt");
	
	if(shirt !is null){
		shirt.SetFrameIndex(this.getFrameIndex());
		shirt.SetVisible(this.isVisible());
		shirt.SetOffset(this.getOffset());
	}
	
	string shirtequipname = getSpritePrefix(blob.get_string("equipment_torso_name"));
	
	if(shirtequipname == ""){
		if(FArmC !is null)FArmC.SetVisible(false);
		if(BArmC !is null)BArmC.SetVisible(false);
		if(shirt !is null)shirt.SetVisible(false);
	} else {
		if(FArmC !is null){
			FArmC.SetVisible(true);
			if(FArmC.getFilename() != shirtequipname+"_Main_Arm.png")
				FArmC.ReloadSprite(shirtequipname+"_Main_Arm.png");
		}
		if(BArmC !is null){
			BArmC.SetVisible(true);
			if(BArmC.getFilename() != shirtequipname+"_Sub_Arm.png")
				BArmC.ReloadSprite(shirtequipname+"_Sub_Arm.png");
		}
		if(shirt !is null){
			shirt.SetVisible(true);
			if(shirt.getFilename() != shirtequipname+"_Chest.png")
				shirt.ReloadSprite(shirtequipname+"_Chest.png");
		}
	}
	
	string legsequipname = getSpritePrefix(blob.get_string("equipment_legs_name"));
	
	if(legsequipname == ""){
		if(FLegC !is null)FLegC.SetVisible(false);
		if(BLegC !is null)BLegC.SetVisible(false);
	} else {
		if(FLegC !is null){
			FLegC.SetVisible(true);
			if(FLegC.getFilename() != legsequipname+"_Front_Leg.png")
				FLegC.ReloadSprite(legsequipname+"_Front_Leg.png");
		}
		if(BLegC !is null){
			BLegC.SetVisible(true);
			if(BLegC.getFilename() != legsequipname+"_Back_Leg.png")
				BLegC.ReloadSprite(legsequipname+"_Back_Leg.png");
		}
	}
}


string getSpritePrefix(string name){

	if(name == "flax_shirt")return "flax";
	if(name == "flax_pants")return "flax";

	return "";
}








