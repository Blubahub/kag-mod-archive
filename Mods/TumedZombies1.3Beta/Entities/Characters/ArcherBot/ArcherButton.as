#include "BrainBotCommon"


void onInit( CBlob@ this )
{			 
    this.addCommandID("archer_standground");
	this.addCommandID("allow_flee");
	//this.addCommandID("stock");
    AddIconToken( "$stop_archer$", "Orders.png", Vec2f(32,32), 3 );
    AddIconToken( "$start_archer$", "Orders.png", Vec2f(32,32), 5 );
	this.getCurrentScript().tickFrequency = 31;
	
}

void onTick( CBlob@ this )
{

}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	/*
	if (!this.hasTag("dead"))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton( "$command_migrant$", Vec2f(0,-8), this, this.getCommandID("stock"), "Shop", params );
	}
	*/
	if (this.hasTag("dead"))
		return;
	//u8 strategy = this.get_u8("strategy");
	bool standground = this.get_bool("standground");
	//printf("strategy = "+strategy);
	CBitStream params;
	const string name = this.getName();
	if (!standground)
	{
		//strategy = Strategy::standground;
		standground = true;
		//printf("standground = "+standground);
		//params.write_u16( this.getNetworkID() );
		params.write_bool( standground );
		caller.CreateGenericButton( "$stop_archer$", Vec2f(0,-32), this,  this.getCommandID("archer_standground"), "Tell archer to standground", params );
	}
	else
	{
		standground = false;
		//printf("standground = "+standground);
		//params.write_u16( this.getNetworkID() );
		params.write_bool( standground );
		caller.CreateGenericButton( "$start_archer$", Vec2f(0,-32), this,  this.getCommandID("allow_flee"), "Allow archer to flee if needed", params );
	}
	
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{		

	bool standground = false;
	//printf("Command started!");
    if (cmd == this.getCommandID("archer_standground"))
    {	
    	standground = params.read_bool();
    	this.set_bool("standground", standground);
    	//printf("strategy stop_migrant = "+strategy);	
    }
    else if (cmd == this.getCommandID("allow_flee"))
    {
    	standground = params.read_bool();
    	this.set_bool("standground", standground);
    	//printf("strategy start_migrant = "+strategy);	
    }
}
