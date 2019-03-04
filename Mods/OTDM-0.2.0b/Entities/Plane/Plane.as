#include "VehicleCommon.as"

// Boat logic

void onInit(CBlob@ this)
{  
	Vec2f fixedpos = Vec2f(this.getPosition()+Vec2f(0, -32));
	this.setPosition(fixedpos);
	//this.getShape().SetOffset(Vec2f(5.0, 1.25));
	this.Tag("convert on sit");
	Vehicle_Setup(this,
	              200.0f, // move speed
	              0.19f,  // turn speed
	              Vec2f(0.0f, -5.0f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_SetupAirship(this, v, -900.0f);

	Vec2f pos_off(0, 0);
	this.set_f32("map dmg modifier", 1.0f);
	this.set_f32("hit dmg modifier", 1.0f);

	this.getShape().SetOffset(Vec2f(-6, 16));
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().transports = true;
	this.getShape().SetRotationsAllowed(false);

}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}

		Vehicle_StandardControls(this, v);

		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			CSprite@ sprite = this.getSprite();
			uint flyerCount = 0;
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.name == "FLYER")
				{
					CBlob@ blob = ap.getOccupied();
					CSpriteLayer@ propeller = sprite.getSpriteLayer(flyerCount);
					if (propeller !is null)
					{
						propeller.animation.loop = ap.isKeyPressed(key_down);;
						f32 y = (blob !is null) ? -40.0f : -35.0f;
						propeller.SetOffset(Vec2f(-ap.offset.x, ap.offset.y + y));

						const bool left = ap.isKeyPressed(key_left);
						const bool right = ap.isKeyPressed(key_right);
						propeller.ResetTransform();
						f32 faceMod = this.isFacingLeft() ? 1.0f : -1.0f;
						if (left)
						{
							propeller.RotateBy(90.0f + faceMod * 25.0f, Vec2f_zero);
						}
						else if (right)
						{
							propeller.RotateBy(90.0f - faceMod * 25.0f, Vec2f_zero);
						}
						else
						{
							propeller.RotateBy(90.0f, Vec2f_zero);
						}

					}

					flyerCount++;
				}
			}
		}
	}
	if (this.getHealth() < 4.0 )
	{
		this.getShape().SetRotationsAllowed(true);
	}
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge) {}
bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_boat(this, blob);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

// SPRITE

void onInit(CSprite@ this)
{
}

void onTick(CSprite@ this)
{
	this.SetZ(-50.0f);
	CBlob@ blob = this.getBlob();
	this.animation.setFrameFromRatio(1.0f - (blob.getHealth() / blob.getInitialHealth()));	

}
