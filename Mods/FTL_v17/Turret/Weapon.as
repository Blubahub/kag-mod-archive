
#include "WeaponCommon.as";

void onInit(CBlob@ this)
{
	this.set_u16("type",1);
}

void onTick(CBlob@ this){
	this.setInventoryName(WeaponName[this.get_u16("type")]);
}

void onTick(CSprite@ this){

	CBlob @blob = this.getBlob();
	
	if(blob is null)return;

	this.SetFrame(blob.get_u16("type")*6);
}