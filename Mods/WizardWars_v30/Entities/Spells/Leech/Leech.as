#include "/Entities/Common/Attacks/Hitters.as";	   
#include "/Entities/Common/Attacks/LimitedAttacks.as";
#include "SpellCommon.as";

const f32 RANGE = 180.0f;
const f32 DAMAGE = 2.0f;

const f32 LIFETIME = 0.5f;

const int MAX_LASER_POSITIONS = 20;
const int LASER_UPDATE_TIME = 10;

const f32 TICKS_PER_SEG_UPDATE = 1;
const f32 LASER_WIDTH = 0.5f;

Random _laser_r;

void onInit( CBlob @ this )
{
	this.Tag("phase through spells");

	//dont collide with edge of the map
	this.SetMapEdgeFlags( u8(CBlob::map_collide_none) | u8(CBlob::map_collide_nodeath) );
	
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	shape.SetGravityScale( 0.0f );
	shape.SetRotationsAllowed(false);
	  
	CSprite@ thisSprite = this.getSprite();
	thisSprite.getConsts().accurateLighting = false;
	thisSprite.PlaySound("EnergyBolt1.ogg", 2.0f, 1.0f + XORRandom(5)/10.0f);
	
	this.set_bool("initialized", false);
	
	this.server_SetTimeToDie(LIFETIME);
}

void setPositionToOwner(CBlob@ this)
{
	CPlayer@ ownerPlayer = this.getDamageOwnerPlayer();
	if ( ownerPlayer !is null )
	{
		CBlob@ ownerBlob = ownerPlayer.getBlob();
		if ( ownerBlob !is null )
			this.setPosition( ownerBlob.getPosition() );
	}
}

void updateLaserPositions(CBlob@ this)
{
	Vec2f thisPos = this.getPosition();
	
	Vec2f aimPos = this.get_Vec2f("aim pos");
	Vec2f aimVec = aimPos - thisPos;
	Vec2f aimNorm = aimVec;
	aimNorm.Normalize();
	
	Vec2f destination = aimPos;
	
	Vec2f shootVec = destination-thisPos;
	
	Vec2f normal = (Vec2f(aimVec.y, -aimVec.x));
	normal.Normalize();
	
	array<Vec2f> laser_positions;
	
	float[] positions;
	positions.push_back(0);
	for (int i = 0; i < MAX_LASER_POSITIONS; i++)
	{
		positions.push_back( _laser_r.NextFloat() );
	}		
	positions.sortAsc();
	
	const f32 sway = 10.0f;
	const f32 jaggedness = 1.0f/(2.0f*sway);
	
	Vec2f prevPoint = thisPos;
	f32 prevDisplacement = 0.0f;
	for (int i = 1; i < positions.length; i++)
	{
		float pos = positions[i];
 
		// used to prevent sharp angles by ensuring very close positions also have small perpendicular variation.
		float scale = (shootVec.Length() * jaggedness) * (pos - positions[i - 1]);
 
		// defines an envelope. Points near the middle of the bolt can be further from the central line.
		float envelope = pos > 0.95f ? 20 * (1 - pos) : 1;
 
		float displacement = _laser_r.NextFloat()*sway*2.0f - sway;
		displacement -= (displacement - prevDisplacement) * (1 - scale);
		displacement *= envelope;
 
		Vec2f point = thisPos + shootVec*pos + normal*displacement;
		
		laser_positions.push_back(prevPoint);
		prevPoint = point;
		prevDisplacement = displacement;
	}
	laser_positions.push_back(destination);
	
	this.set("laser positions", laser_positions);
	
	array<Vec2f> laser_vectors;
	for (int i = 0; i < laser_positions.length-1; i++)
	{
		laser_vectors.push_back(laser_positions[i+1] - laser_positions[i]);
	}		
	this.set("laser vectors", laser_vectors);	
}

void onTick( CBlob@ this)
{
	CSprite@ thisSprite = this.getSprite();
	Vec2f thisPos = this.getPosition();
	
	setPositionToOwner(this);
	
	if ( this.get_bool("initialized") == false && this.getTickSinceCreated() > 1 )
	{
		this.SetLight(true);
		this.SetLightRadius(24.0f);
		SColor lightColor = SColor( 255, 255, 150, 0);
		this.SetLightColor( lightColor );
		thisSprite.SetZ(500.0f);
		
		Vec2f aimPos = this.get_Vec2f("aim pos");
		Vec2f aimVec = aimPos - thisPos;
		Vec2f aimNorm = aimVec;
		aimNorm.Normalize();
		
		Vec2f shootVec = aimNorm*RANGE;
		
		Vec2f destination = thisPos+shootVec;
		
		CMap@ map = this.getMap();
		f32 shortestHitDist = 9999.9f;
		HitInfo@[] hitInfos;
		bool hasHit = map.getHitInfosFromRay(thisPos, -aimNorm.getAngle(), RANGE, this, @hitInfos);
		if ( hasHit )
		{
			bool damageDealt = false;
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				
				if (hi.blob !is null) // blob
				{
					if (hi.blob is this || hi.blob.getTeamNum() == this.getTeamNum() || !hi.blob.isCollidable())
					{
						continue;
					}
					else if ( damageDealt == false )
					{
						this.server_Hit(hi.blob, hi.hitpos, Vec2f(0,0), DAMAGE, Hitters::explosion, true);
						
						CPlayer@ ownerPlayer = this.getDamageOwnerPlayer();
						if ( ownerPlayer !is null && hi.blob.getPlayer() !is null )
						{
							CBlob@ ownerBlob = ownerPlayer.getBlob();
							if ( ownerBlob !is null )
								ownerBlob.server_Heal(DAMAGE);
						}
						
						damageDealt = true;
					}
				}
				
				Vec2f hitPos = hi.hitpos;
				f32 distance = hi.distance;
				if ( shortestHitDist > distance )
				{
					shortestHitDist = distance;
					destination = hitPos;
				}
			}
			this.set_Vec2f("aim pos", destination);
		}
		
		Vec2f normal = (Vec2f(aimVec.y, -aimVec.x));
		normal.Normalize();
		
		updateLaserPositions(this);
		
		if ( shortestHitDist < RANGE )
			leechSparks(destination - aimNorm*4.0f, 20);
		
		this.set_bool("initialized", true);
	}
	
	//laser effects	
	if ( this.getTickSinceCreated() > 1 && getGameTime() % TICKS_PER_SEG_UPDATE == 0 )	//delay to prevent rendering lasers leading from map origin
	{
		Vec2f[]@ laser_positions;
		this.get( "laser positions", @laser_positions );
		
		Vec2f[]@ laser_vectors;
		this.get( "laser vectors", @laser_vectors );
		
		if ( laser_positions is null || laser_vectors is null )
			return; 
			
		updateLaserPositions(this);
		
		int laserPositions = laser_positions.length;
		
		f32 ticksTillUpdate = getGameTime() % TICKS_PER_SEG_UPDATE;
		
		int lastPosArrayElement = laser_positions.length-1;
		int lastVecArrayElement = laser_vectors.length-1;
		
		for (int i = 0; i < laser_positions.length; i++)
		{
			thisSprite.RemoveSpriteLayer("laser"+i);
		}
		
		if ( false )
		{
			Vec2f currSegPos = laser_positions[lastPosArrayElement];
			Vec2f followVec = currSegPos - thisPos;
			Vec2f followNorm = followVec;
			followNorm.Normalize();
			
			f32 followDist = followVec.Length();
					
			CSpriteLayer@ laser = thisSprite.addSpriteLayer( "laser" + (lastPosArrayElement), "LeechLaser.png", 16, 16 ); 
			if (laser !is null)
			{
				Animation@ anim = laser.addAnimation( "default", 1, true );
				int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
				anim.AddFrames(frames);				
				laser.SetFrameIndex(15 - (getGameTime() % 15));
				
				laser.SetVisible(true);
				
				f32 laserLength = (followDist+1.0f) / 16.0f;				
				laser.ResetTransform();						
				laser.ScaleBy( Vec2f(laserLength, LASER_WIDTH) );							
				laser.TranslateBy( Vec2f(laserLength*8.0f, 0.0f) );							
				laser.RotateBy( -followNorm.Angle(), Vec2f());
				laser.setRenderStyle(RenderStyle::additive);
				laser.SetRelativeZ(1);
			}
		}
		
		if ( true )
		{
			Vec2f currSegPos = laser_positions[lastPosArrayElement-1];			
			Vec2f nextSegPos = laser_positions[lastPosArrayElement];
			Vec2f followVec = currSegPos - nextSegPos;
			Vec2f followNorm = followVec;
			followNorm.Normalize();
			
			f32 followDist = followVec.Length();
			
			Vec2f netTranslation = nextSegPos - thisPos;
					
			CSpriteLayer@ laser = thisSprite.addSpriteLayer( "laser" + (lastPosArrayElement-1), "LeechLaser.png", 16, 16 );
			if (laser !is null)
			{
				Animation@ anim = laser.addAnimation( "default", 1, true );
				int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
				anim.AddFrames(frames);				
				laser.SetFrameIndex(15 - (getGameTime() % 15)); 
				
				laser.SetVisible(true);
				
				f32 laserLength = (followDist+1.0f) / 16.0f;						
				laser.ResetTransform();							
				laser.ScaleBy( Vec2f(laserLength, LASER_WIDTH) );							
				laser.TranslateBy( Vec2f(laserLength*8.0f, 0.0f) );							
				laser.RotateBy( -followNorm.Angle(), Vec2f());
				laser.TranslateBy( netTranslation );
				laser.setRenderStyle(RenderStyle::additive);
				laser.SetRelativeZ(1);
			}
		}
		
		for (int i = laser_positions.length - laserPositions; i < lastVecArrayElement; i++)
		{
			Vec2f currSegPos = laser_positions[i];				
			Vec2f prevSegPos = laser_positions[i+1];
			Vec2f followVec = currSegPos - prevSegPos;
			Vec2f followNorm = followVec;
			followNorm.Normalize();
			
			f32 followDist = followVec.Length();
			
			Vec2f netTranslation = Vec2f(0,0);
			for (int t = i+1; t < lastVecArrayElement; t++)
			{	
				netTranslation = netTranslation - laser_vectors[t]; 
			}
			
			Vec2f movementOffset = laser_positions[lastPosArrayElement-1] - thisPos;
					
			CSpriteLayer@ laser = thisSprite.addSpriteLayer( "laser"+i, "LeechLaser.png", 16, 16 );
			if (laser !is null)
			{
				Animation@ anim = laser.addAnimation( "default", 1, true );
				int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
				anim.AddFrames(frames);				
				laser.SetFrameIndex(15 - (getGameTime() % 15));
				
				laser.SetVisible(true);
				
				f32 laserLength = (followDist+1.0f) / 16.0f;					
				laser.ResetTransform();			
				laser.ScaleBy( Vec2f(laserLength, LASER_WIDTH) );	
				laser.TranslateBy( Vec2f(laserLength*8.0f, 0.0f) );	
				laser.RotateBy( -followNorm.Angle(), Vec2f() );	
				laser.TranslateBy( netTranslation + movementOffset );	
				laser.setRenderStyle(RenderStyle::additive);
				laser.SetRelativeZ(1);
			}
		}
	}
}

Random _sprk_r;
void leechSparks(Vec2f pos, int amount)
{
	if ( !getNet().isClient() )
		return;
		
	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 4.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        CParticle@ p = ParticlePixel( pos, vel, SColor( 255, 255, 128+_sprk_r.NextRanged(128), _sprk_r.NextRanged(128)), true );
        if(p is null) return; //bail if we stop getting particles

        p.timeout = 20 + _sprk_r.NextRanged(20);
        p.scale = 1.0f + _sprk_r.NextFloat();
        p.damping = 0.95f;
    }
}