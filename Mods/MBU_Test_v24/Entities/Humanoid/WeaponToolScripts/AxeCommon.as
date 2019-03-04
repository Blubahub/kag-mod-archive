#include "Ally.as";
#include "Knocked.as";
#include "HumanoidCommon.as";

void ManageAxe(CBlob @this, CBlob @item, bool holding, string type){

	string drawback_string = type+"_drawback";

	float damage = 1;
	int speed = 5;
	
	if(item !is null){
		damage = item.get_f32("damage");
		speed = item.get_u8("speed");
	}
	
	damage *= getStrength(this,type+"_arm");

	if(holding){
		if(this.get_s16(drawback_string) < 75)this.add_s16(drawback_string,speed);
		else {
			DoHack(this,item,damage,-getAimAngle(this),40);
			if(this.get_s16(drawback_string) > 0)this.set_s16(drawback_string,0);
			if(this.get_s16(drawback_string) < 0)this.set_s16(drawback_string,0);
		}
		
		if(canHitWorldAxe(this,this.getAimPos()))this.Tag("draw_cursor");
		
	} else this.set_s16(drawback_string,0);
	
	if(this.get_s16(drawback_string) != 0)this.set_u8(type+"_implement", 3);
}

void DoHack(CBlob@ this, CBlob @item, f32 damage, f32 aimangle, f32 arcdegrees)
{
	if (!getNet().isServer() || getKnocked(this) > 0)
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	CMap@ map = this.getMap();
	Vec2f Aim = this.getAimPos();
	
	CBlob @hitterBlob = this;
	if(item !is null)@hitterBlob = item;
	
	///World destruction logics:
	if(canHitWorldAxe(this,Aim)){
	
		hitterBlob.server_HitMap(Aim, Vec2f(0,0), damage, Hitters::axe);
	
		return;
	
	}
	
	///If we didn't hit the world, hit blobs:
	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(12 + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), 16);

	f32 radius = this.getRadius();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (checkAlly(this.getTeamNum(),b.getTeamNum()) == 0)
				{
					Vec2f velocity = thinghy;
					hitterBlob.server_Hit(b, hi.hitpos, velocity, damage, Hitters::axe, true);  // server_Hit() is server-side only
					CSprite @sprite = this.getSprite();
				}
			}
		}
	}
}

bool canHitWorldAxe(CBlob@ this, Vec2f position){

	
	position = getMap().getAlignedWorldPos(position)+Vec2f(4,4);
	
	CMap@ map = getMap();
	
	Vec2f Direction = position-this.getPosition();
    Direction.Normalize();
	
	float Distance = Maths::Sqrt(Maths::Pow(position.x-this.getPosition().x,2)+Maths::Pow(position.y-this.getPosition().y,2));
	
	if(map.rayCastSolid(this.getPosition(), position-Direction*8) || Distance > 32.0f){
	
		return false;
	
	}
	
	TileType tile = map.getTile(position).type;
	
	if (map.isTileWood(tile) || (tile >= 205 && tile <= 207)){
		return true;
	}
	
	return false;

}

