const u16 EFFECT_TIME = 6 * 30;

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
			carrier.set_u16( "invisibilityEffectTime", getGameTime() + EFFECT_TIME );
			carrier.AddScript( "/BF_PotionInvisibilityEffect.as" );

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