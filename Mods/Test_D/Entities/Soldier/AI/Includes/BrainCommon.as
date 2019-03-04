#include "Consts.as"

namespace Brain
{
	bool isScreenDistance( Vec2f pos, Vec2f targetPos ){
		return ((pos - targetPos).getLength() < Consts::SCREEN_DISTANCE);
	}

	bool isFacing(CBlob@ blob, Vec2f pos)
	{
		Vec2f mypos = blob.getPosition();
		const bool facingleft = blob.isFacingLeft();
		return (pos.x < mypos.x && facingleft) || (pos.x > mypos.x && !facingleft);
	}

	bool isObstacleInFrontOfTarget( Vec2f pos, const bool crouching, Vec2f targetPos, const bool targetCrouching, const f32 radius = Consts::SOLDIER_RADIUS )
	{
		Vec2f col;
		Vec2f crouchOffset( 0.0f, 0.0f );
		Vec2f standOffset( 0.0f, -radius );
		return getMap().rayCastSolid( pos + (crouching ? crouchOffset : standOffset),
		 targetPos + (targetCrouching ? crouchOffset : standOffset), col );
	}

	bool isInLineOfFire( Vec2f pos, Vec2f targetPos )
	{
		const f32 radius = 1.0f + 2.0f*Consts::SOLDIER_RADIUS;
		Vec2f offset = Vec2f(0.0f, -radius*0.5f);
		Vec2f col;
		CMap@ map = getMap();
		return Maths::Abs(targetPos.y - pos.y) <= radius
			   && isScreenDistance( pos, targetPos )
			   && (!map.rayCastSolid( pos, targetPos, col)
			   		|| !map.rayCastSolid( pos + offset, targetPos + offset, col));
	}
}