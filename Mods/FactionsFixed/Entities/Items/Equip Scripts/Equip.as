
void onInit( CBlob@ this )
{
	this.addCommandID("equip");
	this.set_u8("cooldown", 40);
	this.Sync("cooldown", true);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	//if(caller)
	if(this.get_u8("cooldown") == 1)
	{
		CButton@ button = caller.CreateGenericButton(15, Vec2f_zero, this, this.getCommandID("equip"), "Equip this Item!", params);
		if (this.hasTag("Sword") && caller.getName() == "knight" && this.isAttachedTo(caller))
		{
			button.SetEnabled(true);
		}
		else if (this.hasTag("Armor") && (caller.getName() == "knight" || caller.getName() == "builder") && this.isAttachedTo(caller))
		{
			button.SetEnabled(true);
		}
		else if (this.hasTag("Bow") && caller.getName() == "archer" && this.isAttachedTo(caller))
		{
			button.SetEnabled(true);
		}
		else
		{
			button.SetEnabled(false);
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("equip"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (this.hasTag("Sword") && caller.getName() == "knight" && this.isAttachedTo(caller))
			{
				//print("hi");
				CBlob@ weapon = server_CreateBlob(caller.get_string("sword"), -1, caller.getPosition());
				caller.set_string("sword",this.getName());
				this.server_Die();
			}
			if (this.hasTag("Armor") && (caller.getName() == "knight" || caller.getName() == "builder") && this.isAttachedTo(caller))
			{
				this.server_Die();
				CBlob@ weapon = server_CreateBlob(caller.get_string("armor"), -1, caller.getPosition());
				caller.set_string("armor",this.getName());
			}
			if (this.hasTag("Bow") && caller.getName() == "archer" && this.isAttachedTo(caller))
			{
				CBlob@ weapon = server_CreateBlob(caller.get_string("bow"), -1, caller.getPosition());
				caller.set_string("bow",this.getName());
				this.server_Die();
			}
		}	
	}
}

void onTick(CBlob@ this)
{
	if(this.get_u8("cooldown") > 1)
	{
		this.set_u8("cooldown", this.get_u8("cooldown") - 1);
	}
}
