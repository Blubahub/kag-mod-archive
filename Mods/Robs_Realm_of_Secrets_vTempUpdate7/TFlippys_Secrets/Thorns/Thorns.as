// Bush logic

#include "../Scripts/canGrow.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.set_bool("grown", true);
	this.set_u32("lastTouch", 0);
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u16 netID = blob.getNetworkID();
	this.animation.frame = (netID % this.animation.getFramesCount());
	this.SetFacingLeft(((netID % 13) % 2) == 0);
	this.SetZ(10.0f);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (this.get_u32("lastSoundPlayedTime") + 30 < getGameTime() && blob !is null && blob.hasTag("flesh"))
	{		
		this.getSprite().PlaySound("sand_fall", 1.30f, 0.80f);
		this.set_u32("lastSoundPlayedTime", getGameTime());
		
		if(getNet().isServer()){
			blob.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 0.25f, Hitters::suddengib, false);
		}
	}
	
	if(blob !is null && (blob.getName() == "log" || blob.getName() == "seed" || blob.getName() == "grain"))
	{
		if(getNet().isServer()){
			blob.server_Die();
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.getSprite().PlaySound("sand_fall", 1.30f, 0.80f);
	this.server_Die();
	
	return 2.0f;
}