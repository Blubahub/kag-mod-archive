// Necro logic

#include "Hitters.as";
#include "Knocked.as";
#include "NecroCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "BombCommon.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	this.Tag("flesh");
	this.Tag("evil");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 4, Vec2f(16, 16));
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

	// slow down walking
	if (!(getKnocked(this) > 0))
	if(this.isKeyJustPressed(key_action1))
	{
		{
			RunnerMoveVars@ moveVars;
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor = 0.1f;
				moveVars.jumpFactor = 0.1f;
			}
		}
		
		bool canRaise = true;
		
		CBlob@[] blobsInRadius;	
		if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() == "darkrez")
				{
					canRaise = false;
				}
			}
		}
		
		if(canRaise){
			if(getNet().isServer())server_CreateBlob("darkrez",this.getTeamNum(),this.getPosition()+Vec2f(0,-16));
			this.set_u16("CooldownOne",getGameTime()+36);
		}
	}
	if (!(getKnocked(this) > 0))
	if(this.isKeyPressed(key_action2))
	{
		{
			RunnerMoveVars@ moveVars;
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor = 0.1f;
				moveVars.jumpFactor = 0.1f;
			}
		}
		
	}
}