// Bomb logic

#include "Hitters.as";
#include "BombCommon.as";
#include "ShieldCommon.as";

const s32 bomb_fuse = 120;

void onInit(CBlob@ this)
{
	this.set_u16("explosive_parent", 0);
	this.getShape().getConsts().net_threshold_multiplier = 2.0f;
	SetupBomb(this, bomb_fuse, 64.0f, 3.0f, 24.0f, 0.4f, true);
	//
	this.Tag("activated"); // make it lit already and throwable
}

//start ugly bomb logic :)

void set_delay(CBlob@ this, string field, s32 delay)
{
	this.set_s32(field, getGameTime() + delay);
}

void onTick(CBlob@ this)
{
	//set parent from attached blob

	if (getNet().isServer())
	{
		CBlob@ parent = this.getAttachments().getAttachedBlob("PICKUP", 0);

		if (parent !is null)
		{
			u16 oldParentID = this.get_u16("explosive_parent");
			u16 newParentID = parent.getNetworkID();

			if (oldParentID != newParentID)
			{
				this.set_u16("explosive_parent", newParentID);
				this.SetDamageOwnerPlayer(parent.getPlayer());
				//this.Sync("explosive_parent", true); we dont need this synced
			}
		}
	}

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this is hitterBlob)
	{
		this.set_s32("bomb_timer", 0);
	}

	if (isExplosionHitter(customData))
	{
		return damage; //chain explosion
	}

	return 0.0f;
}

void onDie(CBlob@ this)
{
	explodeBedrock(this, this.getPosition());
	this.getSprite().SetEmitSoundPaused(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		const u8 hitter = this.get_u8("custom_hitter");

		//all water bombs collide with enemies
		if (hitter == Hitters::water)
			return blob.getTeamNum() != this.getTeamNum();

		//collide with shielded enemies
		return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
	}

	return true;
}



void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	const f32 vellen = this.getOldVelocity().Length();
	const u8 hitter = this.get_u8("custom_hitter");
	if (vellen > 1.7f)
	{
		Sound::Play(!isExplosionHitter(hitter) ? "/WaterBubble" :
		            "/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f));
	}

	if (!isExplosionHitter(hitter))
	{
		Boom(this);
		if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
		{
			this.Tag("_hit_water");
			Vec2f pos = this.getPosition();
			blob.Tag("force_knock");
		}
	}
}

void explodeBedrock(CBlob@ this, Vec2f pos)
{
	if (this.getConfig() == "bomb")
	{
		CMap@ map = getMap();
		map.server_DestroyTile(pos + Vec2f(0, -8), 1000.0f);
		map.server_DestroyTile(pos + Vec2f(0, 8), 1000.0f);
		map.server_DestroyTile(pos + Vec2f(-8, 0), 1000.0f);
		map.server_DestroyTile(pos + Vec2f(8, 0), 1000.0f);
	}
}


