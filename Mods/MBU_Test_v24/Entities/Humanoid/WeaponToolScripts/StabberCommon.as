#include "Ally.as"
#include "Knocked.as";
#include "HumanoidCommon.as";

void ManageStabber(CBlob @this, CBlob @item, bool holding, string type){

	string drawback_string = type+"_drawback";

	float damage = 2;
	int hitter = Hitters::stab;
	int speed = 5;
	
	if(item !is null){
		damage = item.get_f32("damage");
		if(item.exists("hitter"))hitter = item.get_u8("hitter");
		speed = item.get_u8("speed");
	}
	
	damage *= getStrength(this,type+"_arm");

	if(holding){
		if(this.get_s16(drawback_string) < 55)this.add_s16(drawback_string,speed);
		if(this.get_s16(drawback_string) < 0)this.set_s16(drawback_string,0);
	} else {
		if(this.get_s16(drawback_string) < 0)this.add_s16(drawback_string,25);
		if(this.get_s16(drawback_string) > 50){
			DoStab(this,item,damage,-getAimAngle(this),90,hitter);
			this.set_s16(drawback_string,-100);
		}
		if(this.get_s16(drawback_string) > 0)this.set_s16(drawback_string,0);
	}
	
	if(this.get_s16(drawback_string) != 0)this.set_u8(type+"_implement", 5);
}

void DoStab(CBlob@ this, CBlob @item, f32 damage, f32 aimangle, f32 arcdegrees, u8 hitter)
{
	if (!getNet().isServer() || getKnocked(this) > 0)
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(14 + (1.75f * this.getShape().vellen),26);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	CBlob @hitterBlob = this;
	if(item !is null)@hitterBlob = item;
	
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

				//big things block attacks
				const bool large = !b.isAttached() && b.isCollidable();

				if (!canHitStabber(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (!dontHitMore)
				{
					hitterBlob.server_Hit(b, hi.hitpos, Vec2f(0,0), damage, hitter, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
		}
	}
}

bool canHitStabber(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return checkAlly(this.getTeamNum(),b.getTeamNum()) != 2;

}