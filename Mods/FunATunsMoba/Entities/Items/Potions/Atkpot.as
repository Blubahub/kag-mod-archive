const u16 EFFECT_DURATION = 15 * 30;

void onInit( CBlob@ this )
{
	this.Tag("dont deactivate");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		CBlob@ carrier = this.getCarriedBlob();
		if    (carrier !is null)
		{
			carrier.AddScript( "/AtkPotEffect.as" );
			
			this.getSprite().PlaySound("/Potion.ogg");
			
			if(getNet().isServer())
			{
			    this.server_Die();
			}
		}
    }
}