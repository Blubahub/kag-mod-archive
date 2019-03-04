#include "SoldierCommon.as"
#include "SoldierPlace.as"
#include "Sparks.as"
#include "GameColours.as"
#include "SoldierRevive.as"

const int SUPPLIES = 3;
const f32 HEAL_RADIUS = 16.0f;

void onInit(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);
	data.walkSpeedModifier = 1.2f;

	InitPlaceOrDelete(this, "supply", SUPPLIES);
}

void onTick(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);

	bool matchrunning = getRules().isMatchRunning();

	//get healed by others who're alive
	if (data.dead && matchrunning && data.healTime < 1 && getNet().isServer())
	{
		healSelfIfBlobsNearby(this);
	}

	if (data.dead || data.stunned || !matchrunning)
	{
		data.shield = false;
		return;
	}

	// shield

	if (data.fire && data.stunTime <= 0)
	{
		data.shield = true;
		data.allowCrouch = false;
		this.Tag("collide with nades");
	}
	else
	{
		data.shield = false;
		data.allowCrouch = true;
		this.Untag("collide with nades");
	}

	if (this.isKeyJustPressed(key_action2))
	{
		CBlob@ supply = PlaceOrDelete(this, data, "supply", this.getTeamNum()) ;
		if (supply !is null)
		{
			this.IgnoreCollisionWhileOverlapped(supply);
			supply.IgnoreCollisionWhileOverlapped(this);
			this.getSprite().PlaySound("GiveOut");
		}
	}

	// heal

	if (getNet().isServer())
	{
		healBlobsNearby(this);
	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (cmd == Soldier::Commands::MEDIC_SUPPLY)
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		if (blob !is null)
		{
			Soldier::Data@ data = Soldier::getData(blob);
			data.healTime = 1;
			this.getSprite().PlayRandomSound("MedkitHeal", 1.0f, data.pitch);
			this.getSprite().PlaySound("/Heal");
		}
	}
}

void healBlobsNearby(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (!this.getMap().getBlobsInRadius(this.getPosition(), HEAL_RADIUS, @blobsInRadius))
		return;

	const u8 team = this.getTeamNum();
	for (uint i = 0; i < blobsInRadius.length; i++)
	{
		CBlob @b = blobsInRadius[i];
		if (b.getTeamNum() == team && b.getHealth() < b.getInitialHealth() && b.getName() == "soldier")
		{
			Soldier::Data@ data = Soldier::getData(b);
			if (data.healTime < 1 && (data.onGround || data.onLadder))
			{
				CBitStream params;
				params.write_netid(b.getNetworkID());
				this.SendCommand(Soldier::Commands::MEDIC_SUPPLY, params);
			}
		}
	}
}

void healSelfIfBlobsNearby(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (!this.getMap().getBlobsInRadius(this.getPosition(), HEAL_RADIUS, @blobsInRadius))
		return;

	Soldier::Data@ mydata = Soldier::getData(this);
	if (!mydata.onGround && !mydata.onLadder)
		return;

	const u8 team = this.getTeamNum();
	for (uint i = 0; i < blobsInRadius.length; i++)
	{
		CBlob @b = blobsInRadius[i];
		if (b !is this && b.getTeamNum() == team && b.getName() == "soldier")
		{
			Soldier::Data@ data = Soldier::getData(b);
			if(data.dead)
				continue;

			CBitStream params;
			params.write_netid(this.getNetworkID());
			this.SendCommand(Soldier::Commands::MEDIC_SUPPLY, params);

			break;
		}
	}
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	Soldier::Data@ data = Soldier::getData(this);
	if (data.shield)
	{
		if ((velocity.x < 0.0f && !data.facingLeft) || (velocity.x > 0.0f && data.facingLeft))
		{
			this.getSprite().PlayRandomSound("ShieldImpact");
			Particles::Sparks(worldPoint, 4, velocity.getLength() * 0.4f, SColor(Colours::YELLOW));

			// push back
			//printf("velocity " + velocity.x + " da " + damage);
			data.vel += velocity;
			data.vel.y = -Maths::Abs(data.vel.y) - 0.75f * damage;
			this.setVelocity(data.vel);

			// stun
			if (damage > 1.0f)
			{
				data.stunTime = 120;
			}

			damage = 0.0f;
		}
	}
	return damage;
}
