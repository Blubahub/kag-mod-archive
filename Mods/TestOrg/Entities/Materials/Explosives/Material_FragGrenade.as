void onIhit(CBlob@ this)
{
	this.Tag("explosive");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("activate"))
    {
		this.getSprite().PlaySound("grenade_pinpull.ogg", 1.00f, 1.00f);
	
        if(getNet().isServer())
        {
    		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
    		CBlob@ holder = point.getOccupied();

            if(holder !is null)
            {
                CBlob@ blob = server_CreateBlob("fraggrenade", this.getTeamNum(), this.getPosition());
                holder.server_Pickup(blob);
                this.server_Die();
            }
        }
    }
}
