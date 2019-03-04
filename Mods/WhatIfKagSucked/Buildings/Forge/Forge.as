#include "MakeMat.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-60); //-60 instead of -50 so sprite layers are behind ladders

	// Sand
	CSpriteLayer@ gold = this.addSpriteLayer("mat_sand", "ForgeLayers.png", 24, 16);
	if (gold !is null)
	{
		{
			gold.addAnimation("default", 0, false);
			int[] frames = { 2, 7, 12 };
			gold.animation.AddFrames(frames);
		}
		gold.SetOffset(Vec2f(11.0f, -3.0f));
		gold.SetRelativeZ(1);
		gold.SetVisible(false);
	}
	
	// Metal
	CSpriteLayer@ stone = this.addSpriteLayer("mat_metal", "ForgeLayers.png", 24, 16);
	if (stone !is null)
	{
		{
			stone.addAnimation("default", 0, false);
			int[] frames = { 0, 5, 10 };
			stone.animation.AddFrames(frames);
		}
		stone.SetOffset(Vec2f(12.0f, -3.0f));
		stone.SetRelativeZ(1);
		stone.SetVisible(false);
	}

	// Wood
	CSpriteLayer@ wood = this.addSpriteLayer("mat_wood", "ForgeLayers.png", 24, 16);
	if (wood !is null)
	{
		{
			wood.addAnimation("default", 0, false);
			int[] frames = { 1, 6, 11 };
			wood.animation.AddFrames(frames);
		}
		wood.SetOffset(Vec2f(-14.0f, 5.0f));
		wood.SetRelativeZ(1);
		wood.SetVisible(false);
	}
	
	{	//	Metal Bars
		CSpriteLayer@ mat = this.addSpriteLayer("mat_metalbars", "ForgeLayers.png", 24, 16);
		if (mat !is null)
		{
			{
				mat.addAnimation("default", 0, false);
				int[] frames = { 3, 8, 13 };
				mat.animation.AddFrames(frames);
			}
			mat.SetOffset(Vec2f(15.0f, 5.0f));
			mat.SetRelativeZ(1);
			mat.SetVisible(false);
		}
	}
	
	{	//	Coal
		CSpriteLayer@ mat = this.addSpriteLayer("mat_coal", "ForgeLayers.png", 24, 16);
		if (mat !is null)
		{
			{
				mat.addAnimation("default", 0, false);
				int[] frames = { 4, 9, 14 };
				mat.animation.AddFrames(frames);
			}
			mat.SetOffset(Vec2f(1.0f, 2.0f));
			mat.SetRelativeZ(1);
			mat.SetVisible(false);
		}
	}
	
	CSpriteLayer@ fire = this.addSpriteLayer( "fire", 8,8 );
	if(fire !is null)
	{
		fire.addAnimation("default",3,true);
		int[] frames = {5,6,7,8};
		fire.animation.AddFrames(frames);
		fire.SetOffset(Vec2f(-9, 5));
		fire.SetRelativeZ(0.1f);
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	PickupOverlap(this);
	
	CInventory@ inv = this.getInventory();
	bool cooking = false;
	if(inv.getCount("mat_wood") >= 10){
		if(inv.getCount("mat_metal") >= 10 || inv.getCount("mat_sand") >= 10){
			if(inv.getCount("mat_metal") >= 10){
				inv.server_RemoveItems("mat_metal", 10);
				MakeMat(this, this.getPosition(), "mat_metalbars", 1);
				updateLayers(this, "mat_metal");
				updateLayers(this, "mat_metalbars");
			}
			if(inv.getCount("mat_sand") >= 10){
				inv.server_RemoveItems("mat_sand", 10);
				MakeMat(this, this.getPosition(), "mat_glass", 10);
				updateLayers(this, "mat_sand");
				updateLayers(this, "mat_glass");
			}
			cooking = true;
			MakeMat(this, this.getPosition(), "mat_coal", 10);
			inv.server_RemoveItems("mat_wood", 10);
			updateLayers(this, "mat_coal");
			updateLayers(this, "mat_wood");
		}
	}
	
	CSpriteLayer@ fire = this.getSprite().getSpriteLayer("fire");
	if(fire !is null)fire.SetVisible(cooking);
}

void PickupOverlap(CBlob@ this)
{
	if (getNet().isServer())
	{
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && (blob.getName() == "mat_sand" || blob.getName() == "mat_metal" || blob.getName() == "mat_wood"))
			{
				this.server_PutInInventory(blob);
			}
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	updateLayers(this, blob.getName());
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	updateLayers(this, blob.getName());
}

void updateLayers(CBlob@ this, string blobName)
{
	if (!checkName(blobName))
	{
		return;
	}
	CSprite@ sprite = this.getSprite();
	CInventory@ inv = this.getInventory();
	int blobCount = inv.getCount(blobName);
	if (blobName == "mat_metal")
	{
		CSpriteLayer@ stone = sprite.getSpriteLayer("mat_metal");
		if (blobCount > 0)
		{
			if (blobCount >= 200)
			{
				stone.SetFrameIndex(2);
			}
			else if (blobCount >= 100)
			{
				stone.SetFrameIndex(1);
			}
			else
			{
				stone.SetFrameIndex(0);
			}
			stone.SetVisible(true);
		}
		else
		{
			stone.SetVisible(false);
		}
	}
	else if (blobName == "mat_wood")
	{
		CSpriteLayer@ wood = sprite.getSpriteLayer("mat_wood");
		if (blobCount > 0)
		{
			if (blobCount >= 200)
			{
				wood.SetFrameIndex(2);
			}
			else if (blobCount >= 100)
			{
				wood.SetFrameIndex(1);
			}
			else
			{
				wood.SetFrameIndex(0);
			}
			wood.SetVisible(true);
		}
		else
		{
			wood.SetVisible(false);
		}
	}
	else if (blobName == "mat_sand")
	{
		CSpriteLayer@ gold = sprite.getSpriteLayer("mat_sand");
		if (blobCount > 0)
		{
			if (blobCount >= 200)
			{
				gold.SetFrameIndex(2);
			}
			else if (blobCount >= 100)
			{
				gold.SetFrameIndex(1);
			}
			else
			{
				gold.SetFrameIndex(0);
			}
			gold.SetVisible(true);
		}
		else
		{
			gold.SetVisible(false);
		}
	}
	else if (blobName == "mat_metalbars")
	{
		CSpriteLayer@ gold = sprite.getSpriteLayer("mat_metalbars");
		if (blobCount > 0)
		{
			if (blobCount >= 200)
			{
				gold.SetFrameIndex(2);
			}
			else if (blobCount >= 100)
			{
				gold.SetFrameIndex(1);
			}
			else
			{
				gold.SetFrameIndex(0);
			}
			gold.SetVisible(true);
		}
		else
		{
			gold.SetVisible(false);
		}
	}
	else if (blobName == "mat_coal")
	{
		CSpriteLayer@ gold = sprite.getSpriteLayer("mat_coal");
		if (blobCount > 0)
		{
			if (blobCount >= 200)
			{
				gold.SetFrameIndex(2);
			}
			else if (blobCount >= 100)
			{
				gold.SetFrameIndex(1);
			}
			else
			{
				gold.SetFrameIndex(0);
			}
			gold.SetVisible(true);
		}
		else
		{
			gold.SetVisible(false);
		}
	}
}

bool checkName(string blobName)
{
	return (blobName == "mat_sand" || blobName == "mat_wood" || blobName == "mat_metal" || blobName == "mat_coal" || blobName == "mat_metalbars");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}