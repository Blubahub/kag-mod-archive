#include "StabberCommon.as"

void ManageSword(CBlob @this, bool holding, string type){

	CBlob @item = getEquippedBlob(this,type+"_arm");

	if(item is null)return;
	
	float damage = item.get_f32("damage");
	int drawback = this.get_s16(type+"_drawback");

	if(!this.hasTag(type+"_slash")){
		if(holding){
			this.set_s16(type+"_drawback",drawback+1);
			drawback++;
			
			//if(drawback > 15)
				this.Tag(type+"_slash_mode");
			
			if(drawback > 30){
				this.set_s16(type+"_drawback",30);
				drawback = 30;
			}
			
			Vec2f HitPos = this.getAimPos();
			getMap().rayCastSolidNoBlobs(this.getPosition(),this.getAimPos(),HitPos);
			if(canHitWorldSword(this,HitPos))this.Tag("draw_cursor");
			
		} else {
			if(drawback > 15){
				this.Tag(type+"_slash");
				DoSwordHack(this,damage,-getAimAngle(this),90);
				Vec2f thinghy(1, 0);
				thinghy.RotateBy(-getAimAngle(this));
				this.setVelocity(this.getVelocity()+thinghy*2);
				this.set_s16(type+"_drawback",15);
				drawback = 15;
			} else 
			if(drawback > 1){
				this.Tag(type+"_slash");
				this.Untag(type+"_slash_mode");
				DoStab(this,damage/2,-getAimAngle(this),40);
				this.set_s16(type+"_drawback",20);
				drawback = 20;
			} else {
				this.set_s16(type+"_drawback",0);
				drawback = 0;
			}
		}
	} else {
		if(drawback > 0){
			this.set_s16(type+"_drawback",drawback-6);
			drawback -= 6;
			if(drawback < 0){
				this.set_s16(type+"_drawback",0);
				drawback = 0;
			}
		} else 
		if(drawback < 0){
			this.set_s16(type+"_drawback",drawback+5);
			drawback += 5;
			if(drawback > 0){
				this.set_s16(type+"_drawback",0);
				drawback = 0;
			}
		} else {
			this.Untag(type+"_slash");
			this.Untag(type+"_slash_mode");
		}
	}

	
	if(this.hasTag(type+"_slash_mode")){
		if(drawback != 0)this.Tag(type+"_slashing");
		else if(this.hasTag(type+"_slashing"))this.Untag(type+"_slashing");
		
		if(this.hasTag(type+"_stabing"))this.Untag(type+"_stabing");
	} else {
		if(drawback != 0)this.Tag(type+"_stabing");
		else if(this.hasTag(type+"_stabing"))this.Untag(type+"_stabing");
		
		if(this.hasTag(type+"_slashing"))this.Untag(type+"_slashing");
	}
	
	
}

void DoSwordHack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	CMap@ map = this.getMap();
	Vec2f Aim = this.getAimPos();
	Vec2f HitPos = this.getAimPos();
	
	map.rayCastSolidNoBlobs(this.getPosition(),Aim,HitPos);
	
	///World destruction logics:

	if(canHitWorldSword(this,HitPos)){
	
		this.server_HitMap(HitPos, Vec2f(0,0), damage, Hitters::builder);
	
	}
	
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
				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity/10, damage, Hitters::sword, true);  // server_Hit() is server-side only
					CSprite @sprite = this.getSprite();
				}
			}
		}
	}
}

bool canHitWorldSword(CBlob@ this, Vec2f position){
	
	position = getMap().getAlignedWorldPos(position)+Vec2f(4,4);
	
	CMap@ map = getMap();
	
	Vec2f Direction = position-this.getPosition();
    Direction.Normalize();
	
	float Distance = Maths::Sqrt(Maths::Pow(position.x-this.getPosition().x,2)+Maths::Pow(position.y-this.getPosition().y,2));
	
	if(map.rayCastSolid(this.getPosition(), position-Direction*8) || Distance > 32.0f){
	
		return false;
	
	}
	
	TileType tile = map.getTile(position).type;
	
	if(map.isTileSolid(tile) && (map.isTileGround(tile) || map.isTileWood(tile) || map.isTileGold(tile) || map.isTileStone(tile) || map.isTileThickStone(tile)))return true;
	
	return false;

}