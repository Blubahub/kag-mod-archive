// Flag logic

const string return_prop = "return time";
const u16 return_time = 600;
const u16 fast_return_speedup = 3;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 5;

	//cannot fall out of map
	this.SetMapEdgeFlags(u8(CBlob::map_collide_up) |
	                     u8(CBlob::map_collide_down) |
	                     u8(CBlob::map_collide_sides));

	this.set_u16(return_prop, 0);

	Vec2f pos = this.getPosition();

	this.addCommandID("pickup");

	//special item - prioritise pickup
	this.Tag("special");


	//some legacy bug :/
	if (pos.x == 0 && pos.y == 0)
	{
		if (sv_test)
		{
			warning("Flags spawned at (0,0), investigate!");
		}
	}
}

void onTick(CBlob@ this)
{
}

//sprite

void onInit(CSprite@ this)
{
	this.SetZ(-10.0f);
	CSpriteLayer@ flag = this.addSpriteLayer("flag_layer", "/vaterflag.png", 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (flag !is null)
	{
		flag.SetOffset(Vec2f(15, -8));
		flag.SetRelativeZ(1.0f);
		Animation@ anim = flag.addAnimation("default", XORRandom(3) + 3, true);
		anim.AddFrame(0);
		anim.AddFrame(2);
		anim.AddFrame(4);
		anim.AddFrame(6);
	}

	if (this.getBlob().getTeamNum() == 0)
	{
		this.getBlob().SetFacingLeft(true);
	}
}

// alert and capture progress bar

void onRender(CSprite@ this)
{
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//ignore all damage except from special hit
	if (customData == 0xfa)
	{
		this.server_SetHealth(-1.0f);
		this.server_Die();
	}
	return 0.0f;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getShape().isStatic());
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{

}
