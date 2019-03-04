#include "ThrowCommon.as";

void onInit(CBlob@ this)
{
 //   print("test");
    this.addCommandID("activate");
    this.Tag("explosive");
    this.Tag("activatable");
    //this.SendCommand(this.getCommandID("activate")); // triggers nade from start which makes the whole stuff to check if its activated useless
}

void onTick(CBlob@ this)
{
    if (this.isAttachedToPoint("PICKUP"))
    {
        CBitStream params;
        CBlob@ playerBlob = this.getAttachments().getAttachedBlob("PICKUP");
        CControls@ playerControl = playerBlob.getControls();
        if(playerControl.isKeyJustPressed(KEY_LBUTTON))
        {
            params.write_u16(playerBlob.getNetworkID());
            this.SendCommand(this.getCommandID("activate"),params);
            //this.server_Die();
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("activate"))
    {
 //       print("it activated");
        this.getSprite().PlaySound("grenade_pinpull.ogg", 1.00f, 1.00f);
    
       CBlob@ playerBlobtest = getBlobByNetworkID(params.read_u16());

        if(playerBlobtest !is null && getNet().isServer())
        {
            CBlob@ blob = server_CreateBlob("firegrenade", this.getTeamNum(), this.getPosition());
            playerBlobtest.server_Pickup(blob);
            this.server_Die();
        }
        else
        {
            this.server_Die();
        }
    }
}