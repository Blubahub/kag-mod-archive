void onInit( CBlob@ this )
{
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ effectInvis = sprite.addSpriteLayer( "effectInvis", "BF_EffectInvis.png", 16, 16);
    if (effectInvis !is null)
    {
        effectInvis.addAnimation( "effectInvis", 3, false );
        int[] frames = {0,1,2,3,4,5,6};
        effectInvis.animation.AddFrames(frames);
        effectInvis.SetOffset(Vec2f(0,-4));
        effectInvis.SetRelativeZ(1.0f);
    }
}

void onTick( CBlob@ this )
{
	u16 effectTime = this.get_u16( "invisibilityEffectTime" );
	if ( getGameTime() < effectTime )
		this.SetVisible( false );
	else
	{
        this.getSprite().RemoveSpriteLayer("effectInvis");
		this.SetVisible( true );
		ScriptData@ script = this.getCurrentScript();
		if ( script !is null )//script is null in some weird instances
			script.runFlags |= Script::remove_after_this;
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if ( blob.hasTag( "mutant" ) )
		return false;
	
	return true;
}