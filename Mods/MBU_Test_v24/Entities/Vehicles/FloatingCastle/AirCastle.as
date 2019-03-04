#include "VehicleCommon.as"
#include "Hitters.as"

// Boat logic

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              84.0f, // move speed
	              10.0f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_SetupAirship(this, v, -1600.0f);
	
	this.getShape().getConsts().bullet = false;
	this.getShape().getConsts().transports = true;

	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ background = sprite.addSpriteLayer("background", "Balloon.png", 32, 16);
	if (background !is null)
	{
		background.addAnimation("default", 0, false);
		int[] frames = { 3 };
		background.animation.AddFrames(frames);
		background.SetRelativeZ(-5.0f);
		background.SetOffset(Vec2f(0.0f, -65.0f));
	}

	CSpriteLayer@ burner = sprite.addSpriteLayer("burner", "Balloon.png", 8, 16);
	if (burner !is null)
	{
		{
			Animation@ a = burner.addAnimation("default", 3, true);
			int[] frames = { 41, 42, 43 };
			a.AddFrames(frames);
		}
		{
			Animation@ a = burner.addAnimation("up", 3, true);
			int[] frames = { 38, 39, 40 };
			a.AddFrames(frames);
		}
		{
			Animation@ a = burner.addAnimation("down", 3, true);
			int[] frames = { 44, 45, 44, 46 };
			a.AddFrames(frames);
		}
		burner.SetRelativeZ(51.5f);
		burner.SetOffset(Vec2f(0.0f, -71.0f));
	}
	
	
	CSpriteLayer@ foreground = sprite.addSpriteLayer("foreground", "AirCastle.png", 82, 125);
	if (foreground !is null)
	{
		foreground.addAnimation("default", 0, false);
		int[] frames = { 1 };
		foreground.animation.AddFrames(frames);
		foreground.SetRelativeZ(50.0f);
		foreground.SetOffset(Vec2f(0.0f, -54.0f));
	}
	
	CSpriteLayer@ covering = sprite.addSpriteLayer("covering", "AirCastle.png", 82, 125);
	if (covering !is null)
	{
		covering.addAnimation("default", 0, false);
		int[] frames = { 2 };
		covering.animation.AddFrames(frames);
		covering.SetRelativeZ(100.0f);
		covering.SetOffset(Vec2f(0.0f, -54.0f));
	}
	
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
		}
	}
	
	//Cancer code
	int x = Vec2f(5,0.0f).x;
	
	getMap().server_AddMovingSector(Vec2f(-6.0f, -57.0f), Vec2f(6.0f, -9.0f), "ladder", this.getNetworkID());
	
	Vec2f pos_off(0, 0.0f);

	{   //Bottom wall left
		Vec2f[] shape = { Vec2f(8.0f,  21.0f) - pos_off,
		                  Vec2f(21.0f, 21.0f) - pos_off,
		                  Vec2f(21.0f, 36.0f) - pos_off,
		                  Vec2f(16.0f, 36.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
	
	{   //Bottom wall right
		Vec2f[] shape = { Vec2f(75.0f,  21.0f) - pos_off,
		                  Vec2f(88.0f, 21.0f) - pos_off,
		                  Vec2f(75.0f, 36.0f) - pos_off,
		                  Vec2f(80.0f, 36.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
	
	
	{   //Top wall left
		Vec2f[] shape = { Vec2f(17.0f,  5.0f) - pos_off,
		                  Vec2f(21.0f, 5.0f) - pos_off,
		                  Vec2f(21.0f, 21.0f) - pos_off,
		                  Vec2f(17.0f, 21.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
	
	{   //Top wall right
		Vec2f[] shape = { Vec2f(75.0f,  5.0f) - pos_off,
		                  Vec2f(80.0f, 5.0f) - pos_off,
		                  Vec2f(80.0f, 21.0f) - pos_off,
		                  Vec2f(75.0f, 21.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
	
	{   //middle floor left
		Vec2f[] shape = { Vec2f(21.0f,  5.0f) - pos_off,
		                  Vec2f(39.0f, 5.0f) - pos_off,
		                  Vec2f(39.0f, 13.0f) - pos_off,
		                  Vec2f(21.0f, 13.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
	
	{   //middle floor right
		Vec2f[] shape = { Vec2f(57.0f,  5.0f) - pos_off,
		                  Vec2f(75.0f, 5.0f) - pos_off,
		                  Vec2f(75.0f, 13.0f) - pos_off,
		                  Vec2f(57.0f, 13.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
	
	{   //middle floor left
		Vec2f[] shape = { Vec2f(17.0f,  -21.0f) - pos_off,
		                  Vec2f(39.0f, -21.0f) - pos_off,
		                  Vec2f(39.0f, -14.0f) - pos_off,
		                  Vec2f(17.0f, -14.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
	
	{   //middle floor right
		Vec2f[] shape = { Vec2f(57.0f,  -21.0f) - pos_off,
		                  Vec2f(80.0f, -21.0f) - pos_off,
		                  Vec2f(80.0f, -14.0f) - pos_off,
		                  Vec2f(57.0f, -14.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
	
	this.getShape().getConsts().rotates = false;
	
	this.Tag("auto_pilot");
}

void onTick(CBlob@ this)
{
	//if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{
		if (this.getHealth() > 1.0f)
		{
			VehicleInfo@ v;
			if (!this.get("VehicleInfo", @v))
			{
				return;
			}
			Vehicle_StandardControls(this, v);

			//TODO: move to atmosphere damage script
			f32 y = this.getPosition().y;
			if (y < 20 && this.getVelocity().y < 0)
			{
				this.setVelocity(Vec2f(this.getVelocity().x,0));
			}
		}
		else
		{
			this.server_DetachAll();
			this.setAngleDegrees(this.getAngleDegrees() + (this.isFacingLeft() ? 1 : -1));
			if (this.isOnGround() || this.isInWater())
			{
				this.server_SetHealth(-1.0f);
				this.server_Die();
			}
			else
			{
				//TODO: effects
				if (getGameTime() % 30 == 0)
					this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 0.05f, 0, true);
			}
		}
	}
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge) {}
bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
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

// SPRITE

void onInit(CSprite@ this)
{
	this.SetZ(-10.0f);
	this.getCurrentScript().tickFrequency = 5;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	f32 ratio = 1.0f - (blob.getHealth() / blob.getInitialHealth());
	this.animation.setFrameFromRatio(ratio);

	CSpriteLayer@ burner = this.getSpriteLayer("burner");
	if (burner !is null)
	{
		s8 dir = blob.get_s8("move_direction");
		if (dir == 0)
		{
			blob.SetLightColor(SColor(255, 255, 240, 171));
			burner.SetAnimation("default");
		}
		else if (dir < 0)
		{
			blob.SetLightColor(SColor(255, 255, 240, 200));
			burner.SetAnimation("up");
		}
		else if (dir > 0)
		{
			blob.SetLightColor(SColor(255, 255, 200, 171));
			burner.SetAnimation("down");
		}
	}
	
	CSpriteLayer@ covering = this.getSpriteLayer("covering");
	if (covering !is null){
		bool vis = true;
		if(getLocalPlayerBlob() !is null){
			if(blob.getDistanceTo(getLocalPlayerBlob()) < 42.0f){
				vis = false;
			}
		}
		covering.SetVisible(vis);
	}
}
