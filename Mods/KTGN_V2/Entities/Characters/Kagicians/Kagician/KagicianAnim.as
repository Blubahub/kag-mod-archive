// Kagician animations

#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as"
#include "RunnerCommon.as"
#include "Knocked.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "MagicCommon.as"

//

void onInit(CSprite@ this)
{
	addRunnerTextures(this, "kagician", "Kagician");

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	CSpriteLayer@ layer = this.addSpriteLayer("orbs", "Orble.png", 32, 32);
	if(layer !is null)
	{
		layer.SetOffset(Vec2f(-6, -9));
		layer.SetRelativeZ(1.0f);
	}
	CBlob@ b = this.getBlob();
	b.set_f32("orbscale", 1.0f);
}

void onPlayerInfoChanged(CSprite@ this)
{
	ensureCorrectRunnerTexture(this, "kagician", "Kagician");
}

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		this.SetAnimation("dead");
		Vec2f vel = blob.getVelocity();

		if (vel.y < -1.0f)
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
		return;
	}
	// animations

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2);
	const bool action2rel = blob.isKeyJustReleased(key_action2);
	const bool action1 = blob.isKeyPressed(key_action1);
	
	if (!blob.hasTag(burning_tag)) //give way to burning anim
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

		
		CSpriteLayer@ layer = this.getSpriteLayer("orbs");
		if(layer !is null)
		{
			if(action2)
			{
				
				u16 charge = blob.get_u16("charge");
				layer.SetVisible(true);
				layer.RotateBy(charge * (this.isFacingLeft() ? -0.08f : 0.08f), Vec2f());
				float amount = 1.003f;
				int maxcharge = getChargeMax(blob.get_u8("firestyle"), blob.get_u8("stylepower"));
				/*if(this.isAnimation(""))//??
				{
					getFrame()
					switch()
				}*/
				if(charge >= maxcharge)
				{
					layer.SetFrame(2);
				}
				else 
				{
					//No scaling if it's fully charged.
					blob.set_f32("orbscale", blob.get_f32("orbscale") * amount);
					layer.ScaleBy(Vec2f(amount, amount));
					if(canCast(blob)) //show colour change so that they knows
					{
						layer.SetFrame(1);
					}
					else
					{
						layer.SetFrame(0);
					}
				}
			}
			else if(blob.get_f32("orbscale") > 0.5f) //hopefully it only does this once.
			{
				float amount = 0.5f / blob.get_f32("orbscale");
				blob.set_f32("orbscale", blob.get_f32("orbscale") * amount);
				layer.ScaleBy(Vec2f(amount, amount));
				layer.SetVisible(false);
			}
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
		else if (action2rel || (this.isAnimation("cast") && !this.isAnimationEnded()))
		{
			this.SetAnimation("cast");
		}
		else if (blob.hasTag("seated"))
		{
			this.SetAnimation("crouch");
		}
		else if (action2 || (this.isAnimation("strike") && !this.isAnimationEnded()))
		{
			this.SetAnimation("strike");
			CSpriteLayer@ layer = this.getSpriteLayer("orbs");
		}
		else
		{
			if (action1  || (this.isAnimation("build") && !this.isAnimationEnded()))
			{
				this.SetAnimation("build");
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
	}

	//set the attack head

	if (knocked > 0)
	{
		blob.Tag("dead head");
	}
	else if (action2 || blob.isInFlames())
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}
}

/*void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
}*/