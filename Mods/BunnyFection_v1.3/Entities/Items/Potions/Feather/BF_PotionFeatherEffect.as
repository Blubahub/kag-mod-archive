#include "RunnerCommon.as";

void onInit( CBlob@ this )
{
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ effectFeather = sprite.addSpriteLayer( "effectFeather", "BF_EffectFeather.png", 16, 16);
    if (effectFeather !is null)
    {
        effectFeather.addAnimation( "effectFeather", 3, false );
        int[] frames = {0,1,2,3,4,5,6};
        effectFeather.animation.AddFrames(frames);
        effectFeather.SetOffset(Vec2f(0,-4));
        effectFeather.SetRelativeZ(1.0f);
    }
}

void onTick( CBlob@ this )
{
    const bool inair = (!this.isOnGround() && !this.isOnLadder());
    u16 effectTime = this.get_u16( "featherEffectTime" );
    if ( getGameTime() < effectTime )
    {
        RunnerMoveVars@ moveVars;
		
        if ( this.get( "moveVars", @moveVars ) )
            moveVars.jumpFactor *= 2.0f;

		if (inair)
            this.AddForce(Vec2f( 0,-20.0f));
    }
    else
    {
        this.getSprite().RemoveSpriteLayer("effectFeather");
		ScriptData@ script = this.getCurrentScript();
		if ( script !is null )//script is null in some weird instances
			script.runFlags |= Script::remove_after_this;
    }
}