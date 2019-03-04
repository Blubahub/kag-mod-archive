#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	
	this.Tag("holy");

	this.set_s16("smitetimer",0);
	
	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_Vec2f("inventory offset", Vec2f(0.0f, -152.0f));
	
	this.addCommandID("makesword");
	this.addCommandID("makebow");
	this.addCommandID("makeorb");
	this.addCommandID("makegoods");
	this.addCommandID("makefish");
	
	this.addCommandID("makewell");
	
	this.Tag("spirit_view");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("GoldenBeingIcon.png", 10, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(this.getHealth() <= 0){
		if(getNet().isServer())server_CreateBlob("goldwell", this.getTeamNum(), this.getPosition());
	}
	
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	
	if (getNet().isServer())
	if(this.get_s16("smitetimer") > 15){
		if(this.isKeyPressed(key_action1))
		{
			CBlob @blob = server_CreateBlob("hugesmite", -1, this.getPosition());
			if (blob !is null)
			{
			
				Vec2f smiteVel = this.getAimPos()-this.getPosition();
				smiteVel.Normalize();
				blob.setVelocity(smiteVel*16);
			}
			this.set_s16("smitetimer",0);
		}
	} else this.set_s16("smitetimer",this.get_s16("smitetimer")+1);
	
	if (getNet().isServer())
	if(XORRandom(100) == 0)
	if(this.isKeyPressed(key_action2))
	{
		CBlob @blob = server_CreateBlob("goldendrop", -1, this.getPosition()+Vec2f(XORRandom(64)-32,0));
		if (blob !is null)
		{
			Vec2f smiteVel = Vec2f(0,1);
			smiteVel.Normalize();
			blob.setVelocity(smiteVel*1);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("projectile");
}