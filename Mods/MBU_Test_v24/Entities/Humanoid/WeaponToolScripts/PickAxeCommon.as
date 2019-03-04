#include "getAimAttackTarget.as";
#include "Knocked.as";
#include "ModHitters.as";
#include "HumanoidCommon.as";

void ManagePickAxe(CBlob @this, CBlob @item, bool holding, string type){

	string drawback_string = type+"_drawback";

	float damage = 1;
	int hitter = Hitters::axe;
	int speed = 5;
	
	if(item !is null){
		damage = item.get_f32("damage");
		if(item.exists("hitter"))hitter = item.get_u8("hitter");
		speed = item.get_u8("speed");
	}
	
	damage *= getStrength(this,type+"_arm");

	if(holding){
		if(this.get_s16(drawback_string) < 75)this.add_s16(drawback_string,speed);
		else {
			DoPickHack(this,item,damage,hitter);
			if(this.get_s16(drawback_string) > 0)this.set_s16(drawback_string,0);
			if(this.get_s16(drawback_string) < 0)this.set_s16(drawback_string,0);
		}
		
		Vec2f HitPos = this.getAimPos();
		getMap().rayCastSolidNoBlobs(this.getPosition(),this.getAimPos(),HitPos);
		CBlob @targ = getAimAttackTarget(this);
		if(canHitWorldPickAxe(this,HitPos) && targ is null)this.Tag("draw_cursor");
		if(targ !is null)this.set_u16("picking_target",targ.getNetworkID());
		
	} else this.set_s16(drawback_string,0);
		
	if(this.get_s16(drawback_string) != 0)this.set_u8(type+"_implement", 4);
}

void DoPickHack(CBlob@ this, CBlob @item, f32 damage, u8 hitter)
{
	if (!getNet().isServer() || getKnocked(this) > 0)
	{
		return;
	}

	CMap@ map = this.getMap();
	Vec2f Aim = this.getAimPos();

	CBlob @hitterBlob = this;
	if(item !is null)@hitterBlob = item;
	
	CBlob @target = getAimAttackTarget(this);
	if(target !is null){
		hitterBlob.server_Hit(target, Aim, Vec2f(0,0), damage, hitter, true);
		return;
	}

	///World destruction logics:
	Vec2f HitPos = this.getAimPos();
	map.rayCastSolidNoBlobs(this.getPosition(),Aim,HitPos);
	
	if(canHitWorldPickAxe(this,HitPos)){
	
		hitterBlob.server_HitMap(HitPos, Vec2f(0,0), damage, Hitters::pick);
	
		return;
	
	}
}

bool canHitWorldPickAxe(CBlob@ this, Vec2f position){
	
	position = getMap().getAlignedWorldPos(position)+Vec2f(4,4);
	
	CMap@ map = getMap();
	
	Vec2f Direction = position-this.getPosition();
    Direction.Normalize();
	
	float Distance = Maths::Sqrt(Maths::Pow(position.x-this.getPosition().x,2)+Maths::Pow(position.y-this.getPosition().y,2));
	
	if(map.rayCastSolid(this.getPosition(), position-Direction*8) || Distance > 32.0f){
	
		return false;
	
	}
	
	TileType tile = map.getTile(position).type;
	
	if(map.isTileSolid(tile) || (map.isTileBackground(map.getTile(position)) && !map.isTileGroundBack(tile)) || tile > 300)return true;
	
	return false;

}