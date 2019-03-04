/* CreatureMovement.as
 * author: Aphelion
 */

#define SERVER_ONLY

#include "Hitters.as";
#include "CreatureCommon.as";

void onInit(CBlob@ this)
{
    if(!this.exists("moveVars"))
	{
	    // set default vars
		CreatureMoveVars vars;
		
		vars.walkForce.Set(4.0f, 0.0f);
		vars.jumpForce.Set(0.0f, -2.0f);
		vars.climbTime = 20;
		this.set("moveVars", vars);
	}

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
}

void onInit(CMovement@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";   
}

void onTick(CMovement@ this)
{
    CBlob@ blob = this.getBlob();
	
	CreatureMoveVars@ vars;
	if (!blob.get( "moveVars", @vars ))
		return;
	
	CShape@ shape = blob.getShape();
	
	const bool left    = blob.isKeyPressed(key_left);
	const bool right   = blob.isKeyPressed(key_right);
	const bool up      = blob.isKeyPressed(key_up);
	const bool down    = blob.isKeyPressed(key_down);
	
	// left and right movement
	if (left || right)
	{
		f32 mod = blob.isInWater() ? 0.23f : 1.0f;
	    blob.AddForce(Vec2f((left ? -1.0f : 1.0f) * vars.walkForce.x * mod, vars.walkForce.y * mod));
	}
	
	// jump if blocked
	if (left || right || up)
	{
		CMap@ map = blob.getMap();
		Vec2f pos = blob.getPosition();
		
		const f32 radius = blob.getRadius();
		
		if ((blob.isOnGround() || blob.isInWater()) && 
           (up || (right && map.isTileSolid( Vec2f( pos.x + (radius + 1.0f), pos.y ))) || 
		          (left && map.isTileSolid( Vec2f( pos.x - (radius + 1.0f), pos.y )))))
		{ 
			f32 mod = blob.isInWater() ? 0.23f : 1.0f;
			blob.AddForce(Vec2f(vars.jumpForce.x * mod * blob.getMass(), vars.jumpForce.y * mod * blob.getMass()));
		}
		if (( (right && map.isTileSolid( Vec2f( pos.x + (radius + 1.0f), pos.y ))) || 
		      (left && map.isTileSolid( Vec2f( pos.x - (radius + 1.0f), pos.y )))))
		{
		    u8 climb_step = blob.get_u8("climb_step");
			if(climb_step >= vars.climbTime)
			{
			    blob.set_u8("climb_step", 0);
			}
			else
			{
			    f32 mod = blob.isInWater() ? 0.23f : 1.0f;
			    blob.AddForce(Vec2f(vars.jumpForce.x * mod * blob.getMass() / 1.9, vars.jumpForce.y * mod * blob.getMass() / 1.9));
			    blob.set_u8("climb_step", climb_step++);
			}
		}
	}
}
