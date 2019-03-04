// Shadowman logic

#include "Hitters.as";
#include "Knocked.as";
#include "ShadowmanCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "CopyTatoos.as";

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
	
	this.set_s16("temp_statis",5);
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
	CInventory@ inv1 = this.getInventory();
	if (inv1 !is null)
	{
		CBlob@ carried = inv1.getItem("mini_keg");
		if (carried !is null)
			this.server_PutOutInventory(carried);
		@carried = inv1.getItem("mega_drill");
		if (carried !is null)
			this.server_PutOutInventory(carried);

	}
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(this.get_s16("temp_statis") > 0)this.set_s16("temp_statis",this.get_s16("temp_statis")-1);
	
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	
	if(this.get_s16("temp_statis") <= 0)
	if(this.isKeyJustPressed(key_action2) || this.isInWater())if (getNet().isServer()){
		CBlob @newBlob = server_CreateBlob("shadowman", this.getTeamNum(), this.getPosition());

		if (newBlob !is null)
		{
			// make sack
			CInventory @inv = this.getInventory();

			if (inv !is null)
			{
				this.MoveInventoryTo(newBlob);
			}

			// plug the soul
			newBlob.server_SetPlayer(this.getPlayer());
			newBlob.setPosition(this.getPosition());

			// no extra immunity after class change
			if (this.exists("spawn immunity time"))
			{
				newBlob.set_u32("spawn immunity time", this.get_u32("spawn immunity time"));
				newBlob.Sync("spawn immunity time", true);
			}

			if (this.exists("knocked"))
			{
				newBlob.set_u8("knocked", this.get_u8("knocked"));
				newBlob.Sync("knocked", true);
			}
			newBlob.setVelocity(this.getVelocity());
			newBlob.server_SetHealth(this.getHealth());
			copyTatoos(this,newBlob);
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
			this.server_Die();
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getName() == "smite" || blob.getConfig() == "steel_block");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	if(Hitters::suddengib != customData)return 0;
	
	return damage; //no block, damage goes through
}