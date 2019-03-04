
#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.set_u8("meat",0);
	this.set_u8("plant",0);
	this.set_u8("starch",0);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("drink"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && !this.hasTag("drank"))
		{
			Sound::Play("puke.ogg", caller.getPosition(), 1.0f);
			caller.Chat("Blergh, w-what... is this stuff...");
			
			this.Tag("drank");
			
			if(getNet().isServer()){
				this.server_Die();
				server_CreateBlob("jar",0,this.getPosition());
				SetKnocked(caller,60,true);
			}
			
		}
	}
}