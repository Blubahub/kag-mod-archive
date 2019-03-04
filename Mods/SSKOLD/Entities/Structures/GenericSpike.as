// GenericSpike.as

#include "Hitters.as";
#include "SSKStatusCommon.as"
#include "SSKMovesetCommon.as"

namespace Spike
{
	enum pointing
	{
		pointing_up = 0,
		pointing_right,
		pointing_down,
		pointing_left
	};

	enum state
	{
		hidden = 0,
		stabbing,
		falling
	};
}


// Todo: collision normal
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(!getNet().isServer() || this.get_u8("state") == Spike::hidden || blob is null || !blob.hasTag("flesh") || blob.hasTag("invincible")) return;

	Vec2f velocity = blob.getOldVelocity();
	velocity.Normalize();

	const u16 angle_point = this.getAngleDegrees() / 90;
	const u16 angle_collision = velocity.Angle();

	bool pierced = false;

	switch(angle_point)
	{
		case Spike::pointing_up:
			pierced = angle_collision <= 315 && angle_collision >= 225;
			break;

		case Spike::pointing_right:
			pierced = angle_collision <= 225 && angle_collision >= 135;
			break;

		case Spike::pointing_down:
			pierced = angle_collision <= 135 && angle_collision >= 45;
			break;

		case Spike::pointing_left:
			pierced = angle_collision <= 45 || angle_collision >= 315;
			break;
	}

	if(!pierced) return;

	bool applyDamage = true;
	SSKStatusVars@ statusVars;
	if (blob.get("statusVars", @statusVars))
	{
		if (statusVars.isHitstunned)
			applyDamage = false;
	}
	if (applyDamage)
	{
		Vec2f hitVec = blob.getVelocity() * -1;
		// random chance to shoot player in random direction
		if (XORRandom(5) == 0)
		{
			hitVec = getRandomVelocity(0, hitVec.getLength(), 360);
		}

		CustomHitData customHitData(4, 0, 0.1f);
		server_customHit(this, blob, blob.getPosition(), hitVec, 2, Hitters::spikes, true, customHitData);
		print("GenericSpike");
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if(this.exists("bloody")) return;

	this.Tag("bloody");

	CSpriteLayer@ layer = this.getSprite().getSpriteLayer("blood");
	if(layer is null) return;

	layer.SetVisible(true);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}