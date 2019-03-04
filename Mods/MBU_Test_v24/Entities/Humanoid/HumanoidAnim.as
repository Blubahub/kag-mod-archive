// Template animations

#include "FireCommon.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "GrappleCommon.as";
#include "HumanoidCommon.as";
#include "EmotesCommon.as";
#include "Requirements.as";
#include "BuilderCommon.as";
#include "EquipCommon.as";
#include "HumanoidAnimCommon.as";
#include "PixelOffsets.as";

Vec2f DefaultMainArmOffset = Vec2f(2.0f, 1.0f);
Vec2f DefaultSubArmOffset = Vec2f(-3.0f, 1.0f);
Vec2f DefaultFrontLegOffset = Vec2f(1.0f, 3.0f);
Vec2f DefaultBackLegOffset = Vec2f(2.0f, 3.0f);

void onInit(CSprite@ this)
{
	const string texname = this.getBlob().getSexNum() == 0 ?
	                       getFilePath(getCurrentScriptName())+"/Human_Torso_Male.png" :
	                       getFilePath(getCurrentScriptName())+"/Human_Torso_Female.png";

	//this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	this.SetVisible(false);
	
	//Arms
	
	this.RemoveSpriteLayer("frontarm");
	CSpriteLayer@ frontarm = this.addSpriteLayer("frontarm", "Human_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
		frontarm.SetOffset(DefaultMainArmOffset);
		frontarm.SetRelativeZ(3.0f);
	}
	
	this.RemoveSpriteLayer("backarm");
	CSpriteLayer@ backarm = this.addSpriteLayer("backarm", "Human_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
		backarm.SetOffset(DefaultSubArmOffset);
		backarm.SetRelativeZ(-3.0f);
	}
	
	this.RemoveSpriteLayer("frontleg");
	CSpriteLayer@ frontleg = this.addSpriteLayer("frontleg", "Human_Legs.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
		Animation@ anim4 = frontleg.addAnimation("sitting", 0, false);
		anim4.AddFrame(3);
		Animation@ anim5 = frontleg.addAnimation("crouch", 0, false);
		anim5.AddFrame(2);
		frontleg.SetOffset(DefaultFrontLegOffset);
		frontleg.SetRelativeZ(0.22f);
	}
	
	this.RemoveSpriteLayer("backleg");
	CSpriteLayer@ backleg = this.addSpriteLayer("backleg", "Human_Legs.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backleg !is null)
	{
		Animation@ anim1 = backleg.addAnimation("default", 0, false);
		anim1.AddFrame(7);
		Animation@ anim = backleg.addAnimation("run", 3, true);
		anim.AddFrame(8);
		anim.AddFrame(9);
		anim.AddFrame(10);
		anim.AddFrame(11);
		Animation@ anim2 = backleg.addAnimation("lie", 3, true);
		anim2.AddFrame(12);
		anim2.AddFrame(12);
		anim2.AddFrame(12);
		anim2.AddFrame(12);
		Animation@ anim3 = backleg.addAnimation("broken", 0, false);
		anim3.AddFrame(13);
		Animation@ anim4 = backleg.addAnimation("sitting", 0, false);
		anim4.AddFrame(8);
		Animation@ anim5 = backleg.addAnimation("crouch", 0, false);
		anim5.AddFrame(11);
		backleg.SetOffset(DefaultBackLegOffset);
		backleg.SetRelativeZ(-1.0f);
	}
	
	//Shield
	this.RemoveSpriteLayer("shield");
	CSpriteLayer@ shield = this.addSpriteLayer("shield", "character_shield.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (shield !is null)
	{
		Animation@ anim = shield.addAnimation("default", 0, false);
		anim.AddFrame(0);
		Animation@ anim1 = shield.addAnimation("raised", 0, false);
		anim1.AddFrame(1);
		Animation@ anim2 = shield.addAnimation("slide", 0, false);
		anim2.AddFrame(2);
		shield.SetOffset(Vec2f(2.0f, -2.5f));
		shield.SetRelativeZ(100.0f);
		shield.SetVisible(false);
	}
	
	
	
	//grapple
	this.RemoveSpriteLayer("hook");
	CSpriteLayer@ hook = this.addSpriteLayer("hook", "character_grapple.png" , 16, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (hook !is null)
	{
		Animation@ anim = hook.addAnimation("default", 0, false);
		anim.AddFrame(2);
		hook.SetRelativeZ(2.0f);
		hook.SetVisible(false);
	}

	this.RemoveSpriteLayer("rope");
	CSpriteLayer@ rope = this.addSpriteLayer("rope", "character_grapple.png" , 32, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rope !is null)
	{
		Animation@ anim = rope.addAnimation("default", 0, false);
		anim.AddFrame(0);
		rope.SetRelativeZ(-1.5f);
		rope.SetVisible(false);
	}
	
	//Bow
	
	this.RemoveSpriteLayer("bow");
	CSpriteLayer@ bow = this.addSpriteLayer("bow", "character_bow.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (bow!is null)
	{
		Animation@ anim = bow.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		bow.SetOffset(DefaultMainArmOffset);
		bow.SetRelativeZ(2.0f);
		bow.SetVisible(false);
	}

	
	{
		this.RemoveSpriteLayer("main_equip");
		CSpriteLayer@ layer = this.addSpriteLayer("main_equip", "character_pick.png" , 64, 64, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(DefaultMainArmOffset);
			layer.SetRelativeZ(2.0f);
			layer.SetVisible(false);
		}
	}
	
	{
		this.RemoveSpriteLayer("sub_equip");
		CSpriteLayer@ layer = this.addSpriteLayer("sub_equip", "character_pick.png" , 64, 64, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(DefaultSubArmOffset);
			layer.SetRelativeZ(-2.0f);
			layer.SetVisible(false);
		}
	}
	
	ReloadEquipment(this,this.getBlob());

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());

	doRopeUpdate(this, null, null);
	GrappleInfo@ grapple;
	bool hasGrapple = blob.get("GrappleInfo", @grapple);
	if (hasGrapple)
	{
		if(!blob.hasTag("dead"))doRopeUpdate(this, blob, grapple);
	}
	
	
	if(getGameTime() % 30 == 0){
		int gender = blob.getSexNum();
		reloadSpriteTorso(this,blob);

		if(blob.get_u8("sprite_left_eye") != getLeftEye(blob))this.RemoveSpriteLayer("head");
		if(blob.get_u8("sprite_right_eye") != getRightEye(blob))this.RemoveSpriteLayer("head");
		
		if(this.isVisible()){
			if(!blob.exists("head_sprite_index") || blob.get_s8("head_sprite_index") != blob.get_s8("head_type")){
				blob.set_s8("head_sprite_index",blob.get_s8("head_type"));
				this.RemoveSpriteLayer("head");
			}
		}
	}
	
	RenderStyle::Style style = RenderStyle::normal;
	
	if(blob.hasTag("dark_fade"))style = RenderStyle::shadow;
	
	this.setRenderStyle(style);
	
	//Animations
	
	this.animation.frame = 0;
	
	bool LyingDown = !isConscious(blob) || blob.isAttachedToPoint("BED");
	if(blob.hasTag("ghost"))LyingDown = false;
	
	bool Visible = true;
	
	if(blob.hasTag("invisible") || blob.hasTag("light_invisibility"))Visible = false;
	
	bool ghosted = (getLocalPlayer() is null || !getLocalPlayer().hasTag("death_sight")) && !blob.hasTag("ghost_stone");
	
	if(blob.get_s8("torso_type") == 1){
		if(ghosted){
			Visible = false;
			CSpriteLayer@ emote = this.getSpriteLayer("bubble");
			if(emote !is null)emote.SetVisible(false);
		}
	}
	
	if(this.getSpriteLayer("head") !is null)this.getSpriteLayer("head").SetVisible(Visible);
	
	if(blob.isAttached()){
		if(blob.isAttachedToPoint("BED")){
			CAttachment@ attach = blob.getAttachments();
			if(attach.getAttachedBlob("BED") !is null){
				blob.SetFacingLeft(attach.getAttachedBlob("BED").isFacingLeft());
				if(attach.getAttachedBlob("BED").getName() == "bed"){
					Visible = false;
					if(this.getSpriteLayer("head") !is null)this.getSpriteLayer("head").SetVisible(true);
				}
			}
		}
		
		if(blob.isAttachedToPoint("SEX_A") || blob.isAttachedToPoint("SEX_B")){
			Visible = false;
			if(this.getSpriteLayer("head") !is null)this.getSpriteLayer("head").SetVisible(false);
		}
		
		
	}
	
	this.SetVisible(Visible);
	
	
	if(LyingDown)this.animation.frame = 1;
	
	bool Crawling = isConscious(blob) && !canStand(blob) && !LyingDown;
	
	bool Crouching = false;
	if(blob.isOnGround() && down && !left && !right)Crouching = true;
	
	this.SetOffset(Vec2f(0,-4));
	if(Crouching)this.SetOffset(Vec2f(0,-1));
	
	bool Sitting = false;
	if (blob.hasTag("seated"))Sitting = true;
	
	if(Sitting)this.SetOffset(Vec2f(0,0));

	const u8 knocked = getKnocked(blob);
	bool action2 = blob.isKeyPressed(key_action2) && bodyPartFunctioning(blob,"sub_arm");
	bool action1 = blob.isKeyPressed(key_action1) && bodyPartFunctioning(blob,"main_arm");
	
	if(blob.getCarriedBlob() !is null){
		action1 = false;
		action2 = false;
	}
	
	bool aimingMain = action1;
	bool aimingSub = action2;
	
	bool shielding = blob.hasTag("main_shielding") || blob.hasTag("sub_shielding");
	
	int bowcharge = blob.get_u16("bowcharge");
	bool bow = blob.hasTag("shootingbow");
	
	int main_drawback = blob.get_s16("main_drawback");
	int sub_drawback = blob.get_s16("sub_drawback");
	
	int main_implement = blob.get_u8("main_implement");
	int sub_implement = blob.get_u8("sub_implement");

	RunnerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}

	
	if (knocked > 0 && canStand(blob) && !LyingDown)
	{
		this.animation.frame = 2;
	}
	else if (inair)
	{
		
		f32 vy = blob.getVelocity().y;
		if (vy < -0.0f && moveVars.walljumped)
		{
			this.SetAnimation("run");
		}
		else
		{
			this.SetAnimation("fall");
			this.animation.timer = 0;
		}
	}
	
	///////////////////////////////////////////Offsets
	
	if(Crawling)this.animation.frame = 3;
	
	Vec2f MainArmOffset = DefaultMainArmOffset;
	Vec2f SubArmOffset = DefaultSubArmOffset;
	Vec2f FrontLegOffset = DefaultFrontLegOffset;
	Vec2f BackLegOffset = DefaultBackLegOffset;
	
	if(blob.get_s8("torso_type") != 1){ //Ghosts break pixels :/ (this might have been fixed, investigate)
	
		if(blob.exists("MA_offset_cache") && blob.exists("SA_offset_cache") && blob.exists("FL_offset_cache") && blob.exists("BL_offset_cache")){
		
			MainArmOffset = blob.get_Vec2f("MA_offset_cache");
			SubArmOffset = blob.get_Vec2f("SA_offset_cache");
			FrontLegOffset = blob.get_Vec2f("FL_offset_cache");
			BackLegOffset = blob.get_Vec2f("BL_offset_cache");
		
		} else {
		
			string tex_name = this.getFilename();
			if(Texture::exists(tex_name)){
				SColor[] colours = {SColor(64,255,0,0),SColor(64,0,255,0),SColor(64,0,0,255),SColor(64,0,255,255)};
				PixelOffsets@ Poffsets = getPixelOffsetsForTexture(tex_name, Vec2f(32,32), colours);
				
				Vec2f[] MA_offsets = Poffsets.getOffsets(Vec2f(32,32),SColor(64,255,0,0),0);
				if(MA_offsets.length > 0)blob.set_Vec2f("MA_offset_cache",Vec2f(MA_offsets[0].x-9,MA_offsets[0].y-15));
				
				Vec2f[] SA_offsets = Poffsets.getOffsets(Vec2f(32,32),SColor(64,0,255,0),0);
				if(SA_offsets.length > 0)blob.set_Vec2f("SA_offset_cache",Vec2f(SA_offsets[0].x-23,SA_offsets[0].y-15));
				
				Vec2f[] FL_offsets = Poffsets.getOffsets(Vec2f(32,32),SColor(64,0,0,255),0);
				if(FL_offsets.length > 0)blob.set_Vec2f("FL_offset_cache",Vec2f(FL_offsets[0].x-13,FL_offsets[0].y-20));
				
				Vec2f[] BL_offsets = Poffsets.getOffsets(Vec2f(32,32),SColor(64,0,255,255),0);
				if(BL_offsets.length > 0){
					blob.set_Vec2f("BL_offset_cache",Vec2f(BL_offsets[0].x-15,BL_offsets[0].y-20));
				} else {
					if(FL_offsets.length > 0)blob.set_Vec2f("BL_offset_cache",Vec2f(FL_offsets[0].x-11,FL_offsets[0].y-20));
				}
			
			} else Texture::createFromFile(tex_name, this.getFilename());
		
		}
		
	}
	
	MainArmOffset += this.getOffset();
	SubArmOffset += this.getOffset();
	FrontLegOffset += this.getOffset();
	BackLegOffset += this.getOffset();
	
	if(Crawling){
		MainArmOffset = DefaultMainArmOffset+Vec2f(-3.0f,3.0f);
		SubArmOffset = DefaultSubArmOffset+Vec2f(1.0f,4.0f);
	}
	
	//////////////////////////////////Leg handlin
	
	bool FrontLegVisible = Visible;
	bool BackLegVisible = Visible;
	
	if(ghosted){
		if(blob.get_s8("front_leg_type") == 1){
			FrontLegVisible = false;
		}
		if(blob.get_s8("back_leg_type") == 1){
			BackLegVisible = false;
		}
	}
	
	
	this.getSpriteLayer("frontleg").SetVisible((!(blob.get_s8("front_leg_type") < 0)) && FrontLegVisible);
	this.getSpriteLayer("backleg").SetVisible((!(blob.get_s8("back_leg_type") < 0)) && BackLegVisible);
	
	this.getSpriteLayer("frontleg").SetOffset(FrontLegOffset);
	this.getSpriteLayer("backleg").SetOffset(BackLegOffset);
	
	this.getSpriteLayer("frontleg").ResetTransform();
	this.getSpriteLayer("backleg").ResetTransform();
	
	if(LyingDown){
		this.getSpriteLayer("frontleg").SetOffset(FrontLegOffset+Vec2f(-10,0));
		this.getSpriteLayer("backleg").SetOffset(BackLegOffset+Vec2f(-10,0));
		this.getSpriteLayer("frontleg").SetAnimation("lie"); //Liar, liar, pants on fire
		this.getSpriteLayer("backleg").SetAnimation("lie");
	}
	else
	if(Crawling){
		this.getSpriteLayer("frontleg").SetOffset(FrontLegOffset+Vec2f(6,13));
		this.getSpriteLayer("backleg").SetOffset(BackLegOffset+Vec2f(3,12));
		this.getSpriteLayer("frontleg").SetAnimation("lie");
		this.getSpriteLayer("backleg").SetAnimation("lie");
		
		this.getSpriteLayer("frontleg").RotateBy(180, Vec2f(0,0));
		this.getSpriteLayer("backleg").RotateBy(180, Vec2f(0,0));
	}
	else 
	if(Sitting){
		this.getSpriteLayer("frontleg").SetAnimation("sitting");
		this.getSpriteLayer("backleg").SetAnimation("sitting");
	}
	else
	if(Crouching){
		this.getSpriteLayer("frontleg").SetAnimation("crouch");
		this.getSpriteLayer("backleg").SetAnimation("crouch");
	}
	else
	if ((left || right) || (blob.isOnLadder() && (up || down)))
	{
		if(bodyPartFunctioning(blob, "front_leg") || blob.get_s8("torso_type") == 1)this.getSpriteLayer("frontleg").SetAnimation("run");
		if(bodyPartFunctioning(blob, "back_leg") || blob.get_s8("torso_type") == 1)this.getSpriteLayer("backleg").SetAnimation("run");
	}
	else 
	{
		if(bodyPartFunctioning(blob, "front_leg"))
			this.getSpriteLayer("frontleg").SetAnimation("default");
		else
			this.getSpriteLayer("frontleg").SetAnimation("broken");
			
		if(bodyPartFunctioning(blob, "back_leg"))
			this.getSpriteLayer("backleg").SetAnimation("default");
		else
			this.getSpriteLayer("backleg").SetAnimation("broken");
	}

	
	
	///////////////////////////////Arm handlin
	Vec2f vec = blob.getAimPos() - blob.getPosition();
	f32 angle = -vec.Angle();
	
	if (this.isFacingLeft())
	{
		angle = 180.0f + angle;
	}

	if(angle > 180.0f)
	{
		angle -= 360.0f;
	} else
	if (angle < -180.0f)
	{
		angle += 360.0f;
	}
	
	bool mainarmvisible = Visible;
	bool subarmvisible = Visible;

	if(blob.get_s8("main_arm_type") < 0)mainarmvisible = false;
	if(blob.get_s8("sub_arm_type") < 0)subarmvisible = false;
	
	if(ghosted){
		if(blob.get_s8("main_arm_type") == 1){
			mainarmvisible = false;
		}
		if(blob.get_s8("sub_arm_type") == 1){
			subarmvisible = false;
		}
	}
	
	int Down = 90;
	if (this.isFacingLeft())Down = 270;
	
	this.getSpriteLayer("frontarm").SetOffset(MainArmOffset);
	this.getSpriteLayer("backarm").SetOffset(SubArmOffset);
	
	int Wobble = (this.getSpriteLayer("frontleg").getFrame()-1);
	if(!this.getSpriteLayer("frontleg").isAnimation("default")){
		if(Crawling)if(left || right)Wobble = (getGameTime()/3) % 4;
		if(Wobble == 2)Wobble = 0;
		else if(Wobble == 3)Wobble = -1;
		else if(Wobble > 3) Wobble = 0;
	} else Wobble = 0;
	
	if(shielding || bow){
		aimingMain = true;
		aimingSub = true;
	}
	
	bool canUseArms = true;
	
	if(LyingDown){
		canUseArms = false;
		setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 0, Vec2f(0, 0), "default");
		this.getSpriteLayer("frontarm").SetOffset(Vec2f(-3,5.5f));
		
		setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 0, Vec2f(0, 0), "default");
		this.getSpriteLayer("backarm").SetOffset(Vec2f(-3,2));
	} else {
		if (knocked > 0){
			canUseArms = false;
			if (canStand(blob))
			{
				if(this.isFacingLeft()){
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+40, Vec2f(0, 0), "default");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down+40, Vec2f(0, 0), "default");
				} else {
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-40, Vec2f(0, 0), "default");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-40, Vec2f(0, 0), "default");
				}
			}
		}
	}

	setAimValues(this,this.getSpriteLayer("main_equip"), false, 0, Vec2f(0, 0), "default");
	setAimValues(this,this.getSpriteLayer("sub_equip"), false, 0, Vec2f(0, 0), "default");
	
	if(aimingMain){
		setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "stretch");
	} else {
		if(bodyPartFunctioning(blob,"main_arm")){
			if(LyingDown){
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 0, Vec2f(0, 0), "default");
				this.getSpriteLayer("frontarm").SetOffset(Vec2f(-3,5.5f));
			} else
			if(blob.getCarriedBlob() !is null){
				int Carry = -20;
				if (this.isFacingLeft())Carry = 20;
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+Carry*2, Vec2f(0, 0), "default");
			} else 
			if (is_emote(blob, 255, true))
			{
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "point");
			} else 
			setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+Wobble*20, Vec2f(0, 0), "default");
		} else
		setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down, Vec2f(0, 0), "broken");
	}
	if(aimingSub){
		setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
	} else {
		if(bodyPartFunctioning(blob,"sub_arm")){
			if(LyingDown){
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 0, Vec2f(0, 0), "default");
				this.getSpriteLayer("backarm").SetOffset(Vec2f(-3,2));
			} else
			if(blob.getCarriedBlob() !is null){
				int Carry = -20;
				if (this.isFacingLeft())Carry = 20;
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down+Carry, Vec2f(0, 0), "default");
			} else
			setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-Wobble*20, Vec2f(0, 0), "default");
		} else
		setAimValues(this,this.getSpriteLayer("backarm"), mainarmvisible, Down, Vec2f(0, 0), "broken");
	}

	int inverse = -1;
	if(this.isFacingLeft())inverse = 1;
	
	//0 - none
	//1 - Fist
	//2 - Pole
	//3 - Axe
	//4 - Pick
	//5 - Stab
	//6 - Sword
	//7 - Gun
	//8 - Self handle
	
	if(canUseArms){
		switch(main_implement){
			
			case 1:{ // fist
				if(main_drawback < 0)setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "stretch");
				else setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "stretch");
				f32 RadAngle = float(angle)/1000*17.4;
				int test = 1;
				if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
				else test = -1;
				this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(Maths::Cos(RadAngle)*main_drawback*-0.15*test,Maths::Sin(RadAngle)*main_drawback*-0.15));
			break;}
			
			case 2:{ // pole
				f32 RadAngle = float(angle)/1000*17.4;
				int test = 1;
				if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
				else test = -1;
				this.getSpriteLayer("main_equip").SetOffset(MainArmOffset+Vec2f(0,5.5f)+Vec2f(Maths::Cos(RadAngle)*main_drawback*-0.04*test,Maths::Sin(RadAngle)*main_drawback*-0.04));
				setAimValues(this,this.getSpriteLayer("main_equip"), true, angle, Vec2f(0, 0), "default");
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-(main_drawback*0.2)*test, Vec2f(0, 0), "default");
			break;}
			
			case 3:{ // axe
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle-70*inverse+main_drawback*inverse*2, Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("main_equip"), true, angle-70*inverse+main_drawback*inverse*2, Vec2f(0, 0), "default");
				this.getSpriteLayer("main_equip").SetOffset(MainArmOffset);
			break;}
			
			case 4:{ // pick
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle-70.0f*inverse+main_drawback*inverse*2.0f, Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("main_equip"), true, angle-70.0f*inverse+main_drawback*inverse*2.0f, Vec2f(0, 0), "default");
				this.getSpriteLayer("main_equip").SetOffset(MainArmOffset);
			break;}
			
			case 5:{ // stabber
				f32 RadAngle = float(angle)/1000*17.4;
				int test = 1;
				if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
				else test = -1;
				this.getSpriteLayer("main_equip").SetOffset(MainArmOffset+Vec2f(3.0f,4.0f)+Vec2f(Maths::Cos(RadAngle)*main_drawback*-0.04*test,Maths::Sin(RadAngle)*main_drawback*-0.04));
				setAimValues(this,this.getSpriteLayer("main_equip"), true, angle, Vec2f(0, 0), "default");
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-(main_drawback*0.2)*test, Vec2f(0, 0), "default");
			break;}
			
			case 6:{ // sword
				f32 draw_back = main_drawback*0.2f;
				if(draw_back > 15)draw_back = 15+(draw_back-15)*0.2f;
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle-70*inverse+draw_back*inverse*10, Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("main_equip"), true, angle-70*inverse+draw_back*inverse*10, Vec2f(0, 0), "default");
				this.getSpriteLayer("main_equip").SetOffset(MainArmOffset);
			break;}
			
			case 7:{ // Gun
				f32 ang = angle;
				if(main_drawback > 0){
					ang = (-45-main_drawback)*inverse;
					
					if(main_drawback > 20)ang = -45*inverse;
				} else if(main_drawback < 0){
					ang = angle+(120*inverse+main_drawback*inverse*40);
				}
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, ang, Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("main_equip"), true, ang, Vec2f(0, 0), "default");
				
				if(main_drawback == 0){
					Vec2f barrel = blob.get_Vec2f("main_barrel_offset");
					barrel.x *= -inverse;
					barrel.RotateBy(ang);
					Vec2f shoulder_offset = Vec2f(this.getSpriteLayer("main_equip").getOffset().x*inverse,this.getSpriteLayer("main_equip").getOffset().y);
					blob.set_Vec2f("main_gun_barrel_pos",blob.getPosition()+shoulder_offset+barrel);
				}
				
				this.getSpriteLayer("main_equip").SetOffset(MainArmOffset);
			break;}
			
			case 8:{ // Self handle
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, blob.get_f32("main_arm_angle"), Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("main_equip"), true, blob.get_f32("main_equip_angle"), Vec2f(0, 0), "default");
				this.getSpriteLayer("main_equip").SetOffset(MainArmOffset);
			break;}
		
		}
		
		switch(sub_implement){
			
			case 1:{ // fist
				if(sub_drawback < 0)setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
				else setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
				f32 RadAngle = float(angle)/1000*17.4;
				int test = 1;
				if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
				else test = -1;
				this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f(Maths::Cos(RadAngle)*sub_drawback*-0.15*test,Maths::Sin(RadAngle)*sub_drawback*-0.15));
			break;}
			
			case 2:{ // pole
				f32 RadAngle = float(angle)/1000*17.4;
				int test = 1;
				if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
				else test = -1;
				this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset+Vec2f(5.0f,3.5f)+Vec2f(Maths::Cos(RadAngle)*sub_drawback*-0.04*test,Maths::Sin(RadAngle)*sub_drawback*-0.04));
				setAimValues(this,this.getSpriteLayer("sub_equip"), true, angle, Vec2f(0, 0), "default");
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-(sub_drawback*0.2)*test, Vec2f(0, 0), "default");
			break;}
			
			case 3:{ // axe
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle-70*inverse+sub_drawback*inverse*2, Vec2f(0, 0), "stretch");
			setAimValues(this,this.getSpriteLayer("sub_equip"), true, angle-70*inverse+sub_drawback*inverse*2, Vec2f(0, 0), "default");
			this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset);
			break;}
			
			case 4:{ // pick
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle-70.0f*inverse+sub_drawback*inverse*2.0f, Vec2f(0, 0), "stretch");
			setAimValues(this,this.getSpriteLayer("sub_equip"), true, angle-70.0f*inverse+sub_drawback*inverse*2.0f, Vec2f(0, 0), "default");
			this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset);
			break;}
			
			case 5:{ // stabber
				f32 RadAngle = float(angle)/1000*17.4;
				int test = 1;
				if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
				else test = -1;
				this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset+Vec2f(2.0f,4.0f)+Vec2f(Maths::Cos(RadAngle)*sub_drawback*-0.04*test,Maths::Sin(RadAngle)*sub_drawback*-0.04));
				setAimValues(this,this.getSpriteLayer("sub_equip"), true, angle, Vec2f(0, 0), "default");
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-(sub_drawback*0.2)*test, Vec2f(0, 0), "default");
			break;}
			
			case 6:{ // sword
				f32 draw_back = sub_drawback*0.2f;
				if(draw_back > 15)draw_back = 15+(draw_back-15)*0.2f;
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle-70*inverse+draw_back*inverse*10, Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("sub_equip"), true, angle-70*inverse+draw_back*inverse*10, Vec2f(0, 0), "default");
				this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset);
			break;}
			
			case 7:{ // Gun
				f32 ang = angle;
				if(sub_drawback > 0){
					ang = (-45-sub_drawback)*inverse;
					
					if(sub_drawback > 20)ang = -45*inverse;
				} else if(sub_drawback < 0){
					ang = angle-40*inverse-sub_drawback*inverse*10;
				}
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, ang, Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("sub_equip"), true, ang, Vec2f(0, 0), "default");
				this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset);
				
				if(sub_drawback == 0){
					Vec2f barrel = blob.get_Vec2f("sub_barrel_offset");
					barrel.x *= -inverse;
					barrel.RotateBy(ang);
					Vec2f shoulder_offset = Vec2f(this.getSpriteLayer("sub_equip").getOffset().x*inverse,this.getSpriteLayer("sub_equip").getOffset().y);
					blob.set_Vec2f("sub_gun_barrel_pos",blob.getPosition()+shoulder_offset+barrel);
				}
			break;}
			
			case 8:{ // Self handle
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, blob.get_f32("sub_arm_angle"), Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("sub_equip"), true, blob.get_f32("sub_equip_angle"), Vec2f(0, 0), "default");
				this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset);
			break;}
		
		}

		if(hasGrapple)
		if(grapple.grappling){
			Vec2f off = grapple.grapple_pos - blob.getPosition();
			int grappleAngle = -off.Angle();
			if (this.isFacingLeft())
			{
				grappleAngle = 180.0f + grappleAngle;
			}
			setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, grappleAngle, Vec2f(0, 0), "stretch");
			setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, grappleAngle, Vec2f(0, 0), "stretch");
		}
		
		if(bow){
			if(bowcharge <= 20)this.getSpriteLayer("bow").SetFrameIndex(0);
			else if(bowcharge == 40)this.getSpriteLayer("bow").SetFrameIndex(2);
			else this.getSpriteLayer("bow").SetFrameIndex(1);
			
			if(!this.isFacingLeft())setAimValues(this,this.getSpriteLayer("bow"), true, angle, Vec2f(-0.0, 0), "default");
			else setAimValues(this,this.getSpriteLayer("bow"), true, angle, Vec2f(0.0, 0), "default");
			
			f32 offset = 3;
			
			if(this.getSpriteLayer("bow").getFrameIndex() == 0)offset = 1;
			if(this.getSpriteLayer("bow").getFrameIndex() == 1)offset = 3;
			if(this.getSpriteLayer("bow").getFrameIndex() == 2)offset = 5;
			if(this.getSpriteLayer("bow").getFrameIndex() == 3)offset = 5;
			
			this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(offset,0));
			this.getSpriteLayer("bow").SetOffset(MainArmOffset);
			
			
			if(!this.isFacingLeft())offset = -offset;

			setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(offset, 0), "open_hand");
			setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
		} else {
			setAimValues(this,this.getSpriteLayer("bow"), false, angle, Vec2f(0, 0), "default");
		}
		
		if(shielding){
			
			this.getSpriteLayer("shield").SetOffset(MainArmOffset);
			
			if(vec.Angle() > 45 && vec.Angle() < 135){
				setAimValues(this,this.getSpriteLayer("shield"), true, 0, Vec2f(0, 0), "raised");
				if(this.isFacingLeft()){
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 110, Vec2f(0, 0), "stretch");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 70, Vec2f(0, 0), "stretch");
				} else {
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 250, Vec2f(0, 0), "stretch");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 290, Vec2f(0, 0), "stretch");
				}
			} else
			if(vec.Angle() > 270-45 && vec.Angle() < 270+45){
				setAimValues(this,this.getSpriteLayer("shield"), true, 0, Vec2f(0, 0), "slide");
				
				if(this.animation.frame == 0)this.animation.frame = 2;
				
				this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(0,2));
				this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f(0,2));
				
				if(this.isFacingLeft()){
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 290, Vec2f(0, 0), "stretch");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 290, Vec2f(0, 0), "stretch");
				} else {
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 70, Vec2f(0, 0), "stretch");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 70, Vec2f(0, 0), "stretch");
				}
			} else setAimValues(this,this.getSpriteLayer("shield"), true, angle, Vec2f(0, 0), "default");
		} else setAimValues(this,this.getSpriteLayer("shield"), false, angle, Vec2f(0, 0), "default");
	}	
	
	//////////////////////////////Sync back

	if(this.getSpriteLayer("back") !is null){
	
		this.getSpriteLayer("back").SetFrameIndex(this.animation.frame);
		this.getSpriteLayer("back").SetOffset(this.getOffset()+Vec2f(0,4));
		this.getSpriteLayer("back").SetVisible(Visible);
	
	}
	
	if(this.getSpriteLayer("belt") !is null){
	
		this.getSpriteLayer("belt").SetFrameIndex(this.animation.frame);
		this.getSpriteLayer("belt").SetOffset(this.getOffset()+Vec2f(0,4));
		this.getSpriteLayer("belt").SetVisible(Visible);
	
	}

	
	//////////////////////////////set head
	if(LyingDown){
		blob.Tag("sleep head");
	}
	else
	if (knocked > 0 || !blob.hasTag("alive")) //Are we stunned?
	{
		blob.Tag("dead head"); //Use the 'dead' head.
		blob.Untag("sleep head");
	}
	else if (blob.isInFlames()) //Are we using our left click ability or are we on fire?
	{
		blob.Tag("attack head"); //Set our head to the 'attack' head
		blob.Untag("dead head"); //Unset our head from 'dead' head.
		blob.Untag("sleep head");
	}
	else //Other wise
	{
		blob.Untag("attack head");  //Unset 'attack' head
		blob.Untag("dead head");
		blob.Untag("sleep head");		//Unset 'dead' head
		//This'll make our head normal
	}
}
