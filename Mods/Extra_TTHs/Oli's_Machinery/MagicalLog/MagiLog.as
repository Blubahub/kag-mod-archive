#include "VehicleCommon.as"
#include "Knocked.as";
#include "MakeCrate.as";
#include "MiniIconsInc.as";

// Catapult logic

const u8 baseline_charge = 15;

const u8 charge_contrib = 35;

const u8 cooldown_time = 45;
const u8 startStone = 100;

void onInit(CBlob@ this)
{
	this.set_f32("hit dmg modifier", 2.0f);
	VehicleInfo@ v;
	if(getNet().isServer())
	{
		this.server_setTeamNum(-1);
	}
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	this.getShape().SetOffset(Vec2f(0, 6));
}
void onTick(CBlob@ this)
{
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ blob = ap.getOccupied();
			if ( blob !is null)
			{
				if(ap.isKeyJustPressed(key_up))
				{
					if(getNet().isServer())
					{
						this.server_DetachFrom(blob);
					}
				}
				else if (ap.isKeyPressed(key_action1))
				{
					Vec2f force = ap.getAimPos() - blob.getPosition();
					force.Normalize();
					this.AddForce(force*17);
				}
			}
		}
		const float absY = Maths::Abs(this.getVelocity().x);
		const float absX = Maths::Abs(this.getVelocity().y);
		if((10.5 > absY && absY > 10) || (10.5 > absX && absX > 10))
		{
			this.getSprite().PlaySound("/Respawn");
		}
	}
	this.AddForce(Vec2f(0, -46)); //counter gravity
	
	
	//Face where u goin' boi
	if (this.getVelocity().x > 0.5)
	{
		this.SetFacingLeft(false);
	}
	else if(this.getVelocity().x < -0.5)
	{
		this.SetFacingLeft(true);
	}
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue)
{
	return false;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("fire"))
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		v.firing = false;
		v.charge = 0;
	}
	else if (cmd == this.getCommandID("fire blob"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		Vehicle_onFire(this, v, blob, charge);
	}
}

Random _r(0xca7a);

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge)
{
	f32 charge = baseline_charge + (float(_charge) / float(v.max_charge_time)) * charge_contrib;

	if (bullet !is null)
	{
		f32 angle = this.getAngleDegrees();
		f32 sign = this.isFacingLeft() ? -1.0f : 1.0f;

		Vec2f vel = Vec2f(sign, -0.5f) * charge * 0.3f;

		vel += (Vec2f((_r.NextFloat() - 0.5f) * 128, (_r.NextFloat() - 0.5f) * 128) * 0.01f);
		vel.RotateBy(angle);

		bullet.setVelocity(vel);

		if (isKnockable(bullet))
		{
			SetKnocked(bullet, 30);
		}
	}

	// we override the default time because we want to base it on charge
	int delay = 30 + (charge / (250 / 30));
	v.fire_delay = delay;

	v.last_charge = _charge;
	v.charge = 0;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	CAttachment@ attachments = this.getAttachments();
	CBlob@ att = attachments.getAttachedBlob("DRIVER");
	if(att !is null && blob.getTeamNum() != att.getTeamNum())
	{
		return true;
	}
	else return false;
	//It must collide with nothing when it is not attached, and must not collide with team mates when attached.
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getSprite().PlaySound("/ShipmentHorn");
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onAttach(this, v, attached, attachedPoint);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onDetach(this, v, detached, attachedPoint);
}

// Blame Fuzzle.
bool isOverlapping(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}