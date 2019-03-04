#include "SoldierCommon.as"
#include "SoldierCrosshair.as"
#include "SoldierFireCommon.as"
#include "Shell.as"
#include "HoverMessage.as"

const f32 SCOPE_SOUND_DISTANCE = 80.0f;
const f32 ZOOM_SPEED = 0.1f;

void onInit(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);
	data.walkSpeedModifier = 0.8f;

	data.fireRate = 30;
	data.fireSpread = 0.0f;
	data.fireMuzzleVelocity = 100.0f;
	data.bulletLifeSecs = 0.1f;
	data.bulletDamage = 3.0f;
	data.defaultCrosshairDistance = 40.0f;
	data.grenades = data.initialGrenades = 0;
	data.ammo = data.initialAmmo = 10;
	data.crosshairMinTime = 5;
	data.crosshairMaxDist = 250.0f;
}

void onTick(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (data.dead || data.stunned || getRules().isWarmup())
		return;

	// cycle camo

	if (data.local && this.isKeyJustPressed(key_action2) && !data.fire && !data.crosshair)
	{
		CBitStream params;

		u8 seed = 0;
		if (data.camoMode == 0)
		{
			seed = getGameTime();
			if (seed == 0)
				seed = 1;
		}
		params.write_u8(seed);

		this.SendCommand(Soldier::Commands::CHANGE_CAMO, params);
	}

	// sniper scope

	CCamera@ camera = getCamera();
	bool canZoom = false && data.local;
	data.allowCrouch = true;

	if (!data.fire2 && !data.crosshair &&
	        (this.isKeyJustPressed(key_action1) && Soldier::canShoot(data) ||
	         this.isKeyPressed(key_action1) && data.fireTime + data.fireRate == data.gametime)
	   )
	{
		if (data.ammo == 0)
		{
			if (data.local)
			{
				data.sprite.PlaySound("DryShot");
				AddMessageAbove(this, "no ammo");
			}
		}
		else if (data.ammo > 0)
		{
			Soldier::StartCrosshair(this, data);
			data.sprite.PlaySound("ScopeOn");
			data.lastSoundCrosshairOffset = data.crosshairOffset;
		}
	}
	else if (data.crosshair)
	{
		data.allowCrouch = false;
		if ((data.lastSoundCrosshairOffset - data.crosshairOffset).getLength() > SCOPE_SOUND_DISTANCE)
		{
			data.lastSoundCrosshairOffset = data.crosshairOffset;
			data.sprite.PlaySound("ScopeFocus");
		}

		if (data.fire2 || (data.jump && !data.up))
		{
			data.sprite.PlaySound("ScopeOff");
			Soldier::EndCrosshair(this, data);
		}
		else if (Soldier::canShoot(data) && (this.isKeyJustPressed(key_action1)
		                                     || (data.crosshairTime >= data.crosshairMinTime && this.isKeyJustReleased(key_action1))))
		{
			if (data.crosshairTime < data.crosshairMinTime / 2)
			{
				data.lockCrouch = 0;
				data.sprite.PlaySound("ScopeOff");
				Soldier::EndCrosshair(this, data);
			}
			else
			{
				if (data.crosshairTime >= data.crosshairMinTime / 2)
				{
					if (data.local)
					{
						Soldier::Fire(this, data, data.crosshairOffset);
					}
					Soldier::EndCrosshair(this, data);
				}
			}
		}

		if (canZoom)
		{
			if (camera.targetDistance < 2.0f)
				camera.targetDistance += ZOOM_SPEED;
		}
	}
	else
	{
		if (canZoom)
		{
			if (camera.targetDistance > 1.5f)
				camera.targetDistance -= ZOOM_SPEED;
		}
	}

	Soldier::TickCrosshair(this, data);

	// rechamber sound

	if (data.fireTime + data.fireRate / 2 == data.gametime)
	{
		data.sprite.PlaySound("Rechamber");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (cmd == Soldier::Commands::FIRE && getNet().isClient() && getCamera() !is null)
	{
		// client-effects
		CSprite@ sprite = this.getSprite();
		data.shotTime = data.gametime;
		Vec2f vector = data.crosshairOffset;
		vector.Normalize();
		if (!Sound::isTooFar(data.pos))
		{
			ShakeScreen(vector * -25.0f, 8, data.pos);
			Particles::Shell(data.pos, Vec2f(0, -7), SColor(255, 255, 255, 90));
			sprite.PlayRandomSound("SniperShot");
		}
		else
		{
			Sound::Play2D("DistantShot", 0.1f, data.pos.x > getCamera().getPosition().x ? 1.0f : -1.0f);		
		}
		if (data.ammo == 0)
		{
			data.sprite.PlaySound("DryShot");
			AddMessageAbove(this, "no ammo");
		}
	}
	else if (cmd == Soldier::Commands::CHANGE_CAMO)
	{
		u8 seed = params.read_u8();

		data.camoMode = seed;
	}
}
