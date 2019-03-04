#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	string blobName = blob.getName();

	if (blobName == "mat_bombs" || blobName == "mat_grenades" || (blobName == "satchel" && !blob.hasTag("exploding")) || blobName == "mat_waterbombs" || (blobName.findFirst("bomb") != -1 && blob.hasTag("material")))
	{
		this.server_PutInInventory(blob);
	}
}
