#include "TeamColour.as";

void onInit(CBlob@ this)
{
    this.addCommandID("send_chat");
}

void onCommand( CBlob@ this, u8 cmd, CBitStream@ params )
{
    if(cmd == this.getCommandID("send_chat"))
    {
        u16 netID = params.read_netid();
        u8 r = params.read_u8();
        u8 g = params.read_u8();
        u8 b = params.read_u8();
        string text = params.read_string();
        if(this.getNetworkID() == netID && this.getPlayer() !is null && this.getPlayer().isMyPlayer())
        {
            client_AddToChat(text, SColor(255,r,g,b));
        }
    }
}