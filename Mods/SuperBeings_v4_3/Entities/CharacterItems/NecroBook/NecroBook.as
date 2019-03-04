void onInit( CBlob@ this )
{
	this.addCommandID("usebook");
	this.set_string("owner","");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("usebook"), "Gain control over life and death.", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("usebook"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
            CBlob @newBlob = server_CreateBlob("necro", 9, this.getPosition());
			if (newBlob !is null)
			{
				this.getSprite().PlaySound("/EvilNotice", 1.2f, 1.00f); // TFlippy
			
				// plug the soul
				newBlob.server_SetPlayer(caller.getPlayer());
				newBlob.setPosition(caller.getPosition());

				// no extra immunity after class change
				if (caller.exists("spawn immunity time"))
				{
					newBlob.set_u32("spawn immunity time", caller.get_u32("spawn immunity time"));
					newBlob.Sync("spawn immunity time", true);
				}

				if (caller.exists("knocked"))
				{
					newBlob.set_u8("knocked", caller.get_u8("knocked"));
					newBlob.Sync("knocked", true);
				}
				
				newBlob.set_string("owner",this.get_string("owner"));
				
				caller.Tag("switch class");
				caller.server_SetPlayer(null);
				caller.server_Die();
				this.server_Die();
			}
		}
		
	}
}
