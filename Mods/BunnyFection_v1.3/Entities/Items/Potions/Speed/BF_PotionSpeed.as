const u16 EFFECT_TIME = 5 * 30;

void onInit( CBlob@ this )
{
    AttachmentPoint@ att = this.getAttachments().getAttachmentPointByName("PICKUP");
	att.SetKeysToTake(key_action1 | key_action2);
    att.SetMouseTaken(false);
	this.Tag( "dont deactivate" );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("activate"))
    {
		CBlob@ carrier = this.getCarriedBlob();
		if ( carrier !is null )
		{
			//effect
			carrier.set_u16( "speedEffectTime", getGameTime() + EFFECT_TIME );//set here so drinking another speed potion resets it
			carrier.AddScript( "/BF_PotionSpeedEffect.as" );

			//sound effect
			this.getSprite().PlaySound("/PotionDrink.ogg");
			
			if ( getNet().isServer() )
				this.server_Die();
		}
    }
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return ( this.getTeamNum() == byBlob.getTeamNum() );
}