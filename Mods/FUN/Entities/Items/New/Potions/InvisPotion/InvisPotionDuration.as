void onTick(CBlob@ this)
{
    int invisDuration = this.get_u16("invisDuration");
    if (getGameTime() >= invisDuration)
    {
        this.SetVisible(true);
        ScriptData@ script = this.getCurrentScript();
        if ( script !is null)
        {
        	script.runFlags |= Script::remove_after_this;
        }
    }
}