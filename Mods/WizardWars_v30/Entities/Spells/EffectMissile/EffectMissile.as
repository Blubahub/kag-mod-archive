#include "/Entities/Common/Attacks/Hitters.as";	   
#include "/Entities/Common/Attacks/LimitedAttacks.as";
#include "SpellCommon.as";

const int LIFETIME = 4;
const int EXTENDED_LIFETIME = 6;
const f32 SEARCH_RADIUS = 64.0f;
const f32 HOMING_FACTOR = 6.0f;
const int HOMING_DELAY = 15;	

const int INIT_DELAY = 2;	//prevents initial seg pos to be at (0,0)
const int TRAIL_SEGMENTS = 20;
const f32 TICKS_PER_SEG_UPDATE = 4;
const f32 SEG_FOLLOW_FACTOR = 0.5f; //unused
const f32 TRAIL_WIDTH = 1.0f;

void onInit( CBlob @ this )
{
	this.Tag("phase through spells");
	this.Tag("counterable");
	
    //this.server_setTeamNum(1);
	this.Tag("medium weight");

	CShape@ shape = this.getShape();
	shape.SetGravityScale( 0.0f );
	shape.getConsts().bullet = true;
	shape.SetRotationsAllowed(false);
	
    //burning sound	    
	CSprite@ thisSprite = this.getSprite();
	thisSprite.getConsts().accurateLighting = false;
	
	this.set_bool("initialized", false);
	this.set_bool("segments updating", false);
	this.set_u32("dead segment", 0);
	
	this.set_bool("target found", false);
	
	this.set_bool("dead", false);
	
	this.set_bool("onCollision triggered", false);
	this.set_netid("onCollision blob", 0);
}

void onTick( CBlob@ this)
{
	CSprite@ thisSprite = this.getSprite();
	Vec2f thisPos = this.getPosition();
	Vec2f thisVel = this.getVelocity();
	
	bool isDead = this.get_bool("dead");
	
	bool onCollisionTriggered = this.get_bool("onCollision triggered");	//used to sync server and client onCollision 
	
	if ( this.get_bool("initialized") == false && this.getTickSinceCreated() > INIT_DELAY )
	{
		this.SetLight(true);
		this.SetLightRadius(24.0f);
		SColor lightColor = SColor( 255, 255, 150, 0);
		this.SetLightColor( lightColor );
		thisSprite.PlaySound("GenericProjectile1.ogg", 0.8f, 1.0f + XORRandom(3)/10.0f);
		thisSprite.SetZ(500.0f);
		
		array<Vec2f> trail_positions(TRAIL_SEGMENTS, this.getPosition());
		this.set("trail positions", trail_positions);
		
		array<Vec2f> trail_vectors;
		for (int i = 0; i < TRAIL_SEGMENTS-1; i++)
		{
			trail_vectors.push_back(trail_positions[i+1] - trail_positions[i]);
		}		
		this.set("trail vectors", trail_vectors);
		
		this.set_bool("initialized", true);
	}
	
	if ( isDead == false )
		sparks(this, thisPos, 1);
	
	//trail effects	
	string trail_file;
	if ( followsEnemies( this ) )
		trail_file = "Trail3.png";
	else
		trail_file = "Trail1.png";
		
	if ( this.getTickSinceCreated() > INIT_DELAY )	//delay to prevent rendering trails leading from map origin
	{
		Vec2f[]@ trail_positions;
		this.get( "trail positions", @trail_positions );
		
		Vec2f[]@ trail_vectors;
		this.get( "trail vectors", @trail_vectors );
		
		if ( trail_positions is null || trail_vectors is null )
			return; 
		
		bool segmentsUpdating = this.get_bool("segments updating");
		f32 ticksTillUpdate = getGameTime() % TICKS_PER_SEG_UPDATE;
		if ( ticksTillUpdate == 0 )
		{
			this.set_bool("segments updating", true);
		}
		
		int lastPosArrayElement = trail_positions.length-1;
		int lastVecArrayElement = trail_vectors.length-1;
		
		if ( segmentsUpdating )
		{				
			trail_positions.push_back(thisPos);
			trail_vectors.push_back(thisPos - trail_positions[lastPosArrayElement]);
			this.set_bool("segments updating", false);
		}
		
		for (int i = 0; i < trail_positions.length; i++)
		{
			thisSprite.RemoveSpriteLayer("trail"+i);
		}
		
		int deadSegment = this.get_u32("dead segment");
		
		if ( !(isDead && lastPosArrayElement > deadSegment ) )
		{
			Vec2f currSegPos = trail_positions[lastPosArrayElement];
			Vec2f followVec = currSegPos - thisPos;
			Vec2f followNorm = followVec;
			followNorm.Normalize();
			
			f32 followDist = followVec.Length();
					
			CSpriteLayer@ trail = thisSprite.addSpriteLayer( "trail" + (lastPosArrayElement), trail_file, 16, 16 );
			if (trail !is null)
			{
				Animation@ anim = trail.addAnimation( "default", 1, true );
				int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
				anim.AddFrames(frames);				
				trail.SetFrameIndex(15 - (getGameTime() % 15));
				
				trail.SetVisible(true);
				
				f32 trailLength = (followDist+1.0f) / 16.0f;				
				trail.ResetTransform();						
				trail.ScaleBy( Vec2f(trailLength,
					TRAIL_WIDTH*((TICKS_PER_SEG_UPDATE-ticksTillUpdate*(1.0f/TRAIL_SEGMENTS))/TICKS_PER_SEG_UPDATE)) );							
				trail.TranslateBy( Vec2f(trailLength*8.0f, 0.0f) );							
				trail.RotateBy( -followNorm.Angle(), Vec2f());
				trail.setRenderStyle(RenderStyle::light);
				trail.SetRelativeZ(-1);
			}
		}
		
		if ( !(isDead && (lastPosArrayElement-1) > deadSegment) )
		{
			Vec2f currSegPos = trail_positions[lastPosArrayElement-1];			
			Vec2f nextSegPos = trail_positions[lastPosArrayElement];
			Vec2f followVec = currSegPos - nextSegPos;
			Vec2f followNorm = followVec;
			followNorm.Normalize();
			
			f32 followDist = followVec.Length();
			
			Vec2f netTranslation = nextSegPos - thisPos;
					
			CSpriteLayer@ trail = thisSprite.addSpriteLayer( "trail" + (lastPosArrayElement-1), trail_file, 16, 16 );
			if (trail !is null)
			{
				Animation@ anim = trail.addAnimation( "default", 1, true );
				int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
				anim.AddFrames(frames);				
				trail.SetFrameIndex(15 - (getGameTime() % 15)); 
				
				trail.SetVisible(true);
				
				f32 trailLength = (followDist+1.0f) / 16.0f;						
				trail.ResetTransform();							
				trail.ScaleBy( Vec2f(trailLength,
					TRAIL_WIDTH*((TRAIL_SEGMENTS-1.0f)/TRAIL_SEGMENTS)
					*((TICKS_PER_SEG_UPDATE-ticksTillUpdate*(1.0f/TRAIL_SEGMENTS))/TICKS_PER_SEG_UPDATE)) );							
				trail.TranslateBy( Vec2f(trailLength*8.0f, 0.0f) );							
				trail.RotateBy( -followNorm.Angle(), Vec2f());
				trail.TranslateBy( netTranslation );
				trail.setRenderStyle(RenderStyle::light);
				trail.SetRelativeZ(-1);
			}
		}
		
		for (int i = trail_positions.length - TRAIL_SEGMENTS; i < lastVecArrayElement; i++)
		{
			if ( isDead && i > deadSegment )
				continue;
		
			Vec2f currSegPos = trail_positions[i];				
			Vec2f prevSegPos = trail_positions[i+1];
			Vec2f followVec = currSegPos - prevSegPos;
			Vec2f followNorm = followVec;
			followNorm.Normalize();
			
			f32 followDist = followVec.Length();
			
			Vec2f netTranslation = Vec2f(0,0);
			for (int t = i+1; t < lastVecArrayElement; t++)
			{	
				netTranslation = netTranslation - trail_vectors[t]; 
			}
			
			Vec2f movementOffset = trail_positions[lastPosArrayElement-1] - thisPos;
					
			CSpriteLayer@ trail = thisSprite.addSpriteLayer( "trail"+i, trail_file, 16, 16 );
			if (trail !is null)
			{
				Animation@ anim = trail.addAnimation( "default", 1, true );
				int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
				anim.AddFrames(frames);				
				trail.SetFrameIndex(15 - (getGameTime() % 15));
				
				trail.SetVisible(true);
				
				f32 trailLength = (followDist+1.0f) / 16.0f;					
				trail.ResetTransform();			
				trail.ScaleBy( Vec2f(trailLength,
					TRAIL_WIDTH*((i*1.0f-(trail_positions.length-TRAIL_SEGMENTS))/TRAIL_SEGMENTS)
					*((TICKS_PER_SEG_UPDATE-ticksTillUpdate*(1.0f/TRAIL_SEGMENTS))/TICKS_PER_SEG_UPDATE)) );	
				trail.TranslateBy( Vec2f(trailLength*8.0f, 0.0f) );	
				trail.RotateBy( -followNorm.Angle(), Vec2f() );	
				trail.TranslateBy( netTranslation + movementOffset );	
				trail.setRenderStyle(RenderStyle::light);
				trail.SetRelativeZ(-1);
			}
		}
	}
	
	//face towards target like a ballista bolt
	f32 angle = thisVel.Angle();	
	thisSprite.ResetTransform();
	thisSprite.RotateBy( -angle, Vec2f(0,0) );
	
	//makeSmokePuff(this);
	
	//targetting 
	if ( this.getTickSinceCreated() > HOMING_DELAY )
	{	
		// try to find player target	
		CBlob@ target = getBlobByNetworkID(this.get_netid("target"));
		if ( target is null )
		{
			CBlob@[] blobs;
			this.getMap().getBlobsInRadius( thisPos, SEARCH_RADIUS, @blobs );
			f32 best_dist = 99999999;
			for (uint step = 0; step < blobs.length; ++step)
			{
				//TODO: sort on proximity? done by engine?
				CBlob@ other = blobs[step];

				if (other is this) continue; //lets not run away from / try to eat ourselves...
				
				//TODO: flags for these...
				if ( followsAllies(this) )
				{		
					if (other.getTeamNum() == this.getTeamNum() && !isOwnerBlob(this, other) && other.hasTag("player") && !other.hasTag("dead")) //home in on living allies
					{
						Vec2f tpos = other.getPosition();									  
						f32 dist = (tpos - thisPos).getLength();
						if (dist < best_dist)
						{
							this.set_netid("target", other.getNetworkID());
							best_dist=dist;
							this.getShape().setDrag(2.0f);
						}
					}
				}
				else if ( followsDeadAllies(this) )
				{		
					if (other.getTeamNum() == this.getTeamNum() && other.hasTag("gravestone") ) //home in on gravestones
					{
						Vec2f tpos = other.getPosition();									  
						f32 dist = (tpos - thisPos).getLength();
						if (dist < best_dist)
						{
							this.set_netid("target", other.getNetworkID());
							best_dist=dist;
							this.getShape().setDrag(2.0f);
						}
					}
				}
				else	//follow enemies
				{
					if (other.getTeamNum() != this.getTeamNum() && other.hasTag("player") && !other.hasTag("dead")) //home in on enemies
					{
						Vec2f tpos = other.getPosition();									  
						f32 dist = (tpos - thisPos).getLength();
						if (dist < best_dist)
						{
							this.set_netid("target", other.getNetworkID());
							best_dist=dist;
							this.getShape().setDrag(2.0f);
						}
					}
				}
			}
		}
		else
		{
			this.set_bool("target found", true);
		
			Vec2f tpos = target.getPosition();
			Vec2f targetNorm = tpos - thisPos;
			targetNorm.Normalize();
			
			this.AddForce( targetNorm*HOMING_FACTOR );
		}
	}
	
	//delayed death
	if ( !isDead )
	{
		if ( this.get_bool("target found") && this.getTickSinceCreated() > (LIFETIME + EXTENDED_LIFETIME)*30 )
		{
			Die( this );
		}
		else if ( !this.get_bool("target found") && this.getTickSinceCreated() > LIFETIME*30 )
		{
			Die( this );
		}
	}
	
	//activate onCollision events
	if ( onCollisionTriggered == true && !isDead )
	{
		CBlob@ blob = getBlobByNetworkID( this.get_netid("onCollision blob") );
		
		if ( blob !is null )
		{	
			string effectType = this.get_string("effect");
			
			if (blob.hasTag("player") && !blob.hasTag("dead"))
			{	
				if ( !isEnemy(this, blob) && followsAllies( this ) && !isOwnerBlob(this, blob) )	//buff status effects
				{
					if ( effectType == "heal" )
						Heal(blob, this.get_f32("heal_amount"));
					else if ( effectType == "haste" )
						Haste(blob, this.get_u16("haste_time"));
						
					Die( this );
				}
				else if ( isEnemy(this, blob) && followsEnemies( this ) )	//curse status effects
				{
					if ( effectType == "slow" )
						Slow(blob, this.get_u16("slow_time"));
						
					Die( this );
				}
			}
			else if ( blob.getName() == "gravestone" && blob.getTeamNum() == this.getTeamNum() && followsDeadAllies( this ) )	//ally revive spells
			{
				if ( effectType == "revive" )
					Revive(blob);
					
				if ( effectType == "unholy_res" )
					UnholyRes(blob);
					
				Die( this );
			}
			
			this.set_bool("onCollision triggered", false);
		}
	}
}

bool followsAllies( CBlob@ this )
{		
	string effectType = this.get_string("effect");
	
	return ( effectType == "heal" || effectType == "haste" );
}

bool followsEnemies( CBlob@ this )
{		
	string effectType = this.get_string("effect");
	
	return ( effectType == "slow" );
}

bool followsDeadAllies( CBlob@ this )
{		
	string effectType = this.get_string("effect");
	
	return ( effectType == "revive" || effectType == "unholy_res" );
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{	
	if ( blob is null )
		return;
		
	this.set_bool("onCollision triggered", true);
	this.set_netid("onCollision blob", blob.getNetworkID());
	
	this.Sync("onCollision triggered", true);
	this.Sync("onCollision blob", true);
}

void Die(CBlob@ this)
{
	Vec2f[]@ trail_positions;
	if ( this.get( "trail positions", @trail_positions ) )
		this.set_u32("dead segment", trail_positions.length - 1);

	this.shape.SetStatic(true);
	this.getSprite().SetVisible(false);
	
	this.server_SetTimeToDie(3);	
	
	this.set_bool("dead", true);
}

bool isOwnerBlob(CBlob@ this, CBlob@ target)
{
	if ( target is null )
		return true;

	//easy check
	if (this.getDamageOwnerPlayer() is target.getPlayer())
		return true;

	if (!this.exists("explosive_parent")) { return false; }

	return (target.getNetworkID() == this.get_u16("explosive_parent"));
}

bool isEnemy( CBlob@ this, CBlob@ target )
{
	CBlob@ friend = getBlobByNetworkID(target.get_netid("brain_friend_id"));
	return (
		target.hasTag("flesh") 
		&& !target.hasTag("dead") 
		&& target.getTeamNum() != this.getTeamNum() 
		&& (friend is null
			|| friend.getTeamNum() != this.getTeamNum()
		)
	);
}

void makeSmokeParticle(CBlob@ this, const Vec2f vel, const string filename = "Smoke")
{
	if(!getNet().isClient()) 
		return;
	//warn("making smoke");

	const f32 rad = 2.0f;
	Vec2f random = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
	CParticle@ p = ParticleAnimated( "MissileFire1.png", this.getPosition() + random, Vec2f(0,0), float(XORRandom(360)), 1.0f, 2, 0.0f, false );
	if ( p !is null)
	{
		p.Z = 300.0f;
	}
	
	//warn("smoke made");
}

void makeSmokePuff(CBlob@ this, const f32 velocity = 1.0f, const int smallparticles = 10, const bool sound = true)
{

	//makeSmokeParticle(this, Vec2f(), "Smoke");
	//for (int i = 0; i < smallparticles; i++)
	{
		f32 randomness = (XORRandom(32) + 32)*0.015625f * 0.5f + 0.75f;
		Vec2f vel = getRandomVelocity( -90, velocity * randomness, 360.0f );
		makeSmokeParticle(this, vel);
	}
}

Random _sprk_r;
void sparks(CBlob@ this, Vec2f pos, int amount)
{
	if ( !getNet().isClient() )
		return;

	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 0.5f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);
		
		int colorShade = 255 - _sprk_r.NextRanged(128);
		CParticle@ p;
		if ( followsAllies( this ) )
		{
			CParticle@ p = ParticlePixel( pos, vel, SColor( 255, colorShade, colorShade, colorShade ), true );
			if(p !is null) //bail if we stop getting particles
			{
				p.timeout = 40 + _sprk_r.NextRanged(20);
				p.scale = 0.5f + _sprk_r.NextFloat();
				p.damping = 0.95f;
				p.gravity = Vec2f(0,0);
			}
		}
		else if ( followsEnemies( this ) )
		{
			CParticle@ p = ParticlePixel( pos, vel, SColor( 255, colorShade, colorShade, 0 ), true );
			if(p !is null) //bail if we stop getting particles
			{
				p.timeout = 40 + _sprk_r.NextRanged(20);
				p.scale = 0.5f + _sprk_r.NextFloat();
				p.damping = 0.95f;
				p.gravity = Vec2f(0,0);
			}
		}
    }
}

