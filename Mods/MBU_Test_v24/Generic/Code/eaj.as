
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
			
			caller.add_s16("death_amount", 10);
			
			this.Tag("drank");
		
			if(getNet().isServer()){
				caller.Sync("death_amount",true);
				
				this.server_Die();
				server_CreateBlob("jar",0,this.getPosition());
			}
			
		}
	}
}