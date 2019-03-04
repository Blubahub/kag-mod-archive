void onTick(CBlob@ this)
{
    int lightDuration = this.get_u16("lightDuration");
    if (getGameTime() >= lightDuration)
    {
        CShape@ shape = this.getShape();
        f32 defaultMass = this.get_f32("defaultMass");
        shape.SetMass(defaultMass);
        this.Untag("light");
        ScriptData@ script = this.getCurrentScript();
        if ( script !is null )
        {
            script.runFlags |= Script::remove_after_this;
        }
    }
}