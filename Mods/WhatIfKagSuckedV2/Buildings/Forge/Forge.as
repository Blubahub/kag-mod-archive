#include "MakeMat.as";
#include "ShopCommon.as";
#include "Requirements.as"

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-60); //-60 instead of -50 so sprite layers are behind ladders

	CSpriteLayer@ fire = this.addSpriteLayer( "fire", 8,8 );
	if(fire !is null)
	{
		fire.addAnimation("default",3,true);
		int[] frames = {2,3,4,5};
		fire.animation.AddFrames(frames);
		fire.SetOffset(Vec2f(0, 0));
		fire.SetRelativeZ(0.1f);
	}

}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 30;
	this.Tag("builder always hit");
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
			}
			if(inv.getCount("mat_sand") >= 10){
				inv.server_RemoveItems("mat_sand", 10);
				MakeMat(this, this.getPosition(), "mat_glass", 10);
			}
			cooking = true;
			MakeMat(this, this.getPosition(), "mat_coal", 10);
			inv.server_RemoveItems("mat_wood", 10);
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

bool checkName(string blobName)
{
	return (blobName == "mat_sand" || blobName == "mat_wood" || blobName == "mat_metal" || blobName == "mat_coal" || blobName == "mat_metalbars");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}