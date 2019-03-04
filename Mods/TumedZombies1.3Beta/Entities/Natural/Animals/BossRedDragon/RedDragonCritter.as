
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
	int land_mobs_increase_jump_day = getRules().get_s32("land_mobs_increase_jump_day");
	vars.walkForce.Set(34.0f,0.0f);
	vars.runForce.Set(74.0f,0.0f);
	vars.slowForce.Set(7.5f,0.0f);
	if (dayNumber > land_mobs_increase_jump_day)
	vars.jumpForce.Set(0,-28.0f);
	else
	vars.jumpForce.Set(0,-24.0f);

	vars.maxVelocity = 6.0f;
	this.set( "vars", vars );
	this.set_s32("flymod",0);
	// force no team
	this.server_setTeamNum(-1);
	f32 red_dragon_health = getRules().get_f32("red_dragon_health");
	this.server_SetHealth(red_dragon_health);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
}

//movement
void onInit( CMovement@ this )
{
	//this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags = 0;
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
	Vec2f vel = blob.getVelocity();
	if (left) {
		blob.AddForce(Vec2f( -1.0f * vars.walkForce.x, vars.walkForce.y));
		if (XORRandom(3)==0)
		blob.AddForce(Vec2f( vars.jumpForce.x, vars.jumpForce.y));
				
	}
	if (right) {
		blob.AddForce(Vec2f( 1.0f * vars.walkForce.x, vars.walkForce.y));
		if (XORRandom(3)==0)
		blob.AddForce(Vec2f( vars.jumpForce.x, vars.jumpForce.y));
				
	}
	//Swoop down if has target and or just fly
	if (blob.hasTag(chomp_tag))
	{
		if (XORRandom(100)==0)
		{
			blob.AddForce(Vec2f( -vars.jumpForce.x, -vars.jumpForce.y));
		}
		else
		{
			if (XORRandom(20)==0)
			{
				if (right) {
					blob.AddForce(Vec2f( -vars.walkForce.x, vars.walkForce.y));
					if (XORRandom(2)==0)
					blob.AddForce(Vec2f( vars.jumpForce.x, vars.jumpForce.y));	
				}
				if (left) {
					blob.AddForce(Vec2f( vars.walkForce.x, vars.walkForce.y));
					if (XORRandom(2)==0)
					blob.AddForce(Vec2f( vars.jumpForce.x, vars.jumpForce.y));	
				}
			}
		}
	}
		Vec2f pos = blob.getPosition();
		CMap@ map = blob.getMap();
		const f32 radius = blob.getRadius();
		
		f32 x = pos.x;
		Vec2f top = Vec2f(x, map.tilesize);
		Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
		Vec2f end;
		f32 y = end.y;

	// jump if blocked
	s32 flymod = blob.get_s32("flymod");
	if ((flymod < 15 && !down) || blob.hasAttached()) up=true;
	if ((left || right || up) && !down)
	{
		if (map.rayCastSolid(top,bottom,end))
		{	
			
			if (y-pos.y<300 || blob.hasAttached())
			{
				if ((flymod < 22 || blob.isInWater()) && (up || (right && map.isTileSolid( Vec2f( pos.x + (radius+1.0f)-XORRandom(150.0f), pos.y ))) || (left && map.isTileSolid( Vec2f( pos.x - (radius+1.0f)-XORRandom(150.0f), pos.y )))))
				{ 
					f32 mod = blob.isInWater() ? 0.23f : 3.0f;
					blob.AddForce(Vec2f( mod*vars.jumpForce.x, mod*vars.jumpForce.y));
				}
			}
		}
	}
	flymod++;
	if (flymod>22) flymod=0;
	blob.set_s32("flymod",flymod);
	CShape@ shape = blob.getShape();	

	
	// too fast - slow down
	if (shape.vellen > vars.maxVelocity && !blob.hasTag(chomp_tag))
	{		  
		Vec2f vel = blob.getVelocity();
		blob.AddForce( Vec2f(-vel.x * vars.slowForce.x, -vel.y * vars.slowForce.y) );
	}
}

