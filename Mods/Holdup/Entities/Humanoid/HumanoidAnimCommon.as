
#include "EquipCommon.as";

void ReloadEquipment(CSprite @this, CBlob @blob){

	if(blob is null)return;

	ReloadBack(this, blob);
	ReloadAxe(this, blob);
	ReloadPick(this, blob);
	ReloadShield(this, blob);
	ReloadSword(this, blob);
	ReloadStabbers(this, blob);
}

string getBodyTypeName(int type){

	if(type == 0)return "Human";
	if(type == 1)return "Ghost";
	if(type == 2)return "Peg";
	if(type == 3)return "Hook";
	
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
	
	string pregnant = ""; //Why do I do this to myself
	
	if(blob.hasTag("pregnant"))pregnant = "_Pregnant";
	
	const string texname = gender == 0 ?
	                       getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("torso_type"))+"_Torso_Male.png" :
	                       getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("torso_type"))+"_Torso_Female"+pregnant+".png";
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
		CSpriteLayer@ layer = this.addSpriteLayer("back", "character_sack.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
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
	
	if(name == "pouch"){
		CSpriteLayer@ layer = this.addSpriteLayer("back", "character_pouch.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
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
		CSpriteLayer@ layer = this.addSpriteLayer("back", "character_barrel.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
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
		CSpriteLayer@ layer = this.addSpriteLayer("back", "character_backpack.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
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
	
		this.getSpriteLayer("mainaxe").ReloadSprite("character_"+name+".png");
	
	}
	
	name = "";
	
	if(getEquippedBlob(blob, "sub_arm") !is null)
	name = getEquippedBlob(blob, "sub_arm").getName();

	if(this.getSpriteLayer("subaxe") !is null){
	
		this.getSpriteLayer("subaxe").ReloadSprite("character_"+name+".png");
	
	}


}

void ReloadShield(CSprite @this, CBlob @blob){

	string name = "";
	string name2 = "";
	
	if(getEquippedBlob(blob, "main_arm") !is null)
	name = getEquippedBlob(blob, "main_arm").getName();
	if(getEquippedBlob(blob, "sub_arm") !is null)
	name2 = getEquippedBlob(blob, "sub_arm").getName();
	
	if(this.getSpriteLayer("shield") !is null){
	
		if(getEquippedBlob(blob, "sub_arm") !is null)if(name2 == "shield")
		this.getSpriteLayer("shield").ReloadSprite("character_shield.png",32,32,getEquippedBlob(blob, "sub_arm").getTeamNum(),0);
	
		if(getEquippedBlob(blob, "main_arm") !is null)if(name == "shield")
		this.getSpriteLayer("shield").ReloadSprite("character_shield.png",32,32,getEquippedBlob(blob, "main_arm").getTeamNum(),0);
	}


}

void ReloadPick(CSprite @this, CBlob @blob){

	string name = "";
	
	if(getEquippedBlob(blob, "main_arm") !is null)
	name = getEquippedBlob(blob, "main_arm").getName();
	
	if(this.getSpriteLayer("mainpick") !is null){
	
		this.getSpriteLayer("mainpick").ReloadSprite("character_"+name+".png");
	
	}
	
	name = "";
	
	if(getEquippedBlob(blob, "sub_arm") !is null)
	name = getEquippedBlob(blob, "sub_arm").getName();

	if(this.getSpriteLayer("subpick") !is null){
	
		this.getSpriteLayer("subpick").ReloadSprite("character_"+name+".png");
	
	}


}

void ReloadSword(CSprite @this, CBlob @blob){

	string name = "";
	
	if(getEquippedBlob(blob, "main_arm") !is null)
	name = getEquippedBlob(blob, "main_arm").getName();
	
	if(this.getSpriteLayer("mainsword") !is null){
		this.getSpriteLayer("mainsword").ReloadSprite("character_"+name+".png");
		if(this.getSpriteLayer("main_stab") !is null)this.getSpriteLayer("main_stab").ReloadSprite("characterstab_"+name+".png");
	}
	
	name = "";
	
	if(getEquippedBlob(blob, "sub_arm") !is null)
	name = getEquippedBlob(blob, "sub_arm").getName();

	if(this.getSpriteLayer("subsword") !is null){
			this.getSpriteLayer("subsword").ReloadSprite("character_"+name+".png");
			if(this.getSpriteLayer("sub_stab") !is null)this.getSpriteLayer("sub_stab").ReloadSprite("characterstab_"+name+".png");
	}


}

void ReloadStabbers(CSprite @this, CBlob @blob){

	string name = "";
	
	if(getEquippedBlob(blob, "main_arm") !is null)
	name = getEquippedBlob(blob, "main_arm").getName();
	
	if(this.getSpriteLayer("main_stab") !is null){
	
		this.getSpriteLayer("main_stab").ReloadSprite("character_"+name+".png");
	
	}
	
	name = "";
	
	if(getEquippedBlob(blob, "sub_arm") !is null)
	name = getEquippedBlob(blob, "sub_arm").getName();

	if(this.getSpriteLayer("sub_stab") !is null){
	
		this.getSpriteLayer("sub_stab").ReloadSprite("character_"+name+".png");
	
	}


}