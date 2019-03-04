// Priest logic

#include "Hitters.as";
#include "Knocked.as";
#include "PriestCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";

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
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 7, Vec2f(16, 16));
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
	if (getNet().isServer())
	if(this.get_s16("timer") > 15){
		if(this.isKeyPressed(key_action1))
		{
			CBlob @blob = server_CreateBlob("smite", -1, this.getPosition());
			if (blob !is null)
			{
			
				Vec2f smiteVel = this.getAimPos()-this.getPosition();
				smiteVel.Normalize();
				blob.setVelocity(smiteVel*4);
			}
		}
		this.set_s16("timer",0);
	} else this.set_s16("timer",this.get_s16("timer")+1);
	
	if(this.get_s16("timer") > 15){
		if (!(getKnocked(this) > 0))
		if(this.isKeyPressed(key_action2) && !this.isKeyPressed(key_action1))
		{
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 48.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.hasTag("flesh"))
					{
						if(!b.hasTag("undead")){if(b.getHealth() < b.getInitialHealth())b.server_Heal(0.5f);}
						else b.server_Hit(b, b.getPosition(), Vec2f(0.0f,0.0f), 0.5f, Hitters::suddengib, false);
						this.set_s16("timer",0);
					}
				}
			}
		}
	} else this.set_s16("timer",this.get_s16("timer")+1);
}