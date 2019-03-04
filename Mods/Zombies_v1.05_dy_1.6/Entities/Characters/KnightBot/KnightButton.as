#include "BrainBotCommon"


void onInit( CBlob@ this )
{			 
    this.addCommandID("knight_standground");
	this.addCommandID("allow_chase");
	//this.addCommandID("stock");
    AddIconToken( "$stop_knight$", "Orders.png", Vec2f(32,32), 3 );
    AddIconToken( "$start_knight$", "Orders.png", Vec2f(32,32), 0 );
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
		caller.CreateGenericButton( "$stop_knight$", Vec2f(0,-32), this,  this.getCommandID("knight_standground"), "Tell knight to standground", params );
	}
	else
	{
		standground = false;
		//printf("standground = "+standground);
		//params.write_u16( this.getNetworkID() );
		params.write_bool( standground );
		caller.CreateGenericButton( "$start_knight$", Vec2f(0,-32), this,  this.getCommandID("allow_chase"), "Allow knight to chase target", params );
	}
	
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{		

	bool standground = false;
	//printf("Command started!");
    if (cmd == this.getCommandID("knight_standground"))
    {	
    	standground = params.read_bool();
    	this.set_bool("standground", standground);
    	//printf("strategy stop_migrant = "+strategy);	
    }
    else if (cmd == this.getCommandID("allow_chase"))
    {
    	standground = params.read_bool();
    	this.set_bool("standground", standground);
    	//printf("strategy start_migrant = "+strategy);	
    }
}
