void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
    CSpriteLayer@ healEffect = sprite.addSpriteLayer( "healEffect", "HealEffect.png", 32, 32);
    if (healEffect !is null)
    {
        healEffect.addAnimation( "healEffect", 3, true );
        int[] frames = {0,1,2,3,4,5,6,7};
        healEffect.animation.AddFrames(frames);
        healEffect.SetOffset(Vec2f(2,2));
        healEffect.SetRelativeZ(1.0f);
    }
    this.set_u16("healEffectTime", getGameTime() + 21);
}


void onTick( CBlob@ this )
{
	if ( getGameTime() > this.get_u16("healEffectTime") )
	{
		this.getSprite().RemoveSpriteLayer("healEffect");
		ScriptData@ script = this.getCurrentScript();
		if ( script !is null )
			script.runFlags |= Script::remove_after_this;
	}
}