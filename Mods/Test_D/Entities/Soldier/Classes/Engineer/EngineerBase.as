#include "SoldierCommon.as"
#include "SoldierPlace.as"
#include "SoldierCrosshair.as"
#include "HoverMessage.as"

const int PATRIOTS = 3;
const int BOMBS = 3;
const float SHOOT_VEL = 0.14f;
const float THROW_VEL = 1.5f;
const float SHOOT_OFFSET = -8.0f;

enum EngineerState
{
	ES_IDLE = 0,
	ES_AIMING,
	ES_FIRED
};

void onInit(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);
	data.walkSpeedModifier = 1.0f;

	data.grenades = data.initialGrenades = PATRIOTS;
	data.defaultCrosshairDistance = 40.0f;
	data.crosshairMinTime = 5;
	data.crosshairMaxDist = 80.0f;
	data.crosshairMinTime = 5;

	data.fireRate = 30;
	data.fireTime = 0;

	data.bombs = data.initialBombs = BOMBS;
}

void onTick(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (data.dead || data.stunned || getRules().isWarmup())
	{
		data.engineerState = ES_IDLE; //prevent locking up when die while firing
		//data.missileId = 0;
		data.lockCrouch = 0;
		return;
	}

	// missile
	if (!data.crosshair && !data.fire2 && this.isKeyJustPressed(key_action1) &&
	        data.fireTime + data.fireRate < data.gametime)
	{
		if (data.grenades > 0)
		{
			Soldier::StartCrosshair(this, data, true, 0.0f);
			data.engineerState = ES_AIMING;
		}
		else if (data.local)
		{
			data.sprite.PlaySound("NoAmmo");
			AddMessage(this, "no missiles");
		}
	}
	else if (data.crosshair)
	{
		if (this.isKeyPressed(key_action2))
		{
			//data.lockCrouch = 0;
			data.sprite.PlaySound("GrenadePut");
			Soldier::EndCrosshair(this, data);
		}
		else if (data.engineerState == ES_AIMING)
		{
			if (this.isKeyJustPressed(key_action1) || (data.crosshairTime >= data.crosshairMinTime && this.isKeyJustReleased(key_action1)))
			{
				if (data.local)
				{
					CBitStream params;
					params.write_Vec2f(data.pos);
					params.write_Vec2f(data.crosshairOffset);
					this.SendCommand(Soldier::Commands::ENGIE_SHOOT, params);
				}
				data.engineerState = ES_FIRED;
				Soldier::EndCrosshair(this, data);

				data.fireTime = data.gametime;
			}
		}
	}
	else // remote bomb
	{
		if (!data.crosshair && !data.fire && this.isKeyJustPressed(key_action2))
		{
			if (data.local)
			{
				CBitStream params;
				params.write_Vec2f(data.pos);
				params.write_Vec2f(data.vel);
				params.write_bool(data.facingLeft);
				this.SendCommand(Soldier::Commands::ENGIE_BOMB, params);
			}
		}
	}

	Soldier::TickCrosshair(this, data);
}

CBlob@ ShootPatriot(CBlob@ this, Soldier::Data@ data)
{
	if (data.grenades <= 0)
		return null;
		
	CMap@ map = getMap();
	Vec2f pos = data.pos + Vec2f(0.0f, SHOOT_OFFSET);
	Vec2f vec = data.crosshairOffset;
	f32 len = vec.Normalize();

	if (!Sound::isTooFar(data.pos))
	{
		ShakeScreen(vec * -20.0f, 30, data.pos);
	}
	data.sprite.PlaySound("PatriotLaunch");

	if (!getRules().get_bool("infinite grenades") && !sv_test)
	{
		data.grenades--;
	}

	if (!getNet().isServer())
	{
		return null;
	}

	CBlob @blob = server_CreateBlob("patriot", this.getTeamNum(), pos);
	if (blob !is null)
	{
		blob.setVelocity(vec * len * SHOOT_VEL);
		blob.set_netid("owner", this.getNetworkID());
		blob.SetDamageOwnerPlayer(this.getPlayer());
		blob.SetFacingLeft(this.isFacingLeft());
	}
	return blob;
}

CBlob@ ThrowBomb(CBlob@ this, Soldier::Data@ data)
{
	if (data.missileId > 0) // detonate
	{
		if (getNet().isServer())
		{
			CBlob@ blob = getBlobByNetworkID(data.missileId);
			if (blob !is null)
			{
				if (blob.hasTag("activated"))
				{
					data.missileId = 0;
					blob.server_Die();
				}
				return null;
			}
			else{
				data.sprite.PlaySound("NoAmmo");
			}
		}
	}
	else 
	{
		if (data.bombs <= 0)
		{
			data.sprite.PlaySound("NoAmmo");
			AddMessageAbove(this, "no bombs");
			return null;
		}

		Sound::Play("CrateThrow", data.pos);
		data.bombs--;

		if (getNet().isServer())
		{
			Vec2f pos = data.pos + Vec2f(data.facingLeft ? -8.0f : 8.0f, SHOOT_OFFSET);
			CBlob @blob = server_CreateBlob("remotebomb", this.getTeamNum(), pos);
			if (blob !is null)
			{
				blob.setVelocity(data.vel * THROW_VEL);
				blob.set_netid("owner", this.getNetworkID());
				blob.SetDamageOwnerPlayer(this.getPlayer());
				blob.SetFacingLeft(data.facingLeft);
				data.missileId = blob.getNetworkID();

				CBitStream params;
				params.write_netid(data.missileId);
				this.SendCommand(Soldier::Commands::ENGIE_CONTROL, params);

				return blob;
			}
		}
	}

	data.missileId = 0;

	return null;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == Soldier::Commands::ENGIE_SHOOT)
	{
		Soldier::Data@ data = Soldier::getData(this);
		data.pos = params.read_Vec2f();
		data.crosshairOffset = params.read_Vec2f();
		ShootPatriot(this, data);
	}
	else if (cmd == Soldier::Commands::ENGIE_BOMB)
	{
		Soldier::Data@ data = Soldier::getData(this);
		data.pos = params.read_Vec2f();
		data.vel = params.read_Vec2f();
		data.facingLeft = params.read_bool();
		ThrowBomb(this, data);
	}
	else if (cmd == Soldier::Commands::ENGIE_CONTROL)
	{
		Soldier::Data@ data = Soldier::getData(this);
		data.missileId = params.read_netid();
	}
}

// SPRITE

void onRender(CSprite@ sprite)
{

}
