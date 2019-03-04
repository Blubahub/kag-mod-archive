void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
}
void onTick(CBlob@ this)
{
	FillBucket(this);
}

void FillBucket(CBlob@ this)
{
	CBlob@[] overlaps;
	if (this.getOverlapping(overlaps))
	{
		for (int i = 0; i < overlaps.length; i++)
		{
			CBlob@ overlap = overlaps[i];
			if (overlap !is null)
			{
				if (overlap.getName() == "bucket")
				{
					overlap.set_u8("filled", 3);
					overlap.set_u8("water_delay", 30);
					overlap.getSprite().SetAnimation("full");
				}
			}
		}
	}
}