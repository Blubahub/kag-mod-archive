const f32 LOSS_RATE = 0.13f;//health loss per second
const u16 START_AT = 10 * 30;

void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
	if ( this.getTickSinceCreated() > START_AT )
	{
		this.server_Heal( -LOSS_RATE );
		if ( this.getHealth() < 0.0f )
		{
			this.getSprite().Gib();
			this.server_Die();
		}
	}
}