
#include "EquipAnim.as";
#include "LimbsCommon.as";

void setAimValues(CSprite @this, CSpriteLayer@ arm, bool visible, f32 angle, Vec2f around, string anim)
{
	if (arm !is null)
	{
		arm.SetVisible(visible);
		
		CSpriteLayer @other = null;
		
		if(arm.name == "backarm"){
			@other = this.getSpriteLayer("back_sleeve");
		} else
		if(arm.name == "frontarm"){
			@other = this.getSpriteLayer("front_sleeve");
		}
		
		if(other !is null){
			other.SetVisible(visible);

			if (visible)
			{
				if (!other.isAnimation(anim))
				{
					other.SetAnimation(anim);
				}
			
				other.ResetTransform();
				other.RotateBy(angle, around);
			} else return;
		}
		
		if (visible)
		{
			if (!arm.isAnimation(anim))
			{
				arm.SetAnimation(anim);
			}
		
			arm.ResetTransform();
			arm.RotateBy(angle, around);
		} else return;
	}
}

void reloadSpriteBody(CSprite @this, CBlob @blob){
	reloadSpriteHead(this,blob);
	reloadSpriteTorso(this,blob);
	reloadSpriteArms(this,blob);
	reloadSpriteLegs(this,blob);
}

void reloadSpriteHead(CSprite @this, CBlob @blob){
	int gender = blob.getSexNum();
	if(blob.get_u8("head sex") != gender){
		this.RemoveSpriteLayer("head");
		this.RemoveSpriteLayer("hair");
	}
}

void reloadSpriteTorso(CSprite @this, CBlob @blob){
	this.setRenderStyle(RenderStyle::normal);
	
	int gender = blob.getSexNum();
	
	string pregnant = ""; //Why do I do this to myself
	
	if(blob.hasTag("pregnant"))pregnant = "_Pregnant";
	
	const string texname = gender == 0 ?
	                       getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("torso_type"))+"_Torso_Male.png" :
	                       getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("torso_type"))+"_Torso_Female"+pregnant+".png";
	
	if(this.getFilename() != texname){
	
		this.ReloadSprite(texname);
	
	}
	
	if(blob.get_s8("torso_type") == 1){
		this.setRenderStyle(RenderStyle::additive);
		if(getLocalPlayer() !is null && getLocalPlayer().hasTag("death_sight"))this.SetVisible(true);
		else this.SetVisible(false);
	}
	
	CSpriteLayer@ emote = this.getSpriteLayer("bubble");
	if(emote !is null)emote.setRenderStyle(RenderStyle::normal);
}

void reloadSpriteArms(CSprite @this, CBlob @blob){
	
	int findex = this.getSpriteLayer("frontarm").getFrameIndex();
	int bindex = this.getSpriteLayer("backarm").getFrameIndex();
	
	this.getSpriteLayer("frontarm").setRenderStyle(RenderStyle::normal);
	this.getSpriteLayer("backarm").setRenderStyle(RenderStyle::normal);
	
	string text_name_main = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("main_arm_type"))+"_Arms.png";
	string text_name_sub  = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("sub_arm_type"))+"_Arms.png";
	
	if(text_name_main != this.getSpriteLayer("frontarm").getFilename())this.getSpriteLayer("frontarm").ReloadSprite(text_name_main);
	if(text_name_sub != this.getSpriteLayer("backarm").getFilename())this.getSpriteLayer("backarm").ReloadSprite(text_name_sub);
	
	this.getSpriteLayer("frontarm").SetFrameIndex(findex);
	this.getSpriteLayer("backarm").SetFrameIndex(bindex);
	
	if(blob.get_s8("main_arm_type") == 1){
		this.getSpriteLayer("frontarm").setRenderStyle(RenderStyle::additive);
	}
	if(blob.get_s8("sub_arm_type") == 1){
		this.getSpriteLayer("backarm").setRenderStyle(RenderStyle::additive);
	}
}

void reloadSpriteLegs(CSprite @this, CBlob @blob){
	this.getSpriteLayer("frontleg").setRenderStyle(RenderStyle::normal);
	this.getSpriteLayer("backleg").setRenderStyle(RenderStyle::normal);
	
	string text_name_main = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("front_leg_type"))+"_Legs.png";
	string text_name_sub  = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(blob.get_s8("back_leg_type"))+"_Legs.png";
	
	if(text_name_main != this.getSpriteLayer("frontleg").getFilename())this.getSpriteLayer("frontleg").ReloadSprite(text_name_main);
	if(text_name_sub  != this.getSpriteLayer("backleg").getFilename())this.getSpriteLayer("backleg").ReloadSprite(text_name_sub);
	
	if(blob.get_s8("front_leg_type") == 1){
		this.getSpriteLayer("frontleg").setRenderStyle(RenderStyle::additive);
	}
	if(blob.get_s8("back_leg_type") == 1){
		this.getSpriteLayer("backleg").setRenderStyle(RenderStyle::additive);
	}
}

