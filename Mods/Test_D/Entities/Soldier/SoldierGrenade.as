#include "SoldierCommon.as"
#include "SoldierCrosshair.as"
#include "Shells.as"
#include "HoverMessage.as"

//#include "AssaultActions.as"


namespace Soldier
{
	void ThrowGrenade(CBlob@ this, Data@ data)
	{
		Vec2f grenadeVel = data.crosshairOffset * 0.1f;
		f32 len = grenadeVel.Normalize();
		grenadeVel *= Maths::Min(len, Soldier::maxThrow);
		Grenade(this, data, grenadeVel);
		data.grenadeStep = 0.0f;
	}

	void Grenade(CBlob@ this, Data@ data, Vec2f vel)
	{
		bool mine = (this.isBot() && getNet().isServer()) || this.isMyPlayer();
		if (!mine) return;

		CBitStream params;
		params.write_netid(this.getNetworkID());
		params.write_Vec2f(this.getPosition() + Vec2f(data.direction * data.radius * 0.5f, -data.radius));
		params.write_Vec2f(Vec2f(vel.x, vel.y));
		params.write_f32(Soldier::getGrenadeTicksLeft(data) / getTicksASecond());
		params.write_u8( data.grenadeType );
		this.SendCommand(Soldier::Commands::GRENADE, params);
	}

	f32 getGrenadeTicksLeft(Data@ this)
	{
		return this.grenadeTimeout - this.grenadeStep;
	}
}

void onInit(CBlob@ this)
{

}

void onTick(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (data.dead || data.stunned || getRules().isWarmup())
		return;

	if (!data.crosshair && this.isKeyJustPressed(key_action2))
	{
		if (data.grenades <= 0)
		{
			if (data.local)
			{
				data.sprite.PlaySound("NoAmmo");
				AddMessageAbove(this, data.grenadeType == Soldier::FLASHBANG ? "no flashbangs" : "no grenades");
			}
		}
		else
		{
			Soldier::StartCrosshair(this, data, true);
			data.sprite.PlaySound("GrenadePull");
			data.grenadeStep = 0.0f;
		}
	}
	else if (data.crosshair)
	{
		data.grenadeStep += 1.0f;
		if (data.fire || (data.jump && !data.up) || Soldier::getGrenadeTicksLeft(data) <= 0)
		{
			data.sprite.PlaySound("GrenadePut");
			Soldier::EndCrosshair(this, data);
		}
		else if (this.isKeyJustPressed(key_action2) || (data.crosshairTime >= data.crosshairMinTime && this.isKeyJustReleased(key_action2)))
		{
			if (data.local)
			{
				Soldier::ThrowGrenade(this, data);
			}
			Soldier::EndCrosshair(this, data);
		}
	}

	Soldier::TickCrosshair(this, data);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (cmd == Soldier::Commands::GRENADE && data.grenades > 0)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		Vec2f pos = params.read_Vec2f();
		Vec2f velocity = params.read_Vec2f();
		const f32 time = params.read_f32();
		const u8 grenadeType = params.read_u8();

		if (getNet().isServer())
		{
			pos = moveOutOfMap(pos, velocity.x > 0.0f ? 1 : -1);
			CBlob@ grenade = server_CreateBlob("grenade", this.getTeamNum(), pos);
			if (grenade !is null)
			{
				if (caller !is null){
					grenade.SetDamageOwnerPlayer(caller.getPlayer());
				}
				grenade.setVelocity(velocity);
				grenade.server_SetTimeToDie(Maths::Max(time, 0.1f));
				grenade.set_u8("grenade type", grenadeType);
			}
		}

		if (!getRules().get_bool("infinite grenades") && !sv_test)
		{
			data.grenades--;
		}

		// client-effects
		CSprite@ sprite = this.getSprite();
		sprite.PlaySound(velocity.Length() > 5.0f ? "GrenadeThrow" : "GrenadeShortThrow");
		this.SetFacingLeft(velocity.x < 0.0f);
		Particles::Shell(pos, Vec2f(data.direction * -1, -1), SColor(255, 142, 142, 142));   // pin
	}
	else if (cmd == Soldier::Commands::DIE)
	{
		if (data.local && data.grenadeStep > 0.0f)
		{
			Soldier::ThrowGrenade(this, data);
		}
	}
}

Vec2f moveOutOfMap(Vec2f pos, int direction)
{
	CMap@ map = getMap();
	if (map.isTileSolid(map.getTile(pos)))
	{
		pos.x += direction * -8;
	}
	return pos;
}