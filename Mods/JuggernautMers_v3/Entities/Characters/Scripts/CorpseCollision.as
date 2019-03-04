#define SERVER_ONLY

// set "hit dmg modifier" in your blob to modify blob hit damage
// set "map dmg modifier" in your blob to modify map hit damage

#include "HittersNew.as"
#include "Knocked.as"

void onInit(CBlob@ this)
{
	
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(!solid || !this.hasTag("dead")){
		return;
	}
	
	Vec2f hitvel = this.getOldVelocity();
	Vec2f hitvec = point1 - this.getPosition();
	f32 coef = hitvec * hitvel;

	if (coef < 0.706f) // check we were flying at it
	{
		return;
	}

	f32 vellen = hitvel.Length();

	if(blob !is null && (blob.getTeamNum()!=this.getTeamNum() || vellen>5.0f)) {
		this.server_Hit(blob,this.getPosition(),Vec2f(0.0f,0.0f),vellen/5.0f,HittersNew::flying,true);
		this.server_Hit(this,this.getPosition(),Vec2f(0.0f,0.0f),1000.0f,0,true);
		SetKnocked(blob,50);
	}else{
		this.server_Hit(this,this.getPosition(),Vec2f(0.0f,0.0f),vellen/15.0f,0,true);
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null && customData == HittersNew::flying)
	{
		Vec2f force = velocity * this.getMass() * 0.05f;
		hitBlob.AddForce(force);
	}
}
