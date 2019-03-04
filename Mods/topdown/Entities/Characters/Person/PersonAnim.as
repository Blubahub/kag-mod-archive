// Person animations

#include "PersonCommon.as"
#include "FireParticle.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "Hitters.as";
#include "ExtraSparks.as";
#include "PersonLogic.as";
//#include "CustomAnim.as";
const f32 config_offset = 14.0f;

void onInit(CSprite@ this)
{
	//LoadSprites2(this);
	this.SetEmitSoundPaused(false);
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{

	CSprite@ sprite = this.getSprite();
	CPlayer@ player = this.getPlayer();
	if(sprite !is null && player is null && !this.hasTag("dead"))
	{
		u16 randomnum = XORRandom(4);
		string texname = "../Mods/osmod/Entities/Characters/Skins/Default_"+randomnum+".png";
		LoadSprites(sprite, texname);

	}
}

void LoadSprites(CSprite@ this, string texname)
{
	//u16 randomnum = XORRandom(4);
	//string texname = "../Mods/osmod/Entities/Characters/Skins/Default_"+randomnum+".png";
	//this.ReloadSprite(randomskin);
	//this.set_string("skinpath", randomskin);
	//LoadSprites2(this, randomskin);
	/*
	string texname = "BodyParts.png";
	
	CBlob@ blob = this.getBlob();
	if(blob !is null)
	{	
		CPlayer@ player = blob.getPlayer();
		if(player !is null)
		{
			texname = blob.get_string("skinpath2");

		}

	}*/

	this.ReloadSprite(texname, this.getConsts().frameWidth, this.getConsts().frameHeight,
	                  this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	this.RemoveSpriteLayer("head");
	CSpriteLayer@ head = this.addSpriteLayer("head", texname, 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (head !is null)
	{
		Animation@ anim = head.addAnimation("default", 0, false);
		anim.AddFrame(3);
		head.SetOffset(Vec2f(0.0f, 3.0f + config_offset));
		head.SetAnimation("default");
		head.SetVisible(true);
		head.SetRelativeZ(0.15);
	}

	this.RemoveSpriteLayer("rightarm");
	CSpriteLayer@ rightarm = this.addSpriteLayer("rightarm", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightarm !is null)
	{
		Animation@ anim = rightarm.addAnimation("default", 0, false);
		anim.AddFrame(3);
		rightarm.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightarm.SetAnimation("default");
		rightarm.SetVisible(true);
		rightarm.SetRelativeZ(-0.5);
	}

	this.RemoveSpriteLayer("leftarm");
	CSpriteLayer@ leftarm = this.addSpriteLayer("leftarm", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftarm !is null)
	{
		Animation@ anim = leftarm.addAnimation("default", 0, false);
		anim.AddFrame(2);
		leftarm.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		leftarm.SetAnimation("default");
		leftarm.SetVisible(true);
		leftarm.SetRelativeZ(-0.5);
	}

	this.RemoveSpriteLayer("righthand");
	CSpriteLayer@ righthand = this.addSpriteLayer("righthand", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (righthand !is null)
	{
		Animation@ anim = righthand.addAnimation("default", 0, false);
		anim.AddFrame(5);
		righthand.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		righthand.SetAnimation("default");
		righthand.SetVisible(true);
		righthand.SetRelativeZ(-0.3);
	}
	this.RemoveSpriteLayer("lefthand");
	CSpriteLayer@ lefthand = this.addSpriteLayer("lefthand", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (lefthand !is null)
	{
		Animation@ anim = lefthand.addAnimation("default", 0, false);
		anim.AddFrame(4);
		lefthand.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		lefthand.SetAnimation("default");
		lefthand.SetVisible(true);
		lefthand.SetRelativeZ(-0.3);
	}
	this.RemoveSpriteLayer("rightleg");
	CSpriteLayer@ rightleg = this.addSpriteLayer("rightleg", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightleg !is null)
	{
		Animation@ anim = rightleg.addAnimation("default", 0, false);
		anim.AddFrame(9);
		rightleg.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightleg.SetAnimation("default");
		rightleg.SetVisible(true);
		rightleg.SetRelativeZ(-1.5);
	}


	this.RemoveSpriteLayer("leftleg");
	CSpriteLayer@ leftleg = this.addSpriteLayer("leftleg", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftleg !is null)
	{
		Animation@ anim = leftleg.addAnimation("default", 0, false);
		anim.AddFrame(8);
		leftleg.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		leftleg.SetAnimation("default");
		leftleg.SetVisible(true);
		leftleg.SetRelativeZ(-1.5);
	}

	this.RemoveSpriteLayer("leftfoot");
	CSpriteLayer@ leftfoot = this.addSpriteLayer("leftfoot", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftfoot !is null)
	{
		Animation@ anim = leftfoot.addAnimation("default", 0, false);
		anim.AddFrame(10);
		leftfoot.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		leftfoot.SetAnimation("default");
		leftfoot.SetVisible(true);
		leftfoot.SetRelativeZ(-2.0);
	}

	this.RemoveSpriteLayer("rightfoot");
	CSpriteLayer@ rightfoot = this.addSpriteLayer("rightfoot", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightfoot !is null)
	{
		Animation@ anim = rightfoot.addAnimation("default", 0, false);
		anim.AddFrame(11);
		rightfoot.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightfoot.SetAnimation("default");
		rightfoot.SetVisible(true);
		rightfoot.SetRelativeZ(-2.0);
	}


}/*
void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	return;
	// animations

}

void UpdateBody(CSprite@ this, CBlob@ blob)
{

	CSpriteLayer@ leftarm = this.getSpriteLayer("leftarm");

	CSpriteLayer@ rightarm = this.getSpriteLayer("rightarm");

	CSpriteLayer@ lefthand = this.getSpriteLayer("lefthand");

	CSpriteLayer@ righthand = this.getSpriteLayer("righthand");

	CSpriteLayer@ rightleg = this.getSpriteLayer("rightleg");
	CSpriteLayer@ leftleg = this.getSpriteLayer("leftleg");

	CSpriteLayer@ rightfoot = this.getSpriteLayer("rightfoot");
	CSpriteLayer@ leftfoot = this.getSpriteLayer("leftfoot");
	setLegValues(blob, rightleg, leftleg, rightfoot, leftfoot, rightarm, leftarm, righthand, lefthand);

	// fire arrow particles

}*/

bool IsAiming(CBlob@ blob)
{
	return blob.isKeyPressed(key_action2);
}


void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0f;
	const u8 team = blob.getTeamNum();
	CParticle@ Body     = makeGibParticle("Entities/Characters/Person/PersonGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm      = makeGibParticle("Entities/Characters/Person/PersonGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Entities/Characters/Person/PersonGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Entities/Characters/Person/PersonGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}

