const f32 attack_modifier = 1.25f;

void onTick( CBlob@ this )
{
    if (this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
	else
	{
		this.set_f32("atkmult", 1.5f);
		
	}
}