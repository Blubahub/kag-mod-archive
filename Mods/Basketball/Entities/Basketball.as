#include "/Entities/Common/Attacks/Hitters.as";
#include "/Entities/Common/Attacks/LimitedAttacks.as";

const int pierce_amount = 8;

const f32 hit_amount_ground = 0.5f;
const f32 hit_amount_air = 1.0f;
const f32 hit_amount_air_fast = 3.0f;
const f32 hit_amount_cata = 10.0f;
const u32 BASKETBALL_MAX_HOLD_TIME = 60;
const float BASKETBALL_MAX_VELOCITY = 8.0;
const float BASKETBALL_MAX_PICKUP_DIST = 30.0f;

void onInit(CBlob @ this)
{
    this.getShape().SetRotationsAllowed(true);
    this.getShape().getConsts().collideWhenAttached = true;
	this.set_u8("launch team", 255);
	this.server_setTeamNum(-1);

	this.getCurrentScript().tickFrequency = 1;
    this.Tag("special"); // for pickup prio

    this.addCommandID("gib");
}

void onTick(CBlob@ this)
{
    // Don't let people hold on too long
    /*
    if (this.isAttached()) {
        u32 attach_time = this.get_u32("attach_time");
        u32 time_held = getGameTime() - attach_time;
        if (time_held > BASKETBALL_MAX_HOLD_TIME) {
            this.server_DetachFromAll();
        }
    }
    */

    // Limit velocity
    Vec2f vel = this.getVelocity();

	if (vel.x > BASKETBALL_MAX_VELOCITY)
	{
		vel.x = BASKETBALL_MAX_VELOCITY;
	}

	if (vel.x < -BASKETBALL_MAX_VELOCITY)
	{
		vel.x = -BASKETBALL_MAX_VELOCITY;
	}

    /*
	if (this.isOnGround() || this.isOnCeiling())
	{
		vel.x *= 0.8;
	}
    */

	if (vel.y > BASKETBALL_MAX_VELOCITY)
	{
		vel.y = BASKETBALL_MAX_VELOCITY;
	}

	if (vel.y < -BASKETBALL_MAX_VELOCITY)
	{
		vel.y = -BASKETBALL_MAX_VELOCITY;
	}

	this.setVelocity(vel);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
    if (detached !is null) {
        u8 team = detached.getTeamNum();
        this.set_u8("launch team", team);
        printf("Basketball launch team: " + team);

        CPlayer@ player = detached.getPlayer();
        if (player !is null) {
            this.SetDamageOwnerPlayer(player);
            printf("Basketball thrower: " + player.getUsername());
        }
        else {
            printf("Basketball ERROR: Detached has no player!");
        }
    }
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if(attached.getPlayer() !is null)
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
        this.set_u32("attach_time", getGameTime());
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid && blob !is null)
	{
		Vec2f hitvel = this.getOldVelocity();
		Vec2f hitvec = point1 - this.getPosition();
		f32 coef = hitvec * hitvel;

		if (coef < 0.706f) // check we were flying at it
		{
			return;
		}

		f32 vellen = hitvel.Length();

		//fast enough
		if (vellen < 1.0f)
		{
			return;
		}

		u8 tteam = this.get_u8("launch team");
		CPlayer@ damageowner = this.getDamageOwnerPlayer();

		//not teamkilling (except self)
		if (damageowner is null || damageowner !is blob.getPlayer())
		{
			if (
			    (blob.getName() != this.getName() &&
			     (blob.getTeamNum() == this.getTeamNum() || blob.getTeamNum() == tteam))
			)
			{
				return;
			}
		}

		//not hitting static stuff
		if (blob.getShape() !is null && blob.getShape().isStatic())
		{
			return;
		}

		//hitting less or similar mass
		if (this.getMass() < blob.getMass() - 1.0f)
		{
			return;
		}

		//get the dmg required
		hitvel.Normalize();
		f32 dmg = vellen > 8.0f ? 5.0f : (vellen > 4.0f ? 1.5f : 0.5f);

		//bounce off if not gibbed
		if(dmg < 4.0f)
		{
			this.setVelocity(blob.getOldVelocity() + hitvec * -Maths::Min(dmg * 0.33f, 1.0f));
		}

		//hurt
		this.server_Hit(blob, point1, hitvel, dmg, Hitters::boulder, true);

		return;

	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (getNet().isServer() &&
	        !isExplosionHitter(customData) &&
	        (hitterBlob is null || hitterBlob.getTeamNum() != this.getTeamNum()))
	{
        this.server_DetachFromAll();
        /*
		u16 id = this.get_u16("_keg_carrier_id");
		if (id != 0xffff)
		{
			CBlob@ carrier = getBlobByNetworkID(id);
			if (carrier !is null)
			{
				this.server_DetachFrom(carrier);
			}
		}
        */
    }

	return 0;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params) {
    if (cmd == this.getCommandID("gib")) {
        this.getSprite().Gib();
        this.server_Die();
    }
}

bool canBePickedUp(CBlob@ this, CBlob@ other) {
	return this.getDistanceTo(other) < BASKETBALL_MAX_PICKUP_DIST;
}
