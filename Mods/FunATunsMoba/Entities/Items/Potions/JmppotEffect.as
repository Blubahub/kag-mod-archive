void onTick( CBlob@ this )
{
    if (this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
	else
	{
	    this.AddForce(Vec2f(0, -6.0f));
	}
}