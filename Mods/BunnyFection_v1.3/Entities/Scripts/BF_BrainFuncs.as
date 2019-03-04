//BF_BrainFuncs
#include "BrainCommon.as";

f32 DEF_SEARCH_RADIUS = 240.0f;

CBlob@ bf_getNewTarget( CBrain@ this, CBlob @blob, const bool seeThroughWalls = false, const bool seeBehindBack = false, bool targetFlesh = true, f32 radius = DEF_SEARCH_RADIUS )
{
	//print( "::::looking for new target" );
	
	CBlob@[] potentialTargets;
	Vec2f pos = blob.getPosition();

	//cycle through nearby blobs
	getMap().getBlobsInRadius( pos, radius, @potentialTargets );
	u8 pTargetsNum = potentialTargets.length();
	if ( pTargetsNum == 0 )		return null;
	
	CBlob@ bestTarget;
	f32 minDistance = radius;
	for ( uint i = 0; i < pTargetsNum; i++ )
	{
		CBlob@ potential = potentialTargets[i];	
		
		if ( potential is null || ( potential.hasTag( "flesh" ) && !targetFlesh ) )
			continue;

		Vec2f pos2 = potential.getPosition();
		u8 potentialTeam = potential.getTeamNum();
		u8 blobTeam = blob.getTeamNum();
		//print( "Potential: " + potential.getName() +" (" + potentialTeam + ")" );
		// diff team, in range, ( see behind Or closeBy ) || in front, see through walls || isVisible, not dead

		if (potential !is blob && potentialTeam != blobTeam && ( potentialTeam != 255 || ( blobTeam == 1 && potential.hasTag( "fauna" ) ) )
			&& ( seeBehindBack || (blob.isFacingLeft() && pos.x > pos2.x) ||  (!blob.isFacingLeft() && pos.x < pos2.x)) 
			&& ( seeThroughWalls || isVisible(blob, potential) || potential.hasTag( "block" ) )
			&& !potential.hasTag( "dead" ) && !potential.hasTag( "flora" ) && !potential.hasTag( "material" ) && potential.getSprite().isVisible()
			)
		{	
			f32 dist = ( pos2 - pos ).Length();
			//special consideration to player blobs/fleshblobs
			if ( potential.hasTag( "player" ) )
				dist *= 0.85f;
			else if( potential.hasTag( "flesh" ) )
				dist*= 0.95f;
			
			if ( dist < minDistance )
			{
				minDistance = dist;
				@bestTarget = potential;
			}			
		}
	}
	
	if ( bestTarget is null )
		return null;

	blob.set_Vec2f("last pathing pos", bestTarget.getPosition() );
	//print( "found TARGET: " + bestTarget.getName() );
	return bestTarget;
}

void bf_SearchTarget( CBrain@ this, const bool seeThroughWalls = false, const bool seeBehindBack = true, bool targetFlesh = true, f32 radius = DEF_SEARCH_RADIUS )
{
	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// search target if none
	if (target is null)
	{
		@target = bf_getNewTarget(this, blob, seeThroughWalls, seeBehindBack, targetFlesh, radius );
		this.SetTarget( target );
	}
}	   

void bf_Chase( CBlob@ blob, CBlob@ target )
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	blob.setAimPos( targetPos );
	blob.setKeyPressed( key_left, false );
	blob.setKeyPressed( key_right, false );
	if ( Maths::Abs( targetPos.x - mypos.x ) > 3.0f  )
		if (targetPos.x < mypos.x)
			blob.setKeyPressed( key_left, true );
		else
			blob.setKeyPressed( key_right, true );

	if ( blob.isInWater() && mypos.y < targetPos.y + getMap().tilesize/2 )
		blob.setKeyPressed( key_down, true );
	else	if ( mypos.y > targetPos.y + getMap().tilesize/2 )
		blob.setKeyPressed( key_up, true );
}

void Swarm( CBlob@ blob, CBlob@ target )
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	blob.setAimPos( targetPos );
	blob.setKeyPressed( key_left, false );
	blob.setKeyPressed( key_right, false );
	if (targetPos.x + XORRandom( 32 ) - 16 < mypos.x)
		blob.setKeyPressed( key_left, true );
	else
		blob.setKeyPressed( key_right, true );

	if (targetPos.y + getMap().tilesize + 10 < mypos.y) {
		blob.setKeyPressed( key_up, true );
	}
	else
		blob.setKeyPressed( key_down, true );
}

bool bf_isVisible( CBlob@blob, CBlob@ target)//more lax
{
	CMap@ map = getMap();
	Vec2f blobPos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	
	return !map.rayCastSolidNoBlobs( blobPos, targetPos ) || !map.rayCastSolidNoBlobs( blobPos + Vec2f( 0.0f, -map.tilesize ), targetPos ) || !map.rayCastSolidNoBlobs( blobPos + Vec2f( 0.0f, map.tilesize ), targetPos );
}