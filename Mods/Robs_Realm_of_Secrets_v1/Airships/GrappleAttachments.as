
void onInit(CBlob@ this)
{
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			this.addCommandID("HOOK"+i);
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			if (ap.socket)
			{
				int image = 0;
				if(ap.getOccupied() is null)image = 1;
				
				Vec2f pos = (ap.getPosition()-this.getPosition())/2;
				
				if(this.isFacingLeft())pos = Vec2f(pos.x*-1,pos.y);
				
				CButton@ button = caller.CreateGenericButton(image, pos, this, this.getCommandID("HOOK"+i), "Hook attachment point", params);
				//button.SetEnabled(this.isAttachedTo(caller));
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket)if (cmd == this.getCommandID("HOOK"+i))
				{
					if(ap.getOccupied() !is null){
						ap.getOccupied().server_DetachFrom(this);
					} else {
						CBlob@ hold = caller.getCarriedBlob();
						if(hold !is null){
							if(hold.getName() == "grapple"){
								caller.DropCarried();
								this.server_AttachTo(hold, ap);
							}
						}
					}
				}
			}
		}
	}
}