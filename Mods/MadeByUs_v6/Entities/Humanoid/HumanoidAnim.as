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

Vec2f MainArmOffset = Vec2f(2.0f, -2.5f);
Vec2f SubArmOffset = Vec2f(-3.0f, -2.5f);

void onInit(CSprite@ this)
{
	const string texname = this.getBlob().getSexNum() == 0 ?
	                       getFilePath(getCurrentScriptName())+"/Human_Torso_Male.png" :
	                       getFilePath(getCurrentScriptName())+"/Human_Torso_Female.png"; //These three lines are like coder magic. Don't touch em unless you want it to stop working. Only change the names of the .pngs.
	this.ReloadSprite(texname); //This resets the sprite to use the new sprites.

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	//Arms
	
	this.RemoveSpriteLayer("frontarm");
	CSpriteLayer@ frontarm = this.addSpriteLayer("frontarm", "Human_Main_Arm.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
		frontarm.SetOffset(MainArmOffset);
		frontarm.SetRelativeZ(3.0f);
	}
	
	this.RemoveSpriteLayer("backarm");
	CSpriteLayer@ backarm = this.addSpriteLayer("backarm", "Human_Sub_Arm.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
		backarm.SetOffset(SubArmOffset);
		backarm.SetRelativeZ(-3.0f);
	}
	
	this.RemoveSpriteLayer("frontleg");
	CSpriteLayer@ frontleg = this.addSpriteLayer("frontleg", "Human_Front_Leg.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontleg !is null)
	{
		Animation@ anim1 = frontleg.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		Animation@ anim = frontleg.addAnimation("run", 3, true);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		frontleg.SetOffset(Vec2f(1.0f, -1.0f));
		frontleg.SetRelativeZ(1.0f);
	}
	
	this.RemoveSpriteLayer("backleg");
	CSpriteLayer@ backleg = this.addSpriteLayer("backleg", "Human_Back_Leg.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backleg !is null)
	{
		Animation@ anim1 = backleg.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		Animation@ anim = backleg.addAnimation("run", 3, true);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		backleg.SetOffset(Vec2f(2.0f, -1.0f));
		backleg.SetRelativeZ(-1.0f);
	}
	
	//Shield
	this.RemoveSpriteLayer("shield");
	CSpriteLayer@ shield = this.addSpriteLayer("shield", "CharacterShield.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
	}
	
	
	
	//grapple
	this.RemoveSpriteLayer("hook");
	CSpriteLayer@ hook = this.addSpriteLayer("hook", "CharacterGrapple.png" , 16, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (hook !is null)
	{
		Animation@ anim = hook.addAnimation("default", 0, false);
		anim.AddFrame(2);
		hook.SetRelativeZ(2.0f);
		hook.SetVisible(false);
	}

	this.RemoveSpriteLayer("rope");
	CSpriteLayer@ rope = this.addSpriteLayer("rope", "CharacterGrapple.png" , 32, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rope !is null)
	{
		Animation@ anim = rope.addAnimation("default", 0, false);
		anim.AddFrame(0);
		rope.SetRelativeZ(-1.5f);
		rope.SetVisible(false);
	}
	
	//Bow
	
	this.RemoveSpriteLayer("bow");
	CSpriteLayer@ bow = this.addSpriteLayer("bow", "CharacterBow.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (bow!is null)
	{
		Animation@ anim = bow.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		bow.SetOffset(MainArmOffset);//Vec2f(2.0f, -0.5f));
		bow.SetRelativeZ(2.0f);
	}
	
	//Sticks
	{
		this.RemoveSpriteLayer("main_pole");
		CSpriteLayer@ layer = this.addSpriteLayer("main_pole", "CharacterStick.png" , 29, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetRelativeZ(2.0f);
		}
	}
	{
		this.RemoveSpriteLayer("sub_pole");
		CSpriteLayer@ layer = this.addSpriteLayer("sub_pole", "CharacterStick.png" , 29, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(MainArmOffset);
			layer.SetRelativeZ(-2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("mainpick");
		CSpriteLayer@ layer = this.addSpriteLayer("mainpick", "CharacterPick.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(MainArmOffset);
			layer.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("subpick");
		CSpriteLayer@ layer = this.addSpriteLayer("subpick", "CharacterPick.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(SubArmOffset);
			layer.SetRelativeZ(-2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("mainaxe");
		CSpriteLayer@ layer = this.addSpriteLayer("mainaxe", "CharacterAxe.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(MainArmOffset);
			layer.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("subaxe");
		CSpriteLayer@ layer = this.addSpriteLayer("subaxe", "CharacterAxe.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(SubArmOffset);
			layer.SetRelativeZ(-2.0f);
		}
	}

	
	ReloadEquipment(this,this.getBlob());

}

void setAimValues(CSpriteLayer@ arm, bool visible, f32 angle, Vec2f around, string anim)
{
	if (arm !is null)
	{
		arm.SetVisible(visible);

		if (visible)
		{
			if (!arm.isAnimation(anim))
			{
				arm.SetAnimation(anim);
			}
		
			arm.ResetTransform();
			arm.RotateBy(angle, around);
		}
	}
}

void reloadSpriteBody(CSprite @this, CBlob @blob){
	const string texname = this.getBlob().getSexNum() == 0 ?
	                       getFilePath(getCurrentScriptName())+"/Human_Torso_Male.png" :
	                       getFilePath(getCurrentScriptName())+"/Human_Torso_Female.png";
	this.ReloadSprite(texname);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead")) //Are we dead?
	{
		
	}

	doRopeUpdate(this, null, null);
	GrappleInfo@ grapple;
	if (!blob.get("GrappleInfo", @grapple))
	{
		return;
	}
	if(!blob.hasTag("dead"))doRopeUpdate(this, blob, grapple);
	
	if(blob.getHeadNum() == 255 || Maths::FMod(getGameTime(),30) == 0){
		if(blob.getPlayer() !is null){
			blob.setHeadNum(blob.getPlayer().getHead());
			blob.setSexNum(blob.getPlayer().getSex());
			this.RemoveSpriteLayer("head");
			reloadSpriteBody(this,blob);
			int gender = blob.getPlayer().getSex();
			this.getSpriteLayer("backarm").SetFrameIndex(gender);
			this.getSpriteLayer("frontarm").SetFrameIndex(gender);
		}
	}
	
	//Animations
	
	this.animation.frame = 0;

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2) && bodyPartFunctioning(blob,"sub_arm");
	const bool action1 = blob.isKeyPressed(key_action1) && bodyPartFunctioning(blob,"main_arm");
	
	bool aimingMain = action1;
	bool aimingSub = action2;
	
	bool shielding = blob.hasTag("shielding");
	
	int bowcharge = blob.get_u16("bowcharge");
	bool bow = blob.hasTag("shootingbow");
	
	bool mainfist = blob.hasTag("main_fisting");
	int mainfist_drawback = blob.get_s16("main_fist_drawback");
	bool subfist = blob.hasTag("sub_fisting");
	int subfist_drawback = blob.get_s16("sub_fist_drawback");
	
	bool mainpole = blob.hasTag("main_poleing");
	int mainpole_drawback = blob.get_s16("main_pole_drawback");
	bool subpole = blob.hasTag("sub_poleing");
	int subpole_drawback = blob.get_s16("sub_pole_drawback");
	
	bool mainaxe = blob.hasTag("main_axeing");
	int mainaxe_drawback = blob.get_s16("main_axe_drawback");
	bool subaxe = blob.hasTag("sub_axeing");
	int subaxe_drawback = blob.get_s16("sub_axe_drawback");
	
	bool pickaxing = blob.hasTag("pickaxing");
	int pickaxe = blob.get_s16("pick_counter");
	
	bool PickMain = false;
	bool PickSub = false;
	if(pickaxing){
		PickMain = (getEquipedHandType(blob, blob.get_string("equipment_main_arm_name")) == 2 && action1);
		PickSub = (getEquipedHandType(blob, blob.get_string("equipment_sub_arm_name")) == 2 && action2);
	}
	
	Vec2f pos = blob.getPosition();
	Vec2f aimpos = blob.getAimPos();
	Vec2f vec = aimpos - pos;
	f32 angle = -vec.Angle();
	
	
	
	if (this.isFacingLeft())
	{
		angle = 180.0f + angle;
	}

	while (angle > 180.0f)
	{
		angle -= 360.0f;
	}

	while (angle < -180.0f)
	{
		angle += 360.0f;
	}

	if (!blob.hasTag(burning_tag) && !blob.hasTag("dead"))
	{
		const bool left = blob.isKeyPressed(key_left);
		const bool right = blob.isKeyPressed(key_right);
		const bool up = blob.isKeyPressed(key_up);
		const bool down = blob.isKeyPressed(key_down);
		const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
		Vec2f pos = blob.getPosition();

		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}

		
		if (knocked > 0)
		{
			if (inair)
			{
				this.SetAnimation("knocked_air");
			}
			else
			{
				this.SetAnimation("knocked");
			}
		}
		else if (blob.hasTag("seated"))
		{
			this.SetAnimation("crouch");
		}
		else if (inair)
		{
			RunnerMoveVars@ moveVars;
			if (!blob.get("moveVars", @moveVars))
			{
				return;
			}
			Vec2f vel = blob.getVelocity();
			f32 vy = vel.y;
			if (vy < -0.0f && moveVars.walljumped)
			{
				this.SetAnimation("run");
			}
			else
			{
				this.SetAnimation("fall");
				this.animation.timer = 0;

				if (vy < -1.5)
				{
					//this.animation.frame = 0;
				}
				else if (vy > 1.5)
				{
					//this.animation.frame = 2;
				}
				else
				{
					//this.animation.frame = 1;
				}
			}
		}
		
		if ((left || right) ||
		         (blob.isOnLadder() && (up || down)))
		{
			this.getSpriteLayer("frontleg").SetAnimation("run");
			this.getSpriteLayer("backleg").SetAnimation("run");
		}
		else
		{
			// get the angle of aiming with mouse
			Vec2f aimpos = blob.getAimPos();
			Vec2f vec = aimpos - pos;
			f32 angle = vec.Angle();
			int direction;

			if ((angle > 330 && angle < 361) || (angle > -1 && angle < 30) ||
			        (angle > 150 && angle < 210))
			{
				direction = 0;
			}
			else if (aimpos.y < pos.y)
			{
				direction = -1;
			}
			else
			{
				direction = 1;
			}

			this.getSpriteLayer("frontleg").SetAnimation("default");
			this.getSpriteLayer("backleg").SetAnimation("default");
		}
	}

	
	
	
	
	bool mainarmvisible = true;
	bool subarmvisible = true;

	if(blob.get_s8("main_arm_type") < 0)mainarmvisible = false;
	if(blob.get_s8("sub_arm_type") < 0)subarmvisible = false;
	
	int Down = 90;
	if (this.isFacingLeft())Down = 270;
	
	this.getSpriteLayer("frontarm").SetOffset(MainArmOffset);
	this.getSpriteLayer("backarm").SetOffset(SubArmOffset);
	
	int Wobble = (this.getSpriteLayer("frontleg").getFrame()-1);
	if(Wobble == 0)Wobble = 0;
	if(Wobble == 1)Wobble = 1;
	if(Wobble == 2)Wobble = 0;
	if(Wobble == 3)Wobble = -1;
	if(this.getSpriteLayer("frontleg").isAnimation("default"))Wobble = 0;
	
	if(shielding || bow){
		aimingMain = true;
		aimingSub = true;
	}
	
	if(aimingMain){
		setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "stretch");
	} else {
		setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, Down+Wobble*20, Vec2f(0, 0), "default");
		if(blob.getCarriedBlob() !is null){
			int Carry = -20;
			if (this.isFacingLeft())Carry = 20;
			setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, Down+Carry*2, Vec2f(0, 0), "default");
		} else if (is_emote(blob, 255, true))
		{
			setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "point");
		}
	}
	if(aimingSub){
		setAimValues(this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
	} else {
		setAimValues(this.getSpriteLayer("backarm"), subarmvisible, Down-Wobble*20, Vec2f(0, 0), "default");
		if(blob.getCarriedBlob() !is null){
			int Carry = -20;
			if (this.isFacingLeft())Carry = 20;
			setAimValues(this.getSpriteLayer("backarm"), subarmvisible, Down+Carry, Vec2f(0, 0), "default");
		}
	}
	

	int inverse = -1;
	if(this.isFacingLeft())inverse = 1;

	if(mainaxe){
		setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, angle-70*inverse+mainaxe_drawback*inverse*10, Vec2f(0, 0), "stretch");
		setAimValues(this.getSpriteLayer("mainaxe"), true, angle-70*inverse+mainaxe_drawback*inverse*10, Vec2f(0, 0), "default");
	} else setAimValues(this.getSpriteLayer("mainaxe"), false, 0, Vec2f(0, 0), "default");
	
	if(subaxe){
		setAimValues(this.getSpriteLayer("backarm"), subarmvisible, angle-70*inverse+subaxe_drawback*inverse*10, Vec2f(0, 0), "stretch");
		setAimValues(this.getSpriteLayer("subaxe"), true, angle-70*inverse+subaxe_drawback*inverse*10, Vec2f(0, 0), "default");
	} else setAimValues(this.getSpriteLayer("subaxe"), false, 0, Vec2f(0, 0), "default");

	
	if(pickaxing){
	
		if(PickMain){
			setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, angle-70*inverse+pickaxe*inverse*15, Vec2f(0, 0), "stretch");
			setAimValues(this.getSpriteLayer("mainpick"), true, angle-70*inverse+pickaxe*inverse*15, Vec2f(0, 0), "default");
		}
		if(PickSub){
			setAimValues(this.getSpriteLayer("backarm"), subarmvisible, angle-70*inverse+pickaxe*inverse*15, Vec2f(0, 0), "stretch");
			setAimValues(this.getSpriteLayer("subpick"), true, angle-70*inverse+pickaxe*inverse*15, Vec2f(0, 0), "default");
		}
	
	} else {
		setAimValues(this.getSpriteLayer("mainpick"), false, 0, Vec2f(0, 0), "default");
		setAimValues(this.getSpriteLayer("subpick"), false, 0, Vec2f(0, 0), "default");
	}
	
	if(grapple.grappling){
		Vec2f off = grapple.grapple_pos - blob.getPosition();
		int grappleAngle = -off.Angle();
		if (this.isFacingLeft())
		{
			grappleAngle = 180.0f + grappleAngle;
		}
		setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, grappleAngle, Vec2f(0, 0), "stretch");
		setAimValues(this.getSpriteLayer("backarm"), subarmvisible, grappleAngle, Vec2f(0, 0), "stretch");
	}
	
	if(mainfist){
		if(mainfist_drawback < 0)setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "punch");
		else setAimValues(this.getSpriteLayer("frontarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
		
		f32 RadAngle = float(angle)/1000*17.4;

		int test = 1;
		
		if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
		else test = -1;
		
		this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(Maths::Cos(RadAngle)*mainfist_drawback*-0.15*test,Maths::Sin(RadAngle)*mainfist_drawback*-0.15));
	}
	
	if(subfist){
		if(subfist_drawback < 0)setAimValues(this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "punch");
		else setAimValues(this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
		
		f32 RadAngle = float(angle)/1000*17.4;

		int test = 1;
		
		if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
		else test = -1;
		
		this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f(Maths::Cos(RadAngle)*subfist_drawback*-0.15*test,Maths::Sin(RadAngle)*subfist_drawback*-0.15));
	}
	
	if(mainpole){
		f32 RadAngle = float(angle)/1000*17.4;

		int test = 1;
		
		if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
		else test = -1;
		
		this.getSpriteLayer("main_pole").SetOffset(Vec2f(2.0,3.0)+Vec2f(Maths::Cos(RadAngle)*mainpole_drawback*-0.2*test,Maths::Sin(RadAngle)*mainpole_drawback*-0.2));

		setAimValues(this.getSpriteLayer("main_pole"), true, angle, Vec2f(0, 0), "default");
		
		setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, Down-mainpole_drawback*test, Vec2f(0, 0), "default");
	} else {
		setAimValues(this.getSpriteLayer("main_pole"), false, angle, Vec2f(0, 0), "default");
	}
	
	if(subpole){
		f32 RadAngle = float(angle)/1000*17.4;

		int test = 1;
		
		if(this.isFacingLeft())RadAngle = float(angle-180)/1000*17.4;
		else test = -1;
		
		this.getSpriteLayer("sub_pole").SetOffset(Vec2f(2.0,1.0)+Vec2f(Maths::Cos(RadAngle)*subpole_drawback*-0.2*test,Maths::Sin(RadAngle)*subpole_drawback*-0.2));

		setAimValues(this.getSpriteLayer("sub_pole"), true, angle, Vec2f(0, 0), "default");
		
		setAimValues(this.getSpriteLayer("backarm"), subarmvisible, Down-subpole_drawback*test, Vec2f(0, 0), "default");
	} else {
		setAimValues(this.getSpriteLayer("sub_pole"), false, angle, Vec2f(0, 0), "default");
	}
	
	if(bow){
		if(bowcharge <= 20)this.getSpriteLayer("bow").SetFrameIndex(0);
		else if(bowcharge == 40)this.getSpriteLayer("bow").SetFrameIndex(2);
		else this.getSpriteLayer("bow").SetFrameIndex(1);
		
		if(!this.isFacingLeft())setAimValues(this.getSpriteLayer("bow"), true, angle, Vec2f(-0.0, 0), "default");
		else setAimValues(this.getSpriteLayer("bow"), true, angle, Vec2f(0.0, 0), "default");
		
		f32 offset = 3;
		
		if(this.getSpriteLayer("bow").getFrameIndex() == 0)offset = 1;
		if(this.getSpriteLayer("bow").getFrameIndex() == 1)offset = 3;
		if(this.getSpriteLayer("bow").getFrameIndex() == 2)offset = 5;
		if(this.getSpriteLayer("bow").getFrameIndex() == 3)offset = 5;
		
		this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(offset,0));
		
		if(!this.isFacingLeft())offset = -offset;

		setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(offset, 0), "open_hand");
		setAimValues(this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
	} else {
		setAimValues(this.getSpriteLayer("bow"), false, angle, Vec2f(0, 0), "default");
	}
	
	
	
	if(shielding && !blob.hasTag("dead")){
		
		if(vec.Angle() > 45 && vec.Angle() < 135){
			setAimValues(this.getSpriteLayer("shield"), true, 0, Vec2f(0, 0), "raised");
			if(this.isFacingLeft()){
				setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, 110, Vec2f(0, 0), "stretch");
				setAimValues(this.getSpriteLayer("backarm"), subarmvisible, 70, Vec2f(0, 0), "stretch");
			} else {
				setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, 250, Vec2f(0, 0), "stretch");
				setAimValues(this.getSpriteLayer("backarm"), subarmvisible, 290, Vec2f(0, 0), "stretch");
			}
		} else
		if(vec.Angle() > 270-45 && vec.Angle() < 270+45){
			setAimValues(this.getSpriteLayer("shield"), true, 0, Vec2f(0, 0), "slide");
			this.animation.frame = 2;
			
			this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(0,2));
			this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f(0,2));
			
			if(this.isFacingLeft()){
				setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, 290, Vec2f(0, 0), "stretch");
				setAimValues(this.getSpriteLayer("backarm"), subarmvisible, 290, Vec2f(0, 0), "stretch");
			} else {
				setAimValues(this.getSpriteLayer("frontarm"), mainarmvisible, 70, Vec2f(0, 0), "stretch");
				setAimValues(this.getSpriteLayer("backarm"), subarmvisible, 70, Vec2f(0, 0), "stretch");
			}
		} else setAimValues(this.getSpriteLayer("shield"), true, angle, Vec2f(0, 0), "default");
	} else setAimValues(this.getSpriteLayer("shield"), false, angle, Vec2f(0, 0), "default");
	
	//set the attack head

	if (knocked > 0) //Are we stunned?
	{
		blob.Tag("dead head"); //Use the 'dead' head.
	}
	else if (blob.isInFlames()) //Are we using our left click ability or are we on fire?
	{
		blob.Tag("attack head"); //Set our head to the 'attack' head
		blob.Untag("dead head"); //Unset our head from 'dead' head.
	}
	else //Other wise
	{
		blob.Untag("attack head");  //Unset 'attack' head
		blob.Untag("dead head"); //Unset 'dead' head
		//This'll make our head normal
	}
}

void DrawCursorAt(Vec2f position, string& in filename) //Draw the cursor. Exactly what it says on the tin.
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}

	// draw tile cursor

	if ((getEquipedHandType(blob, blob.get_string("equipment_main_arm_name")) == 2 && blob.isKeyPressed(key_action1) && bodyPartFunctioning(blob,"main_arm")) || (getEquipedHandType(blob, blob.get_string("equipment_sub_arm_name")) == 2 && blob.isKeyPressed(key_action2) && bodyPartFunctioning(blob,"sub_arm")))
	{

		HitData@ hitdata;
		blob.get("hitdata", @hitdata);
		CBlob@ hitBlob = hitdata.blobID > 0 ? getBlobByNetworkID(hitdata.blobID) : null;

		if (hitBlob !is null) // blob hit
		{
			if (!hitBlob.hasTag("flesh"))
			{
				hitBlob.RenderForHUD(RenderStyle::outline);
			}
		}
		else// map hit
		{
			DrawCursorAt(hitdata.tilepos, cursorTexture);
		}
	}
}