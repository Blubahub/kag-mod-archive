
//if we were unable to hit something, fleck some sparks off it and play a ding sound.

#include "ParticleSparks.as";

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (damage <= 0.0f && hitBlob.getTeamNum() != this.getTeamNum() &&
		!hitBlob.hasTag("flesh") && !hitBlob.hasTag("material"))
	{
		Vec2f pos = worldPoint;
		
		Sound::Play( "Sounds/dry_hit.ogg", pos );
        sparks (pos, -velocity.Angle(), 0.1f);
	}
}
