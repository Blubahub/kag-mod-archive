void onInit(CBlob @this){

	this.Tag("inventory");

	this.set_u8("equip_slot", 6);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	Take(this, blob);
}

void Take(CBlob@ this, CBlob@ blob)
{
	const string blobName = blob.getName();

	if (blobName == "mat_gold" || blobName == "mat_stone" ||
	        blobName == "mat_wood" || blobName == "grain")
	{
		if ((this.getDamageOwnerPlayer() is blob.getPlayer()) || getGameTime() > blob.get_u32("autopick time"))
		{
			if (!this.server_PutInInventory(blob))
			{
				// we couldn't fit it in
			}
		}
	}
}