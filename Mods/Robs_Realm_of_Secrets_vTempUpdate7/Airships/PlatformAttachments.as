
void onInit(CBlob@ this)
{
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			this.addCommandID("PLATFORM"+i);
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket && ap.name == "PLATFORM")
				{
					int image = 0;
					if(ap.getOccupied() is null)image = 1;
					
					Vec2f pos = ap.offset/2;
					
					bool ShowButton = false;
					
					CBlob @Carried = caller.getCarriedBlob();
					if(Carried !is null){
						if(image == 1){
							if(Carried.getName() == "platform" || Carried.hasTag("platform") || Carried.getName() == "scaffolding")
							ShowButton = true;
						}
					} else {
						if(image == 0)ShowButton = true;
					}
					
					if(ShowButton)caller.CreateGenericButton(image, pos, this, this.getCommandID("PLATFORM"+i), "Platform attachment point", params);
				}
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
				if (ap.socket && ap.name == "PLATFORM")if (cmd == this.getCommandID("PLATFORM"+i))
				{
					if(ap.getOccupied() !is null){
						ap.getOccupied().server_DetachFrom(this);
					} else {
						CBlob@ hold = caller.getCarriedBlob();
						if(hold !is null){
							if(hold.getName() == "platform" || hold.hasTag("platform") || hold.getName() == "scaffolding"){
								caller.DropCarried();
								this.server_AttachTo(hold, ap);
								AttachmentPoint @hap = hold.getAttachmentPoint(0);
								if(hap !is null)ap.occupied_offset = hap.offset;
								hold.getShape().getConsts().collideWhenAttached = true;
							}
						}
					}
				}
			}
		}
	}
}