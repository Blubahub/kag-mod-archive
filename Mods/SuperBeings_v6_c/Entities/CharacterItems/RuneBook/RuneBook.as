void onInit( CBlob@ this )
{
	this.addCommandID("usebook");
	this.server_setTeamNum(0);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("usebook"), "Learn the secrets of life and death.", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("usebook"))
	{
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CPlayer@ player = caller.getPlayer();
			if (player !is null)
			{
				if(player.get_s16("book_level") >= 0){
					CBlob @newBlob = server_CreateBlob("runewhisperer", caller.getTeamNum(), this.getPosition());
					if (newBlob !is null)
					{
					
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
						newBlob.server_SetHealth(caller.getHealth());
						caller.Tag("switch class");
						caller.server_SetPlayer(null);
						caller.server_Die();
					}
				} else {
					if (player is getLocalPlayer())
					{
						client_AddToChat("You're too dumb to grasp this book's concepts.", SColor(255, 0, 0, 0));
					}
				}
			}
		}
	}
}
