// Template animations


#include "BuilderCommon.as"
#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as"
#include "RunnerCommon.as"
#include "Knocked.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"


void onInit(CSprite@ this)
{
addRunnerTextures(this, "cactus", "Cactus");


	this.RemoveSpriteLayer("ball1");
	CSpriteLayer@ effect = this.addSpriteLayer("ball1", "BitProj.png" , 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (effect !is null)
	{
			
		Animation@ anim = effect.addAnimation("default", 0, false);
		anim.AddFrame(3);
		effect.SetOffset(Vec2f(0,0));
		effect.SetAnimation("default");
		effect.SetVisible(true);
		effect.SetRelativeZ(-4.0f);
    effect.SetIgnoreParentFacing(true);
	}
  
  this.RemoveSpriteLayer("ball2");
	CSpriteLayer@ effect1 = this.addSpriteLayer("ball2", "BitProj.png" , 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (effect1 !is null)
	{
			
		Animation@ anim = effect1.addAnimation("default", 0, false);
		anim.AddFrame(3);
		effect1.SetOffset(Vec2f(0,0));
		effect1.SetAnimation("default");
		effect1.SetVisible(true);
		effect1.SetRelativeZ(-4.0f);
    effect1.SetIgnoreParentFacing(true);
	}
  
  this.RemoveSpriteLayer("ball3");
	CSpriteLayer@ effect2 = this.addSpriteLayer("ball3", "BitProj.png" , 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (effect2 !is null)
	{
			
		Animation@ anim = effect2.addAnimation("default", 0, false);
		anim.AddFrame(3);
		effect2.SetOffset(Vec2f(0,0));
		effect2.SetAnimation("default");
		effect2.SetVisible(true);
		effect2.SetRelativeZ(-4.0f);
    effect2.SetIgnoreParentFacing(true);
	}
	

this.getCurrentScript().runFlags |= Script::tick_not_infire;
}

void onPlayerInfoChanged(CSprite@ this)
{
ensureCorrectRunnerTexture(this, "cactus", "Cactus");
}


void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob(); //^What that guy said
  
  Vec2f pos(12.0f,0.0f);
  this.getSpriteLayer("ball1").SetVisible(false);
  this.getSpriteLayer("ball2").SetVisible(false);
  this.getSpriteLayer("ball3").SetVisible(false);
  u32 spin = (getGameTime() *2) % 360;
  if(blob.get_u32("Reload") >= 90) {
    this.getSpriteLayer("ball1").SetVisible(true);
  }
  if(blob.get_u32("Reload") >= 180) {
    this.getSpriteLayer("ball2").SetVisible(true);
  }
  if(blob.get_u32("Reload") >= 270) {
    this.getSpriteLayer("ball3").SetVisible(true);
  }
  this.getSpriteLayer("ball1").SetOffset(pos.RotateBy(spin));
  this.getSpriteLayer("ball2").SetOffset(pos.RotateBy(120));
  this.getSpriteLayer("ball3").SetOffset(pos.RotateBy(120));

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
		return;
	}

	// animations

	const u8 knocked = getKnocked(blob); //Are we stunned?
	const bool action2 = blob.isKeyPressed(key_action2); //Are we left clicking?
	const bool action1 = blob.isKeyPressed(key_action1); //Are we right clicking?

	if (!blob.hasTag(burning_tag)) //Are we burning? If so, lets not screw with the burning animations.
	{
		const bool left = blob.isKeyPressed(key_left); //All these check for if we are pressing movment keys.
		const bool right = blob.isKeyPressed(key_right);
		const bool up = blob.isKeyPressed(key_up);
		const bool down = blob.isKeyPressed(key_down);
		const bool inair = (!blob.isOnGround() && !blob.isOnLadder()); //Are we in the air?
		Vec2f pos = blob.getPosition(); //Let's get our position

		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars)) //Do we still have our runner variables?
		{
			return; //If not, back the heck out.
		}

		
		//////////////////The following code is easy enough to understand just by reading it.
		if (left || right || up || down)
		{
      this.SetAnimation("run");
      
		}
		else 
		{
			this.SetAnimation("default");
		}
	}
}

void DrawCursorAt(Vec2f position, string& in filename) //Draw the cursor. Exactly what it says on the tin.
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}
