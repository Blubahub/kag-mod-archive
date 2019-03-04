const f32 interval = 1*30;
const f32 damage = 0.5f;

void onInit( CBlob@ this )
{
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ corruptionEffect = sprite.addSpriteLayer( "corruption", "RunnerCorruption.png", 16, 16);
    if (corruptionEffect !is null)
    {
        corruptionEffect.addAnimation( "corruption", 3, true );
        int[] frames = {1,2,3,4,5,6};
        corruptionEffect.animation.AddFrames(frames);
        corruptionEffect.SetOffset(Vec2f(0,0));
        corruptionEffect.SetRelativeZ(1.0f);
    }
    this.set_u16("corrupt_time", getGameTime() + interval);
}

void onTick(CBlob@ this)
{
    if (getGameTime() >= this.get_u16("corrupt_time"))
    {
        this.server_Hit( this, this.getPosition(), Vec2f(0,0), damage, 0, true);
        this.set_u16("corrupt_time", getGameTime() + interval);
        this.getSprite().PlaySound("RunnerCorruption.ogg", 0.5f);
        if (this.hasTag("dead"))
        {
            ScriptData@ script = this.getCurrentScript();
            if ( script !is null )
                script.runFlags |= Script::remove_after_this;
        }  
    }
}