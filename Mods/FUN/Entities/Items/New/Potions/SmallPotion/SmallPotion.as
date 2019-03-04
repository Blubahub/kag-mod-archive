#include "PotionsCommon.as";

void onInit( CBlob@ this )
{
    this.Tag( "dont deactivate" );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("activate"))
    {
        CBlob@ attached = this.getCarriedBlob();
        if ( attached !is null )
        {
            attached.set_u16( "invisDuration", getGameTime() + invisDuration );
            attached.SetVisible(false);
            attached.AddScript("/InvisPotionDuration.as");
            //attached.getSprite().AddScript("/PotionsGUI.as"); it's buggy
            attached.getSprite().PlaySound("/Potion.ogg");
            this.server_Die();
        }
    }
}