//SSBG_BrainFuncs
#include "BrainCommon.as";

f32 DEF_SEARCH_RADIUS = 240.0f;

CBlob@ bf_getNewTarget( CBrain@ this, CBlob @blob, const bool seeThroughWalls = false, const bool seeBehindBack = false, f32 radius = DEF_SEARCH_RADIUS )
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
		
		if ( potential is null )
			continue;

		Vec2f pos2 = potential.getPosition();
		u8 potentialTeam = potential.getTeamNum();
		u8 blobTeam = blob.getTeamNum();
		//print( "Potential: " + potential.getName() +" (" + potentialTeam + ")" );
		// diff team, in range, ( see behind Or closeBy ) || in front, see through walls || isVisible, not dead
		if (potential !is blob && potentialTeam != blobTeam && ( potentialTeam != 255 || ( blobTeam == 1 && potential.hasTag( "fauna" ) ) )/*ToDo: make a decent check!*/
			&& ( seeBehindBack || (blob.isFacingLeft() && pos.x > pos2.x) ||  (!blob.isFacingLeft() && pos.x < pos2.x)) 
			&& ( seeThroughWalls || isVisible(blob, potential) || potential.hasTag( "block" ) )
			&& !potential.hasTag( "dead" ) && !potential.hasTag( "flora" ) && !potential.hasTag( "material" ) && potential.getSprite().isVisible()
			)
		{	
			f32 dist = ( pos2 - pos ).Length();
			//special consideration to player blobs/fleshblobs
			if ( potential.hasTag( "player" ) )
				dist *= 0.01f;
			else if( potential.hasTag( "flesh" ) )
				dist*= 0.02f;
			
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

void ssbg_SearchTarget( CBrain@ this, const bool seeThroughWalls = false, const bool seeBehindBack = true, f32 radius = DEF_SEARCH_RADIUS )
{
	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// search target if none
	if (target is null)
	{
		@target = bf_getNewTarget(this, blob, seeThroughWalls, seeBehindBack, radius);
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

	if (targetPos.y + getMap().tilesize < mypos.y) {
		blob.setKeyPressed( key_up, true );
	}
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
}

bool bf_isVisible( CBlob@blob, CBlob@ target)//also 'looks' from one tile above
{
	Vec2f col;
	return !getMap().rayCastSolid( blob.getPosition(), target.getPosition(), col );
}
