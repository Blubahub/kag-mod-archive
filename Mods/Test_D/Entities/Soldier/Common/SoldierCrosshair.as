#include "SoldierCommon.as"

namespace Soldier
{
	void StartCrosshair(CBlob@ this, Data@ data, const bool lockCrouch = false, const f32 yoffset = 0)
	{
		data.crosshair = true;
		data.crosshairOffset = Vec2f((data.facingLeft ? -1.0f : 1.0f) * data.defaultCrosshairDistance, yoffset);
		data.crosshairEasing = 0.01f;
		data.lockCrouch = lockCrouch ? Soldier::crouchLockTicks : 0;
		data.crosshairDownAllowed = data.down ? data.crosshairAllowedTicks : 0;
		data.crosshairUpAllowed = data.up ? data.crosshairAllowedTicks : 0;
		data.crosshairLeftAllowed = data.left ? data.crosshairAllowedTicks : 0;
		data.crosshairRightAllowed = data.right ? data.crosshairAllowedTicks : 0;
		data.crosshairTime = 0;
		this.Tag("crosshair");
	}

	void EndCrosshair(CBlob@ this, Data@ data)
	{
		data.crosshair = false;
		this.Untag("crosshair");
	}

	void TickCrosshair(CBlob@ this, Data@ data)
	{
		if (!data.crosshair)
		{
			// unlock crouch
			if (data.lockCrouch > 0)
			{
				if (this.isKeyJustPressed(key_left) || this.isKeyJustPressed(key_right) || this.isKeyJustPressed(key_jump))
				{
					data.lockCrouch = 0;
				}
			}
			return;
		}

		data.crosshairTime++;

		//if (this.isMyPlayer())
		{
			CControls@ controls = this.getControls();
			const f32 crosshairSpeed = data.crosshairSpeed * (controls !is null ? controls.hat1intensity * controls.hat1intensity*controls.hat1intensity : 1.0f);
			if (data.left && data.crosshairLeftAllowed == 0)
				data.crosshairOffset.x -= crosshairSpeed * data.crosshairEasing;
			else if (data.right && data.crosshairRightAllowed == 0)
				data.crosshairOffset.x += crosshairSpeed * data.crosshairEasing;
			if (data.up && data.crosshairUpAllowed == 0)
				data.crosshairOffset.y -= crosshairSpeed * data.crosshairEasing;
			else if (data.down && data.crosshairDownAllowed == 0)
				data.crosshairOffset.y += crosshairSpeed * data.crosshairEasing;

			//lock length of crosshair
			{
				f32 len = data.crosshairOffset.Length();
				if (len > data.crosshairMaxDist && len > 0)
				{
					data.crosshairOffset /= len; //normalise
					data.crosshairOffset *= data.crosshairMaxDist; //set length
				}
			}

			if (data.left || data.right || data.up || data.down)
			{
				data.crosshairEasing = Maths::Sqrt(data.crosshairEasing * 0.9f);
			}
			else
			{
				data.crosshairEasing = Maths::Max(data.crosshairEasing * data.crosshairEasing, 0.01f);
			}

			// unlock

			if (this.isKeyJustReleased(key_down))
				data.crosshairDownAllowed = 0;
			if (this.isKeyJustReleased(key_up))
				data.crosshairUpAllowed = 0;
			if (this.isKeyJustReleased(key_left))
				data.crosshairLeftAllowed = 0;
			if (this.isKeyJustReleased(key_right))
				data.crosshairRightAllowed = 0;

			if (data.left && data.crosshairLeftAllowed > 0)
				data.crosshairLeftAllowed--;
			if (data.right && data.crosshairRightAllowed > 0)
				data.crosshairRightAllowed--;
			if (data.up && data.crosshairUpAllowed > 0)
				data.crosshairUpAllowed--;
			if (data.down && data.crosshairDownAllowed > 0)
				data.crosshairDownAllowed--;
		}

		data.facingLeft = data.crosshairOffset.x < 0;
		this.SetFacingLeft(data.facingLeft);
	}

	void SyncCrosshair(CBlob@ this, Data@ data)
	{
		CBitStream params;
		params.write_Vec2f(data.crosshairOffset);
		this.SendCommand(Soldier::Commands::CROSSHAIR, params);
	}
}