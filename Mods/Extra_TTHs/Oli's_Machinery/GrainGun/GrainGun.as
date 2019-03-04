void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
this.Tag("no shitty rotation reset");
}
void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point is null) return;
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;
	CInventory@ holderinv = holder.getInventory();
	if (holderinv is null) return;
	if(point.isKeyJustPressed(key_action1))
	{
		if(getNet().isServer())
		{
			if (holderinv.isInInventory("grain", 1))
			{
				holderinv.server_RemoveItems("grain", 1);
				Vec2f thisway = holder.getAimPos() - holder.getPosition();
				thisway.Normalize();
				CBlob@ chakram = server_CreateBlob("grainshot", holder.getTeamNum(), holder.getPosition()+thisway*5);
				chakram.setVelocity(thisway*20);
				this.getSprite().PlaySound("/BolterFire");
			}
		}
	}
}