// Mindman logic

#include "Hitters.as";
#include "Knocked.as";
#include "MindmanCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "EnergyCommon.as";

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
	
	this.set_u16("shoot_timestamp",getGameTime());
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 9, Vec2f(16, 16));
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

	if(getEnergy(this) > 0)
	if(this.isKeyJustPressed(key_action1)){
		if(getGameTime() > this.get_u16("shoot_timestamp")+10){
			if (getNet().isServer()){
				CBlob @blob = server_CreateBlob("pulse", this.getTeamNum(), this.getPosition());
				Vec2f arrowVel = ((this.getPosition() + Vec2f(0.0f, -4.0f)) - (this.getAimPos() + Vec2f(0.0f, -4.0f)));
				arrowVel.Normalize();
				arrowVel *= -6;
				blob.setVelocity(arrowVel);
				blob.set_Vec2f("goal",this.getAimPos());
				this.set_u16("shoot_timestamp",getGameTime());
				addEnergy(this, -1);
			}
		}
	}
	
	/*
	CBlob@[] blobsInRadius;
	if(this.isKeyPressed(key_action1))
	if (this.getMap().getBlobsInRadius(this.getAimPos(), 16.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null){
				if(b !is this){
					Vec2f dir = this.getAimPos()-b.getPosition();
					dir.Normalize();
					b.setVelocity(dir*0.75+b.getVelocity());
				}
			}
		}
	}*/
	
	if(this.isKeyPressed(key_action2) && !this.hasTag("mindfail") && getEnergy(this) > 0)this.Tag("flying");
	else this.Untag("flying");
}