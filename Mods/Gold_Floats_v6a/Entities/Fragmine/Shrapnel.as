// Mine.as

#include "Hitters.as";
#include "Explosion.as";

const string MINE_STATE = "mine_state";
const string MINE_TIMER = "mine_timer";
const string MINE_PRIMING = "mine_priming";
const string MINE_PRIMED = "mine_primed";

enum State
{
	NONE = 0,
	PRIMED
};

void onInit(CBlob@ this)
{
	this.getShape().getVars().waterDragScale = 16.0f;

	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 1.00f);
	this.set_f32("map_damage_radius", 12.0f);
	this.set_f32("map_damage_ratio", 1.5f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "Bomb.ogg");
	this.set_u8("custom_hitter", Hitters::mine);

	this.set_u8("prime_timer", 8 + XORRandom(16));
	
	this.getSprite().SetFrameIndex(XORRandom(4));
	
	this.Tag("ignore fall");
	this.Tag("shrapnel");

	this.Tag(MINE_PRIMING);

	this.set_u8(MINE_STATE, NONE);
	this.set_u8(MINE_TIMER, 0);
	
	this.addCommandID(MINE_PRIMED);

	this.getShape().getConsts().collideWhenAttached = true;

	this.getCurrentScript().tickIfTag = MINE_PRIMING;
	
	this.getShape().SetGravityScale(0.7f);
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	{
		u8 timer = this.get_u8(MINE_TIMER);
		timer++;
		this.set_u8(MINE_TIMER, timer);

		if(timer >= this.get_u8("prime_timer"))
		{
			this.Untag(MINE_PRIMING);
			this.SendCommand(this.getCommandID(MINE_PRIMED));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID(MINE_PRIMED))
	{
		this.set_u8(MINE_STATE, PRIMED);
		this.getShape().checkCollisionsAgain = true;
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(this.get_u8(MINE_STATE) == PRIMED)
	{
		this.Tag("exploding");
		this.Sync("exploding", true);

		this.server_SetHealth(-1.0f);
		this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	if(getNet().isServer() && this.hasTag("exploding"))
	{
		const Vec2f POSITION = this.getPosition();

		CBlob@[] blobs;
		getMap().getBlobsInRadius(POSITION, this.getRadius() + 4, @blobs);
		for(u16 i = 0; i < blobs.length; i++)
		{
			CBlob@ target = blobs[i];
			if(target.hasTag("flesh"))
			{
				this.server_Hit(target, POSITION, Vec2f_zero, 0.9f, Hitters::mine_special, true);
			}
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return customData == Hitters::builder? this.getInitialHealth() / 2 : damage;
}
