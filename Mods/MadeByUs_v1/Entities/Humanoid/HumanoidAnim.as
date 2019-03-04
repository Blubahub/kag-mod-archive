// Template animations

#include "FireCommon.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "GrappleCommon.as";
#include "HumanoidCommon.as";
#include "EmotesCommon.as";

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
		Animation@ anim1 = frontarm.addAnimation("punch", 0, false);
		anim1.AddFrame(1);
		Animation@ anim2 = frontarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(2);
		Animation@ anim3 = frontarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(3);
		frontarm.SetOffset(MainArmOffset);
		frontarm.SetRelativeZ(3.0f);
	}
	
	this.RemoveSpriteLayer("backarm");
	CSpriteLayer@ backarm = this.addSpriteLayer("backarm", "Human_Sub_Arm.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		Animation@ anim1 = backarm.addAnimation("punch", 0, false);
		anim1.AddFrame(1);
		Animation@ anim2 = backarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(2);
		Animation@ anim3 = backarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(3);
		backarm.SetOffset(SubArmOffset);
		backarm.SetRelativeZ(-3.0f);
	}
	
	this.RemoveSpriteLayer("frontleg");
	CSpriteLayer@ frontleg = this.addSpriteLayer("frontleg", "Human_Front_Leg.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontleg !is null)
	{
		Animation@ anim1 = frontleg.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		Animation@ anim = frontleg.addAnimation("run", 2, true);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		frontleg.SetOffset(Vec2f(1.0f, -0.5f));
		frontleg.SetRelativeZ(2.0f);
	}
	
	this.RemoveSpriteLayer("backleg");
	CSpriteLayer@ backleg = this.addSpriteLayer("backleg", "Human_Back_Leg.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backleg !is null)
	{
		Animation@ anim1 = backleg.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		Animation@ anim = backleg.addAnimation("run", 2, true);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		backleg.SetOffset(Vec2f(2.0f, -0.5f));
		backleg.SetRelativeZ(-2.0f);
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
		shield.SetOffset(Vec2f(2.0f, -0.5f));
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
		bow.SetOffset(Vec2f(2.0f, -0.5f));
		bow.SetRelativeZ(9.0f);
	}
	
	this.RemoveSpriteLayer("bowhand");
	CSpriteLayer@ bowhand = this.addSpriteLayer("bowhand", "Human_Main_Arm.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (bowhand!is null)
	{
		Animation@ anim = bowhand.addAnimation("default", 0, false);
		anim.AddFrame(2);
		bowhand.SetOffset(Vec2f(2.0f, -0.5f));
		bowhand.SetRelativeZ(9.5f);
	}
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

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob(); //^What that guy said

	if (blob.hasTag("dead")) //Are we dead?
	{
		this.SetAnimation("dead"); //Set our animation to dead.
		Vec2f vel = blob.getVelocity(); //Get our speed

		if (vel.y < -1.0f) //These change our sprite depending on if we are falling, flying or lying down. While dead.
		{
			this.SetFrameIndex(0);
		}
		else if (vel.y > 1.0f)
		{
			this.SetFrameIndex(2);
		}
		else
		{
			this.SetFrameIndex(1);
		}
	}

	doRopeUpdate(this, null, null);
	GrappleInfo@ grapple;
	if (!blob.get("GrappleInfo", @grapple))
	{
		return;
	}
	if(!blob.hasTag("dead"))doRopeUpdate(this, blob, grapple);
	
	//Animations

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2) && bodyPartFunctioning(blob,"sub_arm");
	const bool action1 = blob.isKeyPressed(key_action1) && bodyPartFunctioning(blob,"main_arm");
	
	bool aiming = (action1 || action2);
	
	bool shielding = blob.hasTag("shielding");
	
	int bowcharge = blob.get_u16("bowcharge");
	bool bow = blob.hasTag("shootingbow");
	
	bool mainfist = blob.hasTag("main_fisting");
	int mainfist_drawback = blob.get_s16("main_fist_drawback");
	bool subfist = blob.hasTag("sub_fisting");
	int subfist_drawback = blob.get_s16("sub_fist_drawback");
	
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
					this.animation.frame = 0;
				}
				else if (vy > 1.5)
				{
					this.animation.frame = 2;
				}
				else
				{
					this.animation.frame = 1;
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

	
	
	
	
	bool armvisible = true;
	
	if(blob.hasTag("dead"))armvisible = false;
	
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
	
	if(aiming){
		setAimValues(this.getSpriteLayer("frontarm"), armvisible, angle, Vec2f(0, 0), "stretch");
		setAimValues(this.getSpriteLayer("backarm"), armvisible, angle, Vec2f(0, 0), "stretch");
	} else {
		setAimValues(this.getSpriteLayer("frontarm"), armvisible, Down+Wobble*10, Vec2f(0, 0), "default");
		setAimValues(this.getSpriteLayer("backarm"), armvisible, Down-Wobble*10, Vec2f(0, 0), "default");
		if(blob.getCarriedBlob() !is null){
			int Carry = -20;
			if (this.isFacingLeft())Carry = 20;
			setAimValues(this.getSpriteLayer("frontarm"), armvisible, Down+Carry*2, Vec2f(0, 0), "default");
			setAimValues(this.getSpriteLayer("backarm"), armvisible, Down+Carry, Vec2f(0, 0), "default");
		} else if (is_emote(blob, 255, true))
		{
			setAimValues(this.getSpriteLayer("frontarm"), armvisible, angle, Vec2f(0, 0), "stretch");
			setAimValues(this.getSpriteLayer("backarm"), armvisible, 100, Vec2f(0, 0), "default");
		}
	}
	
	if(mainfist){
		if(mainfist_drawback < 0)setAimValues(this.getSpriteLayer("frontarm"), armvisible, angle, Vec2f(0, 0), "punch");
		else setAimValues(this.getSpriteLayer("frontarm"), armvisible, angle, Vec2f(0, 0), "stretch");
		
		this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f((mainfist_drawback*1.0)/10.0,0));
		
		if(!subfist)setAimValues(this.getSpriteLayer("backarm"), armvisible, Down, Vec2f(0, 0), "default");
	}
	
	if(subfist){
		if(subfist_drawback < 0)setAimValues(this.getSpriteLayer("backarm"), armvisible, angle, Vec2f(0, 0), "punch");
		else setAimValues(this.getSpriteLayer("backarm"), armvisible, angle, Vec2f(0, 0), "stretch");
		
		this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f((subfist_drawback*1.0)/10.0,0));
		
		if(!mainfist)setAimValues(this.getSpriteLayer("frontarm"), armvisible, Down, Vec2f(0, 0), "default");
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
		
		this.getSpriteLayer("bowhand").SetOffset(Vec2f(2.0f+offset,-0.5f));
		
		if(!this.isFacingLeft())offset = -offset;
		
		setAimValues(this.getSpriteLayer("bowhand"), true, angle, Vec2f(offset, 0), "default");
		setAimValues(this.getSpriteLayer("frontarm"), false, angle, Vec2f(0, 0), "default");
	} else {
		setAimValues(this.getSpriteLayer("bow"), false, angle, Vec2f(0, 0), "default");
		setAimValues(this.getSpriteLayer("bowhand"), false, angle, Vec2f(0, 0), "default");
	}
	
	
	
	if(shielding && !blob.hasTag("dead")){
		if(vec.Angle() > 45 && vec.Angle() < 135){
			setAimValues(this.getSpriteLayer("shield"), true, 0, Vec2f(0, 0), "raised");
			if(this.isFacingLeft()){
				setAimValues(this.getSpriteLayer("frontarm"), true, 110, Vec2f(0, 0), "stretch");
				setAimValues(this.getSpriteLayer("backarm"), true, 70, Vec2f(0, 0), "stretch");
			} else {
				setAimValues(this.getSpriteLayer("frontarm"), true, 250, Vec2f(0, 0), "stretch");
				setAimValues(this.getSpriteLayer("backarm"), true, 290, Vec2f(0, 0), "stretch");
			}
		} else
		if(vec.Angle() > 270-45 && vec.Angle() < 270+45){
			setAimValues(this.getSpriteLayer("shield"), true, 0, Vec2f(0, 0), "slide");
			this.SetAnimation("crouch");
			if(this.isFacingLeft()){
				setAimValues(this.getSpriteLayer("frontarm"), true, 290, Vec2f(0, 0), "stretch");
				setAimValues(this.getSpriteLayer("backarm"), true, 290, Vec2f(0, 0), "stretch");
			} else {
				setAimValues(this.getSpriteLayer("frontarm"), true, 70, Vec2f(0, 0), "stretch");
				setAimValues(this.getSpriteLayer("backarm"), true, 70, Vec2f(0, 0), "stretch");
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