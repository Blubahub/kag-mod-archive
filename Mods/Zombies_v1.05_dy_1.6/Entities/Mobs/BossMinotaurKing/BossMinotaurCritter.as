
//script for a LandCritter - attach to:
// blob
// movement
// 		vars:		f32 swimspeed f32 swimforce

#define SERVER_ONLY

#include "Hitters.as";

shared class CritterVars
{
	Vec2f walkForce;  
	Vec2f runForce;
	Vec2f slowForce;
	Vec2f jumpForce;
	f32 maxVelocity;
};

//blob
void onInit(CBlob@ this)
{
	CritterVars vars;
	//walking vars
	int gamestart = getRules().get_s32("gamestart");
	int day_cycle = getRules().daycycle_speed * 60;
	int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
	float difficulty = getRules().get_f32("difficulty")/4.0;
	int land_mobs_increase_jump_day = getRules().get_s32("land_mobs_increase_jump_day");
	if (difficulty<1.0) difficulty=1.0;
	if (difficulty>6.0) difficulty=6.0;
	vars.walkForce.Set(20.0f,0.0f);
	vars.runForce.Set(20.0f,0.0f);
	vars.slowForce.Set(3.0f,0.0f);
	if (dayNumber > land_mobs_increase_jump_day)
	vars.jumpForce.Set(0.0f,2*-3.4f);
	else
	vars.jumpForce.Set(0.0f,-3.4f);
	
	vars.maxVelocity = difficulty;
	this.set( "vars", vars );

	// force no team
	this.server_setTeamNum(10);
	f32 boss_minotaur_health = getRules().get_f32("boss_minotaur_health");
	this.server_SetHealth(boss_minotaur_health);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
}

//movement
void onInit( CMovement@ this )
{
	//this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	//this.getCurrentScript().runProximityTag = "player";
	//this.getCurrentScript().runProximityRadius = 120.0f;
	this.getCurrentScript().removeIfTag	= "dead";   
}

void onTick( CMovement@ this )
{
    CBlob@ blob = this.getBlob();
    const string chomp_tag = "chomping";
	CritterVars@ vars;
	if (!blob.get( "vars", @vars ))
		return;
	if (blob.getHealth() <= 0.0) return; // dead
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	bool up = blob.isKeyPressed(key_up);
	bool down = blob.isKeyPressed(key_down);
	CMap@ map = blob.getMap();
	Vec2f pos = blob.getPosition();
	const f32 radius = blob.getRadius();
	bool rightsolid = map.isTileSolid( Vec2f( pos.x + (radius+1.0f), pos.y )) ;
	bool leftsolid = map.isTileSolid( Vec2f( pos.x - (radius+1.0f), pos.y ));
	Vec2f vel = blob.getVelocity();
	if (left) {
		blob.AddForce(Vec2f( -1.0f * vars.walkForce.x, vars.walkForce.y));
	}
	if (right) {
		blob.AddForce(Vec2f( 1.0f * vars.walkForce.x, vars.walkForce.y));
	}
	if (((right && rightsolid) || (left && leftsolid)) && XORRandom(10)==0)
	{
		blob.AddForce(Vec2f( vars.jumpForce.x, vars.jumpForce.y*blob.getMass()/2));
	}
	// jump if blocked


	if ((left || right || up))
	{
		
		if (((right && rightsolid) || (left && leftsolid)) && XORRandom(10)==0)
		{
			blob.AddForce(Vec2f( vars.jumpForce.x, vars.jumpForce.y*blob.getMass()/2));
		}
		if (blob.isInWater() && (up || (right && rightsolid) || (left && leftsolid)))
		{ 	
			if (!down)
			{
				f32 mod = blob.isInWater() ? 0.23f : 1.0f;
				blob.AddForce(Vec2f( mod*vars.jumpForce.x*blob.getMass(), mod*vars.jumpForce.y*blob.getMass()));
			}
			
		}
		
		if (XORRandom(15)==0 && !down)
		blob.AddForce(Vec2f( vars.jumpForce.x, vars.jumpForce.y*blob.getMass()/2));
	}


	CShape@ shape = blob.getShape();

	// too fast - slow down
	if (shape.vellen > vars.maxVelocity)
	{		  
		Vec2f vel = blob.getVelocity();
		blob.AddForce( Vec2f(-vel.x * vars.slowForce.x, -vel.y * vars.slowForce.y) );
	}
}
