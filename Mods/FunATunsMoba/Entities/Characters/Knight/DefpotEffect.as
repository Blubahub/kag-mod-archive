const f32 damage_reduction = 0.4f;

void onTick( CBlob@ this )
{
    if (this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	f32 currentHealth = this.getHealth();
	if (currentHealth < oldHealth)
	{
		this.server_Heal((oldHealth - currentHealth ) * damage_reduction);
    }
}