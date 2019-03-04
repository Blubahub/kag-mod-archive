
void onInit( CBlob@ this )
{
	this.addCommandID("equip");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	//if(caller)
	CButton@ button = caller.CreateGenericButton(15, Vec2f_zero, this, this.getCommandID("equip"), "Equip this Item!", params);
	if (this.hasTag("Sword") && (caller.getName() == "nathan" || caller.getName() == "oz"))
	{
		button.SetEnabled(true);
	}
	else if (this.hasTag("Armor") && ((caller.getName() == "nathan" || caller.getName() == "oz") || (caller.getName() == "payton" || caller.getName() == "molly")))
	{
		button.SetEnabled(true);
	}
	else if (this.hasTag("Bow") && caller.getName() == "brennan")
	{
		button.SetEnabled(true);
	}
	else
	{
		button.SetEnabled(false);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("equip"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (this.hasTag("Sword") && (caller.getName() == "nathan" || caller.getName() == "oz"))
			{
				//print("hi");
				CBlob@ weapon = server_CreateBlob(caller.get_string("sword"), -1, caller.getPosition());
				caller.set_string("sword",this.getName());
				this.server_Die();
			}
			if (this.hasTag("Armor") && ((caller.getName() == "nathan" || caller.getName() == "oz") || (caller.getName() == "payton" || caller.getName() == "molly")))
			{
				CBlob@ weapon = server_CreateBlob(caller.get_string("armor"), -1, caller.getPosition());
				caller.set_string("armor",this.getName());
				this.server_Die();
			}
			if (this.hasTag("Bow") && caller.getName() == "brennan")
			{
				CBlob@ weapon = server_CreateBlob(caller.get_string("bow"), -1, caller.getPosition());
				caller.set_string("bow",this.getName());
				this.server_Die();
			}
		}	
	}
}
