#include "MakeMat.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50); //-60 instead of -50 so sprite layers are behind ladders
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;
	
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	if(this.get_s16("heat") < 600){
	
		if(this.hasBlob("log", 1)){
			this.TakeBlob("log", 1);
			this.set_s16("heat",this.get_s16("heat")+25);
			this.set_s16("smoke",this.get_s16("smoke")+25);
		} else
		if(this.hasBlob("stick", 1)){
			this.TakeBlob("stick", 1);
			this.set_s16("heat",this.get_s16("heat")+10);
			this.set_s16("smoke",this.get_s16("smoke")+10);
		} else
		for(int i = 5; i > 0;i--){
			if(this.hasBlob("mat_wood", i)){
				this.TakeBlob("mat_wood", i);
				this.set_s16("heat",this.get_s16("heat")+i);
				this.set_s16("smoke",this.get_s16("smoke")+i);
				break;
			}
		}
	}
	
	if(this.get_s16("heat") > 0){
		this.getSprite().SetAnimation("burning");
		this.SetLight(true);
	} else {
		this.getSprite().SetAnimation("default");
		this.SetLight(false);
	}
	
	if(getNet().isServer())this.Sync("heat",true);
	
	this.setInventoryName("Fireplace\nTemperature: "+(27+this.get_s16("heat"))+"C");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	
	if (!blob.isAttached())
	if(blob.getName() == "mat_wood" || blob.getName() == "log")
	{
		if (getNet().isServer()) this.server_PutInInventory(blob);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is null && forBlob.isOverlapping(this);
}