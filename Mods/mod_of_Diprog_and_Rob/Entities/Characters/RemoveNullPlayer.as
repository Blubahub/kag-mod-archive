int ticksToCheck = 20;
void onInit( CBlob@ this )
{
	this.set_u32("tickstodie", getGameTime() + ticksToCheck);
}
void onTick( CBlob@ this )
{
	if (getGameTime() > this.get_u32("tickstodie"))
	{
		if(this.getPlayer() is null)
			this.server_Die();
		ScriptData@ script = this.getCurrentScript();
		if ( script !is null )
			script.runFlags |= Script::remove_after_this;
	}
}
