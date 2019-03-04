#include "RunnerCommon.as";

void onInit( CBlob@ this )
{
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ effectSpeed = sprite.addSpriteLayer( "effectSpeed", "BF_EffectSpeed.png", 16, 16);
    if (effectSpeed !is null)
    {
        effectSpeed.addAnimation( "effectSpeed", 3, false );
        int[] frames = {0,1,2,3,4,5,6};
        effectSpeed.animation.AddFrames(frames);
        effectSpeed.SetOffset(Vec2f(0,-4));
        effectSpeed.SetRelativeZ(1.0f);
    }
}


void onTick( CBlob@ this )
{
	u16 effectTime = this.get_u16( "speedEffectTime" );
	if ( getGameTime() < effectTime )
	{
		RunnerMoveVars@ moveVars;
		if ( this.get( "moveVars", @moveVars ) )
		{
			moveVars.walkFactor *= 1.5f;
			moveVars.jumpFactor *= 1.65f;
		}
	}
	else
    {
        this.getSprite().RemoveSpriteLayer("effectSpeed");
		ScriptData@ script = this.getCurrentScript();
		if ( script !is null )//script is null in some weird instances
			script.runFlags |= Script::remove_after_this;
    }
}