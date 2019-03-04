#include "HittersTC.as"

//Does the good old "red screen flash" when hit - put just before your script that actually does the hitting

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (this.isMyPlayer() && damage > 0)
    {
		switch (customData)
		{
			case HittersTC::radiation:
				SetScreenFlash(25, 50, 255, 125);
				break;
		
			case HittersTC::forcefield:
			case HittersTC::electric:
				SetScreenFlash(200, 255, 255, 255);
				break;
		
			default:
				SetScreenFlash(90, 120, 0, 0);
				break;
		}
		
        ShakeScreen(9, 2, this.getPosition());
    }

    return damage;
}