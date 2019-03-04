#include "CommonGun.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(80.0f);
	this.SetLightColor(SColor(255, 180, 230, 255));
	
	this.set_u16("lightblob_id", 0);
	
	if (getNet().isServer())
	{
		CBlob@ light = server_CreateBlob("flashlight_light", this.getTeamNum(), this.getPosition());
		this.set_u16("lightblob_id", light.getNetworkID());
		this.Sync("lightblob_id", true);
	}
}

void onTick(CBlob@ this)
{
	GunTick(this);
	
	Vec2f startPos =	this.getPosition();
	Vec2f hitPos;
	f32 length;
		
	bool flip=this.isFacingLeft();	
	
	f32 angle =	this.getAngleDegrees();
	
	Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1),0.0f).RotateBy(angle);
	Vec2f endPos = startPos + dir * 100.0f;

	HitInfo@[] hitInfos;
	bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
	length = (hitPos - startPos).Length();
	bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);
	
	CBlob@ light = getBlobByNetworkID(this.get_u16("lightblob_id"));
	
	if (light !is null)
	{
		// print("light");
		light.setPosition(hitPos);
	}
	else
	{
		print("no light");
	}
	
	// if(getNet().isClient())
	// {
		// this.setPosition(target);
	// }
}