#include "VehicleCommon.as"
#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";
// Boat logic

//attachment point of the sail
const int sail_index = 0;

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              400.0f, // move speed
	              0.18f,  // turn speed
	              Vec2f(0.0f, -2.5f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_SetupWaterSound(this, v, "BoatRowing",  // movement sound
	                        0.0f, // movement sound volume modifier   0.0f = no manipulation
	                        0.0f // movement sound pitch modifier     0.0f = no manipulation
	                       );
	this.getShape().SetOffset(Vec2f(-6, 12));
	this.getShape().SetCenterOfMassOffset(Vec2f(-1.5f, 6.0f));
	this.getShape().getConsts().transports = true;
	this.getShape().getConsts().bullet = false;
	this.set_f32("map dmg modifier", 150.0f);
	
	this.Tag("respawn");

	InitRespawnCommand(this);
	InitClasses(this);
	this.Tag("change class store inventory");

	//block knight sword
	this.Tag("blocks sword");

	// additional shape

	Vec2f[] frontShape;
	frontShape.push_back(Vec2f(109.0f, -19.0f));
	frontShape.push_back(Vec2f(113.0f, -19.0f));
	frontShape.push_back(Vec2f(115.0f, 0.0f));
	frontShape.push_back(Vec2f(111.0f, 0.0f));
	this.getShape().AddShape(frontShape);

	Vec2f[] backShape;
	backShape.push_back(Vec2f(8.0f, -8.0f));
	backShape.push_back(Vec2f(10.0f, 0.0f));
	backShape.push_back(Vec2f(6.0f, 0.0f));
	this.getShape().AddShape(backShape);

	// sprites

	// add mast
	this.set_bool("has mast", true);

	const Vec2f mastOffset(-6, -6);

	CSpriteLayer@ mast = this.getSprite().addSpriteLayer("mast", 80, 48);
	if (mast !is null)
	{
		Animation@ anim = mast.addAnimation("default", 0, false);
		int[] frames = {6};
		anim.AddFrames(frames);
		mast.SetOffset(Vec2f(9, -11) + mastOffset);
		mast.SetRelativeZ(-20.0f);
	}

	if (this.get_bool("has mast"))		// client-side join - might be false
	{
		// add sail

		CSpriteLayer@ sail = this.getSprite().addSpriteLayer("sail " + sail_index, 80, 48);
		if (sail !is null)
		{
			Animation@ anim = sail.addAnimation("default", 3, false);
			int[] frames = {7, 5, 3};
			anim.AddFrames(frames);
			sail.SetOffset(Vec2f(9, -11) + mastOffset);
			sail.SetRelativeZ(-20.0f);

			sail.SetVisible(false);
		}
	}
	else
	{
		if (mast !is null)
		{
			mast.animation.frame = 1;
		}
	}

	// add head
	{
		CSpriteLayer@ head = this.getSprite().addSpriteLayer("head", 16, 16);
		if (head !is null)
		{
			Animation@ anim = head.addAnimation("default", 0, false);
			anim.AddFrame(5);
			head.SetOffset(Vec2f(-52, -12));
			head.SetRelativeZ(1.0f);
		}
	}

	//add minimap icon
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(16, 8));
}

void onTick(CBlob@ this)
{
	const int time = this.getTickSinceCreated();
	if (this.hasAttached() || time < 30)
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		Vehicle_StandardControls(this, v);
	}

	if (time % 12 == 0)
	{
		Vehicle_DontRotateInWater(this);
	}
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge) {}
bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.getShape().getConsts().platform)
		return false;
	return Vehicle_doesCollideWithBlob_boat(this, blob);
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	const f32 tier1 = this.getInitialHealth() * 0.6f;
	const f32 health = this.getHealth();

	if (health < tier1 && oldHealth >= tier1)
	{
		this.set_bool("has mast", false);
		this.Tag("no sail");

		CSprite@ sprite = this.getSprite();

		CSpriteLayer@ mast = sprite.getSpriteLayer("mast");
		if (mast !is null)
			mast.animation.frame = 1;

		CSpriteLayer@ sail = sprite.getSpriteLayer("sail " + sail_index);
		if (sail !is null)
			sail.SetVisible(false);
	}
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
