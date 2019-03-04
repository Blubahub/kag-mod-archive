// Template animations

#include "BuilderCommon.as"
#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as"
#include "RunnerCommon.as"
#include "Knocked.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"


//

void onInit(CSprite@ this)
{
	addRunnerTextures(this, "link", "Link");

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
}

void onPlayerInfoChanged(CSprite@ this)
{
	ensureCorrectRunnerTexture(this, "link", "Link");
}

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob(); //^What that guy said
 
	if (blob.hasTag("dead")) //Are we dead?
	{
		this.SetAnimation("dead");
			this.SetFrameIndex(0);
		return;
	}

	// animations

	const u8 knocked = getKnocked(blob); //Are we stunned?
	const bool action2 = blob.isKeyPressed(key_action2); //Are we left clicking?
	const bool action1 = blob.isKeyPressed(key_action1); //Are we right clicking?
  const bool gotem = blob.isKeyJustReleased(key_action1);
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

		else if (blob.get_u32("SlashTime") > 0)
		{
			this.SetAnimation("attackfin");
		}
		
		else if (action1  || (this.isAnimation("attack") && !this.isAnimationEnded()))
		{
			this.SetAnimation("attack");
		}
    
		else if (left || right || up || down)
		{
      if(action2 && blob.get_f32("ShieldHealth") > 0.0f) 
      {
        this.SetAnimation("shieldrun");
      }
      else{
        this.SetAnimation("run");
      }
		}
    
    else if (action2 && blob.get_f32("ShieldHealth") > 0.0f ) {
      this.SetAnimation("shield");
    }
		else
		{
			this.SetAnimation("default");
		}
}

void DrawCursorAt(Vec2f position, string& in filename) //Draw the cursor. Exactly what it says on the tin.
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}
