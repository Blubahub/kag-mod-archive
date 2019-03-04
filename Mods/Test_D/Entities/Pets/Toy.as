#include "Pets.as"

const f32 MAX_SPEED = 8.0f;

void onInit(CBlob@ this)
{
	ShapeConsts@ consts = this.getShape().getConsts();
	consts.bullet = true;
	consts.net_threshold_multiplier = 0.5f;
	this.getSprite().SetZ(-60.0f);
	this.SetMapEdgeFlags(u8(CBlob::map_collide_sides | CBlob::map_collide_nodeath | CBlob::map_collide_bounce));
	this.server_SetTimeToDie(60);

	bool throwable = false;	
	f32 gravityScale = 1.0f;
	f32 throw_modifier = 1.0f;
	string fall_sound = "BallDrop";

	const u8 type = getToyType(this);
	switch (type)
	{
		case TOY_FRISBEE:
		throwable = true;
		gravityScale = 0.15f;
		throw_modifier = 0.4f;
		this.RemoveScript("FakeRolling.as");
		break;

		case TOY_WOOLBALL:
		gravityScale = 0.5f;
		break;

		case TOY_MASCOT:
		gravityScale = 0.5f;
		fall_sound = "Bell";
		//this.RemoveScript("FakeRolling.as");
		break;

		case TOY_HAMBURGER:
		gravityScale = 0.75f;
		this.RemoveScript("FakeRolling.as");
		break;			

		case TOY_NEST:
		this.RemoveScript("FakeRolling.as");
		break;		

		case TOY_CARROT:
		gravityScale = 0.75f;
		this.RemoveScript("FakeRolling.as");
		break;		

		case TOY_FERTILIZER:
		gravityScale = 0.75f;
		this.RemoveScript("FakeRolling.as");
		break;											
	}	

	if (throwable){
		this.Tag("throwable");
	}
	this.getShape().SetGravityScale(gravityScale);
	this.set_f32("throw_modifier", throw_modifier);
	this.set_string("fall_sound", fall_sound);
}

// void onTick(CBlob@ this)
// {
// 	const u8 type = getToyType(this);
// 	switch (type)
// 	{
// 		case TOY_FRISBEE:
// 		break;
// 	}
// }

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	const f32 vellen = this.getShape().vellen;

	if (solid)
	{
		this.getSprite().PlayRandomSound(this.get_string("fall_sound"), 1.0f, 1.0f);
	}

	if (blob !is null)
	{
		if (blob.hasTag("player") && !blob.hasTag("bouncer"))
		{
			blob.server_AttachTo(this, 0);
		}

		if (blob.getName() == "pet"){
			this.getSprite().PlayRandomSound(this.get_string("fall_sound"), 1.0f, 1.0f);
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	this.server_SetTimeToDie(600);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.server_SetTimeToDie(60);
}


// SPRITE


void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	const u8 type = getToyType(blob);
	switch (type)
	{
		case TOY_FRISBEE:
		this.SetFrameIndex(0);
		break;
		case TOY_WOOLBALL:
		this.SetFrameIndex(1);
		break;
		case TOY_MASCOT:
		this.SetFrameIndex(2);
		break;
		case TOY_HAMBURGER:
		this.SetFrameIndex(3);
		break;		
		case TOY_NEST:
		this.SetFrameIndex(4);
		break;		
		case TOY_FERTILIZER:
		this.SetFrameIndex(6);
		break;		
		case TOY_CARROT:
		this.SetFrameIndex(5);
		break;				

	}
}