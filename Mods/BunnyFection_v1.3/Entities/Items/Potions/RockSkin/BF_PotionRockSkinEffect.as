void onInit( CBlob@ this )
{
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ effectRock = sprite.addSpriteLayer( "effectRock", "BF_EffectRock.png", 16, 16);
    if (effectRock !is null)
    {
        effectRock.addAnimation( "effectRock", 3, false );
        int[] frames = {0,1,2,3,4,5,6};
        effectRock.animation.AddFrames(frames);
        effectRock.SetOffset(Vec2f(0,-4));
        effectRock.SetRelativeZ(1.0f);
    }
}

void onTick( CBlob@ this )
{
    u16 effectTime = this.get_u16( "rockSkinEffectTime" );
    if ( getGameTime() > effectTime )
    {
        this.getSprite().RemoveSpriteLayer("effectRock");
		ScriptData@ script = this.getCurrentScript();
		if ( script !is null )//script is null in some weird instances
			script.runFlags |= Script::remove_after_this;
    }
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	f32 currentHealth = this.getHealth();
	if ( currentHealth < oldHealth )//took damage
		this.server_Heal( ( oldHealth - currentHealth ) * 0.65 );
}