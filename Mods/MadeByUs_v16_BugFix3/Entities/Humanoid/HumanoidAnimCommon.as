
#include "EquipCommon.as";

void ReloadEquipment(CSprite @this, CBlob @blob){

	if(blob is null)return;

	ReloadBack(this, blob);
	ReloadAxe(this, blob);
	ReloadPick(this, blob);
}

string getBodyTypeName(int type){

	if(type == 0)return "Human";
	if(type == 1)return "Ghost";
	if(type == 2)return "Peg";
	
	return "None";

}

void reloadSpriteBody(CSprite @this, CBlob @blob){
	reloadSpriteTorso(this,blob);
	reloadSpriteArms(this,blob);
	reloadSpriteLegs(this,blob);
	
	this.RemoveSpriteLayer("head");
	
	this.SetVisible(true);
}

void reloadSpriteTorso(CSprite @this, CBlob @blob){
	this.setRenderStyle(RenderStyle::normal);
	
	int gender = blob.getSexNum();
	
	if(blob.getPlayer() !is null){
		gender = blob.getPlayer().getSex();
	}
	
	const string texname = gender == 0 ?
	                       getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("torso_type"))+"_Torso_Male.png" :
	                       getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("torso_type"))+"_Torso_Female.png";
	this.ReloadSprite(texname);
	
	
	if(blob.get_s8("torso_type") == 1)this.setRenderStyle(RenderStyle::additive);
	
	CSpriteLayer@ emote = this.getSpriteLayer("bubble");
	if(emote !is null)emote.setRenderStyle(RenderStyle::normal);
}

void reloadSpriteArms(CSprite @this, CBlob @blob){
	
	int findex = this.getSpriteLayer("frontarm").getFrameIndex();
	int bindex = this.getSpriteLayer("backarm").getFrameIndex();
	
	this.getSpriteLayer("frontarm").setRenderStyle(RenderStyle::normal);
	this.getSpriteLayer("backarm").setRenderStyle(RenderStyle::normal);
	
	this.getSpriteLayer("frontarm").ReloadSprite(getBodyTypeName(blob.get_s8("main_arm_type"))+"_Main_Arm.png");
	this.getSpriteLayer("backarm").ReloadSprite(getBodyTypeName(blob.get_s8("sub_arm_type"))+"_Sub_Arm.png");
	
	this.getSpriteLayer("frontarm").SetFrameIndex(findex);
	this.getSpriteLayer("backarm").SetFrameIndex(bindex);
	
	if(blob.get_s8("main_arm_type") == 1)this.getSpriteLayer("frontarm").setRenderStyle(RenderStyle::additive);
	if(blob.get_s8("sub_arm_type") == 1)this.getSpriteLayer("backarm").setRenderStyle(RenderStyle::additive);
}

void reloadSpriteLegs(CSprite @this, CBlob @blob){
	this.getSpriteLayer("frontleg").setRenderStyle(RenderStyle::normal);
	this.getSpriteLayer("backleg").setRenderStyle(RenderStyle::normal);
	
	this.getSpriteLayer("frontleg").ReloadSprite(getBodyTypeName(blob.get_s8("front_leg_type"))+"_Front_Leg.png");
	this.getSpriteLayer("backleg").ReloadSprite(getBodyTypeName(blob.get_s8("back_leg_type"))+"_Back_Leg.png");
	
	if(blob.get_s8("front_leg_type") == 1)this.getSpriteLayer("frontleg").setRenderStyle(RenderStyle::additive);
	if(blob.get_s8("back_leg_type") == 1)this.getSpriteLayer("backleg").setRenderStyle(RenderStyle::additive);
}

void ReloadBack(CSprite @this, CBlob @blob){

	this.RemoveSpriteLayer("back");
	
	string name = "";
	
	if(getEquippedBlob(blob, "back") !is null)
	name = getEquippedBlob(blob, "back").getName();
	
	if(name == "sack"){
		CSpriteLayer@ layer = this.addSpriteLayer("back", "CharacterSack.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
			layer.SetOffset(Vec2f(0,0));
			layer.SetRelativeZ(2.5f);
			layer.SetFacingLeft(this.isFacingLeft());
		}
	}
	
	if(name == "barrel"){
		CSpriteLayer@ layer = this.addSpriteLayer("back", "CharacterBarrel.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
			layer.SetOffset(Vec2f(0,0));
			layer.SetRelativeZ(-3.5f);
			layer.SetFacingLeft(this.isFacingLeft());
		}
	}
	
	if(name == "backpack"){
		CSpriteLayer@ layer = this.addSpriteLayer("back", "CharacterBackpack.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
			layer.SetOffset(Vec2f(0,0));
			layer.SetRelativeZ(-3.5f);
			layer.SetFacingLeft(this.isFacingLeft());
		}
	}

}


void ReloadAxe(CSprite @this, CBlob @blob){

	string name = "";
	
	if(getEquippedBlob(blob, "main_arm") !is null)
	name = getEquippedBlob(blob, "main_arm").getName();
	
	if(this.getSpriteLayer("mainaxe") !is null){
	
		if(name == "axe")this.getSpriteLayer("mainaxe").ReloadSprite("CharacterAxe.png");
		if(name == "hachet")this.getSpriteLayer("mainaxe").ReloadSprite("CharacterHachet.png");
	
	}
	
	name = "";
	
	if(getEquippedBlob(blob, "sub_arm") !is null)
	name = getEquippedBlob(blob, "sub_arm").getName();

	if(this.getSpriteLayer("subaxe") !is null){
	
		if(name == "axe")this.getSpriteLayer("subaxe").ReloadSprite("CharacterAxe.png");
		if(name == "hachet")this.getSpriteLayer("subaxe").ReloadSprite("CharacterHachet.png");
	
	}


}

void ReloadPick(CSprite @this, CBlob @blob){

	string name = "";
	
	if(getEquippedBlob(blob, "main_arm") !is null)
	name = getEquippedBlob(blob, "main_arm").getName();
	
	if(this.getSpriteLayer("mainpick") !is null){
	
		if(name == "pick")this.getSpriteLayer("mainpick").ReloadSprite("CharacterPick.png");
		if(name == "hammer")this.getSpriteLayer("mainpick").ReloadSprite("CharacterHammer.png");
	
	}
	
	name = "";
	
	if(getEquippedBlob(blob, "sub_arm") !is null)
	name = getEquippedBlob(blob, "sub_arm").getName();

	if(this.getSpriteLayer("subpick") !is null){
	
		if(name == "pick")this.getSpriteLayer("subpick").ReloadSprite("CharacterPick.png");
		if(name == "hammer")this.getSpriteLayer("subpick").ReloadSprite("CharacterHammer.png");
	
	}


}