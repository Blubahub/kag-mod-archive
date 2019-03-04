// Runescribe logic

#include "Hitters.as";
#include "Knocked.as";
#include "RuneWhispererCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "RuneScrollLogic.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_string("lastsaid","");
	this.set_string("secondlastsaid","");
	
	this.set_s16("power",100);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 11, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.get_s16("power") < 100)this.set_s16("power",this.get_s16("power")+1);
	
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	// activate/throw
	if(ismyplayer)
	{

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
	
	if(this.isKeyJustPressed(key_action1))
	{
		readRunes(this, this, this.get_string("lastsaid"));
	}
	
	if(this.isKeyJustPressed(key_action2))
	{
		readRunes(this, this, this.get_string("secondlastsaid"));
	}
	
}