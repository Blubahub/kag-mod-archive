#include "VehicleCommon.as"
#include "Knocked.as";
#include "MakeCrate.as";
#include "MiniIconsInc.as";

// Unicycle logic

const u8 baseline_charge = 15;

const u8 charge_contrib = 35;

const u8 cooldown_time = 45;
const u8 startStone = 100;

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              60.0f, // move speed
	              0.1f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}

	Vehicle_SetupGroundSound(this, v, "WoodenWheelsRolling",  // movement sound
	                         2.0f, // movement sound volume modifier   0.0f = no manipulation
	                         2.0f // movement sound pitch modifier     0.0f = no manipulation
	                        );
	Vehicle_addUnicycleWheel(this, v, "UnicycleWheel.png", 16, 16, 1, Vec2f(0,1.5));

	//this.getShape().SetOffset(Vec2f(0, -5));
	
	Vec2f massCenter(0, 20);
	this.getShape().SetCenterOfMassOffset(massCenter);
	this.set_Vec2f("mass center", massCenter);
	
	
	v.fire_time;
}

void onInit(CSprite@ this)
{
	this.SetZ(-3); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ front = this.addSpriteLayer("front", this.getFilename() , 16, 32, blob.getTeamNum(), blob.getSkinNum());

	if (front !is null)
	{
		Animation@ anim = front.addAnimation("default", 0, false);
		anim.AddFrame(1);
		front.SetOffset(Vec2f(0.0f, -5.5f));
		front.SetRelativeZ(2.0f);
	}
}

CSpriteLayer@ Vehicle_addUnicycleWheel(CBlob@ this, VehicleInfo@ v, const string& in textureName, int frameWidth, int frameHeight, int frame, Vec2f offset)
{
	v.wheels_angle = 0;
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ wheel = sprite.addSpriteLayer("!w " + sprite.getSpriteLayerCount(), textureName, frameWidth, frameHeight);

	if (wheel !is null)
	{
		Animation@ anim = wheel.addAnimation("default", 0, false);
		anim.AddFrame(frame);
		wheel.SetOffset(offset);
		wheel.SetRelativeZ(1.0f);
	}

	return wheel;
}

void onTick(CBlob@ this)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
		return;
	Vehicle_StandardControls(this, v);
	
	CSprite@ sprite = this.getSprite();
	uint sprites = sprite.getSpriteLayerCount();
	
	for (uint i = 0; i < sprites; i++)
	{
		CSpriteLayer@ wheel = sprite.getSpriteLayer(i);
		if (wheel.name.substr(0, 2) == "!w") // this is a wheel
		{
			f32 wheels_angle = (Maths::Round(wheel.getWorldTranslation().x * 10) % 360) / 1.0f;
			wheel.ResetTransform();
			wheel.RotateBy(wheels_angle + i * i * 16.0f, Vec2f_zero);
		}
	}
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge)
{
	return;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this, blob);
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