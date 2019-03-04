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
           /* u16 light = attached.get_u16("lightDuration");
            if (getGameTime() < light)
                attached.set_u16( "lightDuration", light + lightDuration );
            else*/
                
            /*light = attached.get_u16("lightDuration");
            print("" + light);*/
           
            if (!attached.hasTag("light"))
            {
                CShape@ shape = attached.getShape();
                attached.set_f32("defaultMass", attached.getMass());
                attached.AddScript("/LightPotionDuration.as");
                //attached.getSprite().AddScript("/PotionsGUI.as"); it's buggy
                attached.set_u16( "lightDuration", getGameTime() + lightDuration );
                shape.SetMass(attached.getMass() / lightMass);
                attached.Tag("light");
            }
            this.getSprite().PlaySound("/Potion.ogg");
            this.server_Die();
        }
    }
}