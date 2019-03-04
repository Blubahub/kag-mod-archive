#include "StabberCommon.as"
#include "Ally.as"
#include "Knocked.as";
#include "HumanoidCommon.as";

void ManageSword(CBlob @this, CBlob @item, bool holding, string type){

	string drawback_string = type+"_drawback";
	int drawback = this.get_s16(drawback_string);

	float damage = 4;
	int hitter = Hitters::sword;
	int speed = 5;
	
	if(item !is null){
		damage = item.get_f32("damage");
		if(item.exists("hitter"))hitter = item.get_u8("hitter");
		speed = item.get_u8("speed");
	}
	
	damage *= getStrength(this,type+"_arm");

	if(!this.hasTag(type+"_slash")){
		if(holding){
			this.add_s16(drawback_string,speed);
			drawback += speed;
			
			//if(drawback > 75)
				this.Tag(type+"_slash_mode");
			
			if(drawback > 150){
				this.set_s16(drawback_string,150);
				drawback = 150;
			}
			
			Vec2f HitPos = this.getAimPos();
			getMap().rayCastSolidNoBlobs(this.getPosition(),this.getAimPos(),HitPos);
			if(canHitWorldSword(this,HitPos))this.Tag("draw_cursor");
			
		} else {
			if(drawback > 75){
				this.Tag(type+"_slash");
				DoSwordHack(this,item,damage,-getAimAngle(this),90, hitter);
				Vec2f thinghy(1, 0);
				thinghy.RotateBy(-getAimAngle(this));
				this.setVelocity(this.getVelocity()+thinghy*2);
				this.set_s16(drawback_string,75);
				drawback = 75;
			} 
			else 
			if(drawback > 25){
				this.Tag(type+"_slash");
				DoSwordHack(this,item,damage*0.4f,-getAimAngle(this),90, hitter);
				//drawback = 100;
				//this.set_s16(drawback_string,drawback);
			} else {
				this.set_s16(drawback_string,0);
				drawback = 0;
			}
		}
	} else {
		if(drawback > 0){
			this.set_s16(drawback_string,drawback-30);
			drawback -= 30;
			if(drawback < 0){
				this.set_s16(drawback_string,0);
				drawback = 0;
			}
		} else 
		if(drawback < 0){
			this.set_s16(drawback_string,drawback+25);
			drawback += 25;
			if(drawback > 0){
				this.set_s16(drawback_string,0);
				drawback = 0;
			}
		} else {
			this.Untag(type+"_slash");
			this.Untag(type+"_slash_mode");
		}
	}

	
	if(this.get_s16(drawback_string) != 0)this.set_u8(type+"_implement", 6);
	
	
}

void DoSwordHack(CBlob@ this, CBlob @item, f32 damage, f32 aimangle, f32 arcdegrees, u8 hitter)
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
	Vec2f HitPos = this.getAimPos();
	
	CBlob @hitterBlob = this;
	if(item !is null)@hitterBlob = item;
	
	map.rayCastSolidNoBlobs(this.getPosition(),Aim,HitPos);
	
	///World destruction logics:

	if(canHitWorldSword(this,HitPos) && damage > 3.0f){
	
		hitterBlob.server_HitMap(HitPos, Vec2f(0,0), damage, hitter);
	
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
			if(checkAlly(this.getTeamNum(),b.getTeamNum()) != 2){
				Vec2f velocity = thinghy;
				hitterBlob.server_Hit(b, hi.hitpos, velocity, damage, hitter, true);  // server_Hit() is server-side only
				CSprite @sprite = this.getSprite();
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