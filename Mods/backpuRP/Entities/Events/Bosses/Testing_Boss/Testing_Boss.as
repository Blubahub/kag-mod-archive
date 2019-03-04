//player grave
#include "ModName"

void onInit(CBlob@ this)
{
	print("robot_mecha started");
	CSprite@ mechaSprite = this.getSprite();
	mechaSprite.RemoveSpriteLayer("rightArm");
	CSpriteLayer@ rightArm = mechaSprite.addSpriteLayer("rightArm", "mecha_boss_right_arm.png" , 9, 46);
	if(rightArm !is null)
	{
		rightArm.SetOffset(Vec2f(-20, 0));
		rightArm.SetRelativeZ(1);
		rightArm.RotateBy(90.0f,Vec2f(-20,0));
	}
	print("done");
}


void onTick(CBlob@ this)
{
	/*CSpriteLayer@ rightArm = this.getSprite().getSpriteLayer("rightArm");
	if(rightArm !is null)
	{
		rightArm.RotateBy(1.0f,Vec2f(40,40));
	}*/

}

void onDie(CBlob@ this)
{
	
}
