// PushButton.as

#include "MechanismsCommon.as";

class Switch : Component
{
	Switch(Vec2f position)
	{
		x = position.x;
		y = position.y;
	}
};

void onInit(CBlob@ this)
{
	// used by BuilderHittable.as
	this.Tag("builder always hit");

	// used by BlobPlacement.as
	this.Tag("place norotate");

	// used by TileBackground.as
	this.set_TileType("background tile", CMap::tile_wood_back);

	// background, let water overlap
	this.getShape().getConsts().waterPasses = true;

	this.addCommandID("activate");
	this.addCommandID("switch");

	AddIconToken("$pushbutton_1$", "PushButton.png", Vec2f(16, 16), 2);

	this.getCurrentScript().tickIfTag = "active";

	this.set_Vec2f("tpPos", Vec2f(-1, -1));
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(!isStatic || this.exists("component")) return;

	const Vec2f position = this.getPosition() / 8;

	Switch component(position);
	this.set("component", component);

	this.set_u8("state", 0);

	if(getNet().isServer())
	{
		MapPowerGrid@ grid;
		if(!getRules().get("power grid", @grid)) return;

		grid.setAll(
		component.x,                        // x
		component.y,                        // y
		TOPO_NONE,                          // input topology
		TOPO_CARDINAL,                      // output topology
		INFO_SOURCE,                        // information
		0,                                  // power
		0);                                 // id
	}

	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	sprite.SetFacingLeft(false);
	sprite.SetZ(-50);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(!this.isOverlapping(caller) || !this.getShape().isStatic() || this.get_u8("state") != 0) return;

	CBitStream arg;

	arg.write_string(caller.getPlayer().getUsername());

	CButton@ button = caller.CreateGenericButton(
	"$pushbutton_1$",                           // icon token
	Vec2f_zero,                                 // button offset
	this,                                       // button attachment
	this.getCommandID("activate"),              // command id
	getTranslatedString("Activate"), arg);           // description

	button.radius = 8.0f;
	button.enableRadius = 20.0f;
}

void onTick(CBlob@ this)
{
	if(getGameTime() < this.get_u32("duration")) return;

	Component@ component = null;
	if(!this.get("component", @component)) return;

	MapPowerGrid@ grid;
	if(!getRules().get("power grid", @grid)) return;

	// set state on server, sync to clients
	this.set_u8("state", 0);
	this.Sync("state", true);

	this.Untag("active");

	grid.setInfo(
	component.x,                        // x
	component.y,                        // y
	INFO_SOURCE);                       // information
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	return 0;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("activate"))
	{
		string username = params.read_string();
		if(this.get_Vec2f("tpPos").x > -1)
		{
			getPlayerByUsername(username).getBlob().setPosition(this.get_Vec2f("tpPos"));
			getPlayerByUsername(username).getBlob().setVelocity(Vec2f_zero);
			getPlayerByUsername(username).getBlob().getShape().PutOnGround();
		}
		if(getNet().isServer())
		{
			this.set_string("Caller", username);
			// double check state, if state != 0, return
			if(this.get_u8("state") != 0) return;

			Component@ component = null;
			if(!this.get("component", @component)) return;

			MapPowerGrid@ grid;
			if(!getRules().get("power grid", @grid)) return;

			// only set tag on server, so only the server ticks
			this.Tag("active");

			this.set_u32("duration", getGameTime() + 36);

			// set state, sync to clients
			this.set_u8("state", 1);
			this.Sync("state", true);
			grid.setInfo(
			component.x,                        // x
			component.y,                        // y
			INFO_SOURCE | INFO_ACTIVE);         // information
		}

		CSprite@ sprite = this.getSprite();
		if(sprite is null) return;

		sprite.SetAnimation("default");
		sprite.SetAnimation("activate");
		sprite.PlaySound("PushButton.ogg");
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
