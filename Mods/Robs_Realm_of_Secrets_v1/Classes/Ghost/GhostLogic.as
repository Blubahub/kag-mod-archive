//Ghost logic

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
	
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("player");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	//this.server_SetTimeToDie(10);
	
	this.set_s16("corruption",0);
	
	this.Tag("ghost");
	this.Tag("ignore_flags");
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
	
	if(this.getPosition().y > getMap().tilemapheight*8-32)this.AddForce(Vec2f(0,-200));
	
	if (this.isKeyPressed(key_action3)){
		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob("ghost_shard", -1, this.getPosition());
			blob.server_SetPlayer(this.getPlayer());
		
			this.Tag("switch class");
			this.server_SetPlayer(null);
			this.server_Die();
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}


