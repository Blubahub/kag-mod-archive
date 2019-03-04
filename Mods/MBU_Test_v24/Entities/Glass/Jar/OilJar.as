
void onInit(CBlob@ this)
{
	this.set_u8("meat",30);
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
			if(getNet().isClient())this.getSprite().PlaySound("wetfall2.ogg");
			
			this.Tag("drank");
			
			if(getNet().isServer()){
				this.server_Die();
				caller.server_Pickup(server_CreateBlob("jar",0,this.getPosition()));
			}
			
		}
	}
}