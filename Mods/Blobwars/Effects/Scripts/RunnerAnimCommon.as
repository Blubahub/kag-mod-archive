#include "EmotesCommon.as";

void defaultIdleAnim(CSprite@ this, CBlob@ blob, int direction)
{
	CControls@ cc = blob.getControls();
	if (cc.isKeyPressed(KEY_KEY_DOWN))
	{
		this.SetAnimation("crouch");
	}
	else if (is_emote(blob, 255, true))
	{
		this.SetAnimation("point");
		this.animation.frame = 1 + direction;
	}
	else
	{
		this.SetAnimation("default");
	}
}
