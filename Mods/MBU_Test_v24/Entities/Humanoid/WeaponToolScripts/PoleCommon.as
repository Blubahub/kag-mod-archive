#include "Ally.as"
#include "Knocked.as";
#include "HumanoidCommon.as";

void ManagePole(CBlob @this, CBlob @item, bool holding, string type){

	string drawback_string = type+"_drawback";

	float damage = 2;
	int hitter = Hitters::muscles;
	int speed = 5;
	
	if(item !is null){
		damage = item.get_f32("damage");
		if(item.exists("hitter"))hitter = item.get_u8("hitter");
		speed = item.get_u8("speed");
	}
	
	damage *= getStrength(this,type+"_arm");

	if(holding){
		if(this.get_s16(drawback_string) < 100)this.add_s16(drawback_string,speed);
		if(this.get_s16(drawback_string) < 0)this.set_s16(drawback_string,0);
	} else {
		if(this.get_s16(drawback_string) > 50){
			DoWhack(this,item,f32(this.get_s16(drawback_string)-10)/10.0f*(damage*0.75f)+(damage*0.25f),-getAimAngle(this),40, hitter);
			this.set_s16(drawback_string,-450);
		}
		if(this.get_s16(drawback_string) > 0)this.set_s16(drawback_string,0);
		if(this.get_s16(drawback_string) < 0)this.add_s16(drawback_string,30);
	}
	
	if(this.get_s16(drawback_string) != 0)this.set_u8(type+"_implement", 2);
}

void DoWhack(CBlob@ this, CBlob @item, f32 damage, f32 aimangle, f32 arcdegrees, u8 hitter)
{
	if(getKnocked(this) > 0)return;

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
	
	Vec2f inertia(-2.5f, 0);
	inertia.RotateBy(aimangle);
	Vec2f reverseinertia(Maths::Max(-1.5f*this.getVelocity().Length(),-7.0f), 0);
	reverseinertia.RotateBy(aimangle);
	Vec2f vaultinertia(-2, 0);
	vaultinertia.RotateBy(aimangle);
	
	this.setVelocity(Vec2f(this.getVelocity().x,Maths::Max(this.getVelocity().y,0))+inertia);

	f32 attack_distance = Maths::Min(26 + (2.5f * this.getShape().vellen),52);

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

				if (!canHitPole(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (getNet().isServer())
				if (!dontHitMore)
				{
					Vec2f knockback(3, 0);
					knockback.RotateBy(aimangle);
					hitterBlob.server_Hit(b, hi.hitpos, knockback, damage, Hitters::muscles, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else  // hitmap
				if (!dontHitMoreMap)
				{
					this.setVelocity(this.getVelocity()+vaultinertia);
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					if (getNet().isServer())
					if (ground || wood || dirt_stone || gold)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);
						f32 tileangle = offset.Angle();
						f32 dif = Maths::Abs(exact_aimangle - tileangle);
						if (dif > 180)
							dif -= 360;
						if (dif < -180)
							dif += 360;

						dif = Maths::Abs(dif);
						//print("dif: "+dif);

						if (dif < 20.0f)
						{
							//detect corner

							int check_x = -(offset.x > 0 ? -1 : 1);
							int check_y = -(offset.y > 0 ? -1 : 1);
							if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
							        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
								continue;

							bool canhit = true; //default true if not jab
							
							//info.tileDestructionLimiter++;
							//canhit = ((info.tileDestructionLimiter % ((wood || dirt_stone) ? 3 : 2)) == 0);

							//dont dig through no build zones
							canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

							dontHitMoreMap = true;
							if (canhit)
							{
								//map.server_DestroyTile(hi.hitpos, 0.1f, this);
								hitterBlob.server_HitMap(hi.hitpos, Vec2f(0,0), 1.0f, Hitters::builder);
							}
						}
					}
				}
		}
	}
}

bool canHitPole(CBlob@ this, CBlob@ b)
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