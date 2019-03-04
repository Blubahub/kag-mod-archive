void onInit( CBlob@ this )
{
	this.addCommandID("unpack");
    this.Tag("medium weight");
	this.getSprite().SetZ(-25);
    
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (!caller.isOverlapping(this)) return;
	if (this.getTeamNum() == caller.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton( 15, Vec2f(0.0,0.0), this, this.getCommandID("unpack"), "Build Outpost" , params );
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("unpack"))
	{
		CBlob@ newOutpost; 
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		this.getSprite().PlaySound("/Construct.ogg"); 
		
		if(getNet().isServer()){
			this.server_Die();
			@newOutpost = server_CreateBlob( "outpost", blob.getTeamNum(), Vec2f(this.getPosition().x, this.getPosition().y - 1.5)); 


		}

	}
}




