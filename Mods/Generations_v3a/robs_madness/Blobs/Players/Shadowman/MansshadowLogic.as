// Shadowman logic

#include "Hitters.as";
#include "Knocked.as";
#include "ShadowmanCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "SwapClass.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	this.Tag("evil");
	this.Tag("cant_capture");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_u16("transform_timestamp",getGameTime());
	
	this.getShape().getConsts().mapCollisions = false;
	
	this.set_u16("CooldownTwo",getGameTime()+20);
	this.Tag("DisableOne");
	
	// Sounds by TFlippy
	this.getSprite().PlaySound("WC3_Shadow_On", 1.00f, 1.00f);
	
	for(int i = 0; i < 20; i++)
	ParticleAnimated("DeathPuff.png", this.getPosition() + getRandomVelocity(0, 6, 360), getRandomVelocity(0, 2, 360), XORRandom(360), 1.0f, 2, 0.0f, false);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 10, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	
	if(getGameTime() > this.get_u16("transform_timestamp")+20)
	if(this.isKeyJustPressed(key_action2) || this.isKeyPressed(key_action1) || this.isInWater())if (getNet().isServer()){
		CBlob @me = swapClass(this, "shadowman");
		me.setVelocity(this.getVelocity());
	}
	
	// Particles by TFlippy
	MakeParticle(this);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	if(Hitters::suddengib != customData)return 0;
	
	if(Hitters::suddengib == customData){
		if (getNet().isServer()){
			CBlob @me = swapClass(this, "shadowman");
			me.setVelocity(this.getVelocity());
		}
		return 0;
	
	}

	return damage; //no block, damage goes through
}

// Particles by TFlippy
void MakeParticle(CBlob@ this)
{
	if (!getNet().isClient()) return;
	
	if(this.getVelocity().y > 1.0f || this.getVelocity().y < -1.0f || this.getVelocity().x > 1.0f || this.getVelocity().x < -1.0f)
	ParticleAnimated("DeathPuff.png", this.getPosition() + getRandomVelocity(0, 6, 360), this.getVelocity()/3, XORRandom(360), 0.5f+(XORRandom(25)/100.0f), 3, 0.0f, false);
	
}

// Sounds by TFlippy
void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("WC3_Shadow_Off", 1.00f, 1.00f);
}