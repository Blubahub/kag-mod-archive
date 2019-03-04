
//script for an land animal - attach to:
// blob
// movement
// 		vars:		f32 swimspeed f32 swimforce


#define SERVER_ONLY

#include "Hitters.as";
#include "AnimalConsts.as";


//blob
void onInit(CBlob@ this)
{
	AnimalVars vars;
	//walking vars
	vars.walkForce.Set(1.5f, -0.1f);
	vars.runForce.Set(2.5f, -1.0f);
	vars.slowForce.Set(1.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -20.0f);
	vars.maxVelocity = 1.1f;
	this.set("vars", vars);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
}


//movement

void onInit(CMovement@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	
	AnimalVars@ vars;
	if (!blob.get("vars", @vars))
		return;
	
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	bool up = blob.isKeyPressed(key_up);
	bool down = blob.isKeyPressed(key_down);

	Vec2f vel = blob.getVelocity();
	if (left)
	{
		blob.AddForce(Vec2f(-1.0f * vars.walkForce.x, vars.walkForce.y));
	}
	if (right)
	{
		blob.AddForce(Vec2f(1.0f * vars.walkForce.x, vars.walkForce.y));
	}

	// jump if blocked

	if (left || right || up)
	{
		Vec2f pos = blob.getPosition();
		CMap@ map = blob.getMap();
		const f32 radius = blob.getRadius();
		if ((blob.isOnGround() || blob.isInWater()) && (up || (right && map.isTileSolid(Vec2f(pos.x + radius, pos.y + 0.45f * radius))) || (left && map.isTileSolid(Vec2f(pos.x - radius, pos.y + 0.45f * radius)))
		                                               )
		   )
		{
			f32 mod = blob.isInWater() ? 0.23f : 1.0f;
			blob.AddForce(Vec2f(mod * vars.jumpForce.x, mod * vars.jumpForce.y));
		}
	}


	CShape@ shape = blob.getShape();

	// too fast - slow down
	if (shape.vellen > vars.maxVelocity)
	{
		Vec2f vel = blob.getVelocity();
		blob.AddForce(Vec2f(-vel.x * vars.slowForce.x, -vel.y * vars.slowForce.y));
	}
	
	if(getMap().getTile(blob.getPosition()).type == 144){
		
		f32 climb = -0.5f;
		if(up)climb = -1.5f;
		if(down)climb = 1.0f;
		
		blob.setVelocity(Vec2f(blob.getVelocity().x,climb));
	}	
}
