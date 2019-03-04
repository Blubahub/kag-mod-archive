
#include "ModHitters.as";

void onInit(CBlob@ this)
{
	this.set_u8("meat",0);
	this.set_u8("plant",0);
	this.set_u8("starch",0);
	
	this.SetLight(true);
	this.SetLightColor(SColor(11, 213, 255, 171));
	this.SetLightRadius(16.0f);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("drink"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && !this.hasTag("drank"))
		{
			
			caller.add_s16("life_amount", 5);
		
			this.server_Hit(caller, caller.getPosition(), Vec2f(0,0), 5.0f, Hitters::life_flame, true);
			caller.Chat("Argh, my tongue!");
			
			this.Tag("drank");
		
			if(getNet().isServer()){
				caller.Sync("life_amount",true);
				
				this.server_Die();
				server_CreateBlob("jar",0,this.getPosition());
			}
			
		}
	}
}