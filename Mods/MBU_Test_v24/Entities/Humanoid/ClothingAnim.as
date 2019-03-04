#include "EquipCommon.as";
#include "HumanoidCommon.as";

void onInit(CSprite @this){

	this.RemoveSpriteLayer("front_sleeve");
	CSpriteLayer@ frontarm = this.addSpriteLayer("front_sleeve", "flax_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontarm !is null)
	{
		Animation@ anim = frontarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		Animation@ anim2 = frontarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(6);
		Animation@ anim3 = frontarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(2);
		Animation@ anim4 = frontarm.addAnimation("point", 0, false);
		anim4.AddFrame(8);
		Animation@ anim5 = frontarm.addAnimation("broken", 0, false);
		anim5.AddFrame(4);
		frontarm.SetRelativeZ(3.1f);
	}
	
	this.RemoveSpriteLayer("back_sleeve");
	CSpriteLayer@ backarm = this.addSpriteLayer("back_sleeve", "flax_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(1);
		Animation@ anim2 = backarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(7);
		Animation@ anim3 = backarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(3);
		Animation@ anim4 = backarm.addAnimation("point", 0, false);
		anim4.AddFrame(9);
		Animation@ anim5 = backarm.addAnimation("broken", 0, false);
		anim5.AddFrame(5);
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

	CSpriteLayer @FArm = this.getSpriteLayer("frontarm");
	CSpriteLayer @BArm = this.getSpriteLayer("backarm");
	
	CSpriteLayer @FArmC = this.getSpriteLayer("front_sleeve");
	CSpriteLayer @BArmC = this.getSpriteLayer("back_sleeve");
	
	CSpriteLayer @shirt = this.getSpriteLayer("shirt");
	CSpriteLayer @pants = this.getSpriteLayer("pants");
	
	if(FArm !is null && FArmC !is null){
		FArmC.SetOffset(FArm.getOffset());
		FArmC.SetVisible(canHitLimb(blob,"main_arm") && FArm.isVisible());
	} else return;
	
	if(BArm !is null && BArmC !is null){
		BArmC.SetOffset(BArm.getOffset());
		BArmC.SetVisible(canHitLimb(blob,"sub_arm") && BArmC.isVisible());
	} else return;
	
	if(shirt !is null){
		shirt.SetFrameIndex(this.getFrameIndex());
		shirt.SetVisible(this.isVisible());
		shirt.SetOffset(this.getOffset());
	} else return;

	if(pants !is null){
		pants.SetFrameIndex(this.getFrameIndex());
		pants.SetVisible(this.isVisible());
		pants.SetOffset(this.getOffset());
	} else return;
	
	CBlob @shirtBlob = getEquippedBlob(blob,"torso");
	string shirtequipname = "";
	int shirtTeam = 7;
	
	if(shirtBlob !is null){
		shirtTeam = shirtBlob.getTeamNum();
		shirtequipname = shirtBlob.get_string("character_sprite_prefix");
	}
	
	string path = getFilePath(getCurrentScriptName())+"/ArmourSprites/";
	
	if(shirtequipname == ""){
		FArmC.SetVisible(false);
		BArmC.SetVisible(false);
		shirt.SetVisible(false);
	} else {
		string sex = "_Male";
		if(blob.getSexNum() == 1)sex = "_Female";
		
		if(shirt.getFilename() != path+shirtequipname+sex+"_Chest.png"){
			shirt.ReloadSprite(shirtequipname+sex+"_Chest.png", 32, 32, shirtTeam, 0);
			FArmC.ReloadSprite(shirtequipname+"_Arms.png", 32, 32, shirtTeam, 0);
			BArmC.ReloadSprite(shirtequipname+"_Arms.png", 32, 32, shirtTeam, 0);
		}
	}
	
	string legsequipname = "";
	
	int legsTeam = 7;
	
	CBlob @legsBlob = getEquippedBlob(blob,"legs");
	if(legsBlob !is null){
		legsTeam = legsBlob.getTeamNum();
		legsequipname = legsBlob.get_string("character_sprite_prefix");
	}
	
	if(legsequipname == ""){
		pants.SetVisible(false);
	} else {
		if(pants.getFilename() != path+legsequipname+"_Pants.png")
			pants.ReloadSprite(legsequipname+"_Pants.png", 32, 32, legsTeam, 0);
	}

}