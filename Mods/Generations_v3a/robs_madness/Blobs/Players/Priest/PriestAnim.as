// Priest animations

#include "PriestCommon.as"
#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

void onInit(CSprite@ this)
{
	const string texname = this.getBlob().getSexNum() == 0 ?
	                       "PriestMale.png" :
	                       "PriestFemale.png";
	this.ReloadSprite(texname);

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	this.RemoveSpriteLayer("aura");
	CSpriteLayer@ aura = this.addSpriteLayer("aura", "aura.png" , 96, 96, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (aura !is null)
	{
		Animation@ anim = aura.addAnimation("default", 0, false);
		anim.AddFrame(0);
		aura.SetOffset(Vec2f(0,0));
		aura.SetAnimation("default");
		aura.SetVisible(false);
		aura.SetRelativeZ(-100.0f);
		aura.setRenderStyle(RenderStyle::additive);
	}
	
	CSpriteLayer@ smite = this.addSpriteLayer("smite", "GammaLaser.png", 32, 8);
	
	if(smite !is null)
	{
		Animation@ anim = smite.addAnimation("default", 0, false);
		anim.AddFrame(0);
		smite.SetRelativeZ(-1.0f);
		smite.SetVisible(false);
		smite.setRenderStyle(RenderStyle::additive);
		smite.SetOffset(Vec2f(-9.0f, 0.0f));
	}
}


void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		this.SetAnimation("dead");
		Vec2f vel = blob.getVelocity();
		if(this.getSpriteLayer("aura") !is null)this.getSpriteLayer("aura").SetVisible(false);
		if(this.getSpriteLayer("smite") !is null)this.getSpriteLayer("smite").SetVisible(false);
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

	
	if(this.getSpriteLayer("aura") !is null){
		this.getSpriteLayer("aura").setRenderStyle(RenderStyle::additive);
	}
	
	if(this.getSpriteLayer("smite") !is null){
		this.getSpriteLayer("smite").setRenderStyle(RenderStyle::additive);
	}
	
	// animations

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2);
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
		
		this.getSpriteLayer("aura").SetVisible(false);
		this.getSpriteLayer("smite").SetVisible(false);
		
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
		else if (action1)
		{
			this.SetAnimation("smite");
			if(this.getSpriteLayer("smite") !is null)this.getSpriteLayer("smite").SetVisible(true);
		}
		else if (action2)
		{
			this.SetAnimation("pray");
			if(this.getSpriteLayer("aura") !is null)this.getSpriteLayer("aura").SetVisible(true);
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
	
	if (knocked > 0)
	{
		blob.Tag("dead head");
	}
	else if (action1 || blob.isInFlames())
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

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

// render cursors

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
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}
}
