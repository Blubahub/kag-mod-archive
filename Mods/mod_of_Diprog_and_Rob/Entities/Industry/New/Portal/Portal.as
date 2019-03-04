#include "PortalCommon.as"

void onInit( CBlob@ this )
{
	this.addCommandID("activate");
	this.addCommandID("corrupt");
	this.Tag("portal travel");
	
	 AddIconToken( "$BloodJar$", "BloodJar.png", Vec2f(8,10), 0 );
	 AddIconToken( "$Corrupt$", "BuilderGibs.png", Vec2f(16,16), 2 );

	 if (!this.exists("travel button pos" ))
		this.set_Vec2f("travel button pos", Vec2f_zero );

	this.set_TileType("background tile", CMap::tile_castle_back);
	CShape@ shape = this.getShape();
	if(shape !is null)
	{
		this.set_u8("button radius", Maths::Max(this.getRadius(), (shape.getWidth() + shape.getHeight()) / 2));
	}
	
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	//Activating the portal
	const u16 bloodjar = caller.getBlobCount("bloodjar");
	if (caller.getTeamNum() == this.getTeamNum() && !this.hasTag("activated") && bloodjar > 0)
	{
		caller.CreateGenericButton( "$BloodJar$", Vec2f(0,0), this, this.getCommandID("activate"), "Activate Portal");
	}
	else if (caller.getTeamNum() == this.getTeamNum()&& !this.hasTag("activated") && bloodjar <= 0)
	{
		CButton@ repairBtn = caller.CreateGenericButton( "$BloodJar$", Vec2f(0,0), this, 0, "Activate Portal: Requires Blood Jar" );
		if (repairBtn !is null) { repairBtn.SetEnabled( false );}
	}
	
	if (caller.getTeamNum() != this.getTeamNum() && this.hasTag("activated") && !this.hasTag("corrupted") && caller.getConfig() != "shadowman")
	{
		CButton@ btn = caller.CreateGenericButton( "$Corrupt$", Vec2f(0,0), this, this.getCommandID("corrupt"), "Corrupt");
		if (btn !is null)
		{
			btn.enableRadius = this.get_u8("button radius");
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{

	CBlob@ caller = getBlobByNetworkID( params.read_u16() );

	if (cmd == this.getCommandID("activate"))
	{
		this.Tag("activated");
		if (caller !is null) caller.TakeBlob("bloodjar", 1);
		this.SetLight(true);
		this.SetLightRadius( 30.0f );
		this.SetLightColor(0xffdb3dfe);
	}

	if (cmd == this.getCommandID("corrupt"))
	{
		this.Tag("corrupted");
		this.SetLightColor(0xff7CDC63);
	}
}