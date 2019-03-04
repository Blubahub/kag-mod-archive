
#include "HumanoidAnimCommon.as";

void onInit(CBlob@ this)
{
	this.set_s8("type",0);
}

void onInit(CSprite@ this)
{
	this.animation.frame = XORRandom(2);
	this.getBlob().server_setTeamNum(-1);
}

void onTick(CSprite @this){

	CBlob @blob = this.getBlob();

	if(!blob.hasTag("load")){
		this.ReloadSprite(getBodyTypeName(blob.get_s8("type"))+"_Main_Arm.png");
		blob.Tag("load");
	}

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.1f && hitterBlob !is this)
	{
		Sound::Play("FleshHit.ogg", this.getPosition());
	}

	return damage;
}
