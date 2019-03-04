// Archer animations

#include "ArcherCommon.as"
#include "FireParticle.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "PixelOffsets.as"
#include "RunnerTextures.as"

const f32 config_offset = -3.0f;
const string shiny_layer = "shiny bit";

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
    
  CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
    CBlob@ bop = getLocalPlayerBlob();
    CMap@ map = getMap();
		if(bop !is null &&  map.rayCastSolid(blob.getPosition() , bop.getPosition()))
    {
      CSpriteLayer@ frontarm = this.getSpriteLayer("frontarm");
      if(frontarm !is null)
      {
        frontarm.SetVisible(false);
      }
      return;
    }
    else
    {
      CSpriteLayer@ frontarm = this.getSpriteLayer("frontarm");
      if(frontarm !is null)
      {
        frontarm.SetVisible(true);
      }
    }
	}
  else
  {
    CSpriteLayer@ frontarm = this.getSpriteLayer("frontarm");
      if(frontarm !is null)
      {
        frontarm.SetVisible(true);
      }
  }
	
}

void onInit(CSprite@ this)
{
	LoadSprites(this);
}

void LoadSprites(CSprite@ this)
{
	string texname = getRunnerTextureName(this);

	this.RemoveSpriteLayer("frontarm");
	CSpriteLayer@ frontarm = this.addTexturedSpriteLayer("frontarm", texname , 32, 16);

	if (frontarm !is null)
	{
		Animation@ animcharge = frontarm.addAnimation("charge", 0, false);
		animcharge.AddFrame(16);
		animcharge.AddFrame(24);
		animcharge.AddFrame(32);
		Animation@ animshoot = frontarm.addAnimation("fired", 0, false);
		animshoot.AddFrame(40);
		Animation@ animnoarrow = frontarm.addAnimation("no_arrow", 0, false);
		animnoarrow.AddFrame(25);
		frontarm.SetOffset(Vec2f(-1.0f, 5.0f + config_offset));
		frontarm.SetAnimation("fired");
		frontarm.SetVisible(false);
	}
}

void setArmValues(CSpriteLayer@ arm, bool visible, f32 angle, f32 relativeZ, string anim, Vec2f around, Vec2f offset)
{
	if (arm !is null)
	{
		arm.SetVisible(visible );

		if (visible)
		{
			if (!arm.isAnimation(anim))
			{
				arm.SetAnimation(anim);
			}

			arm.SetOffset(offset);
			arm.ResetTransform();
			arm.SetRelativeZ(relativeZ);
			arm.RotateBy(angle, around);
		}
	}
}

// stuff for shiny - global cause is used by a couple functions in a tick
bool needs_shiny = false;
Vec2f shiny_offset;
f32 shiny_angle = 0.0f;

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		if (this.animation.name != "dead")
		{
			this.SetAnimation("dead");
			this.RemoveSpriteLayer("frontarm");
		}
 }
		Vec2f vel = blob.getVelocity();


	// animations
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	needs_shiny = false;
	bool crouch = false;

	const u8 knocked = getKnocked(blob);
	Vec2f pos = blob.getPosition();
	Vec2f aimpos = blob.getAimPos();
	// get the angle of aiming with mouse
	Vec2f vec = aimpos - pos;
	f32 angle = vec.Angle();

	
	//arm anims
	Vec2f armOffset = Vec2f(-1.0f, 4.0f + config_offset);
		f32 armangle = -angle;

		if (this.isFacingLeft())
		{
			armangle = 180.0f - angle;
		}

		while (armangle > 180.0f)
		{
			armangle -= 360.0f;
		}

		while (armangle < -180.0f)
		{
			armangle += 360.0f;
		}
    f32 sign = (this.isFacingLeft() ? 1.0f : -1.0f);
    CSpriteLayer@ frontarm = this.getSpriteLayer("frontarm");
    if(frontarm !is null)
    {
      setArmValues(frontarm, hasVision(blob), armangle, 1000.0f,"defaut",Vec2f(-4.0f * sign, 0.0f), armOffset);
    }

}

bool hasVision(CBlob@ blob){
  if (!blob.isMyPlayer())
	{
    CBlob@ bop = getLocalPlayerBlob();
    CMap@ map = getMap();
		if(bop !is null &&  map.rayCastSolid(blob.getPosition() , bop.getPosition()))
    {
      return false;
    }
    else
    {
      return true;
    }
	}
  else
  {
    return true;
  }
}






