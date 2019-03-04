void onInit(CBlob@ this )
{
	this.addCommandID("repair");
	if (!this.exists("repair_costs"))
		this.set_u16("repair_costs", 1000);
	if (!this.exists("repair_mat_cfg"))
		this.set_string("repair_mat_cfg", "mat_wood");
	if (!this.exists("repair_mat_name"))
		this.set_string("repair_mat_name", "Wood");
	if (!this.exists("repair_offset"))
		this.set_Vec2f("repair_offset", Vec2f(0,-8));
		
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (!caller.isOverlapping(this)) return;
	
	string matCFG = this.get_string("repair_mat_cfg");
	string matName = this.get_string("repair_mat_name");
	u16 repairCosts = this.get_u16("repair_costs");
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	u16 woodCount;
	string name = this.getInventoryName();
	if (caller !is null) woodCount = caller.getBlobCount(matCFG);
	
	Vec2f offset = this.get_Vec2f("repair_offset");
	if (woodCount >= repairCosts)
	{
		caller.CreateGenericButton( 15, offset, this, this.getCommandID("repair"), "Repair " + name, params );
	}
	else
	{
		CButton@ repairBtn = caller.CreateGenericButton( 15, offset, this, 0, "Repair " + name + ": Requires "+repairCosts+" " + matName );
		if (repairBtn !is null) { repairBtn.SetEnabled( false );}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	string matCFG = this.get_string("repair_mat_cfg");
	u16 repairCosts = this.get_u16("repair_costs");
	
	CBlob@ blob = getBlobByNetworkID( params.read_netid() );

	if (cmd == this.getCommandID("repair"))
	{
		if (this.getSprite() !is null) this.getSprite().PlaySound("/Construct.ogg"); 
		if (blob !is null) blob.TakeBlob( matCFG, repairCosts );
		this.server_Heal(1000.0f);
	}
}
