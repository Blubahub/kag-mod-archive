// Template animations

#include "FireCommon.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "GrappleCommon.as";

void onInit(CSprite@ this)
{
	const string texname = "Grabber.png"; //These three lines are like coder magic. Don't touch em unless you want it to stop working. Only change the names of the .pngs.
	this.ReloadSprite(texname); //This resets the sprite to use the new sprites.

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	
	//grapple
	this.RemoveSpriteLayer("hook");
	CSpriteLayer@ hook = this.addSpriteLayer("hook", "GrabberHook.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (hook !is null)
	{
		Animation@ anim = hook.addAnimation("default", 0, false);
		anim.AddFrame(0);
		hook.SetRelativeZ(2.0f);
		hook.SetVisible(false);
	}

	this.RemoveSpriteLayer("rope");
	CSpriteLayer@ rope = this.addSpriteLayer("rope", "GrabberHook.png" , 32, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rope !is null)
	{
		Animation@ anim = rope.addAnimation("default", 0, false);
		anim.AddFrame(3);
		rope.SetRelativeZ(-1.5f);
		rope.SetVisible(false);
	}
	
	this.RemoveSpriteLayer("hookoff");
	CSpriteLayer@ hookoff = this.addSpriteLayer("hookoff", texname, 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (hookoff !is null)
	{
		Animation@ anim = hookoff.addAnimation("default", 0, false);
		anim.AddFrame(16);
		hookoff.SetRelativeZ(-1.5f);
		hookoff.SetVisible(true);
		hookoff.SetOffset(Vec2f(0,-8));
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
	
	CSpriteLayer@ hookoff = this.getSpriteLayer("hookoff");
	if(grapple.grappling){
		hookoff.SetVisible(false);
	} else {
		hookoff.SetVisible(true);
		if(!this.isFacingLeft())hookoff.SetOffset(Vec2f(0,-8)+Vec2f(blob.getVelocity().x,-blob.getVelocity().y)*2.0f);
		else hookoff.SetOffset(Vec2f(0,-8)+Vec2f(-blob.getVelocity().x,-blob.getVelocity().y)*2.0f);
	}
	
	//Animations

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2);
	const bool action1 = blob.isKeyPressed(key_action1);
	
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
		else if (blob.get_s16("attack_cooldown") > 0)
		{
			if(!this.isAnimation("punch"))this.SetAnimation("punch");
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
		else if ((left || right) ||
		         (blob.isOnLadder() && (up || down)))
		{
			this.SetAnimation("run");
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

			defaultIdleAnim(this, blob, direction);
		}
	}

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