void ManageStabber(CBlob @this, bool holding, string type){

	CBlob @item = getEquippedBlob(this,type+"_arm");

	if(item is null)return;
	
	float damage = item.get_f32("damage");

	if(holding){
		if(this.get_s16(type+"_drawback") < 11)this.set_s16(type+"_drawback",this.get_s16(type+"_drawback")+1);
		if(this.get_s16(type+"_drawback") < 0)this.set_s16(type+"_drawback",0);
	} else {
		if(this.get_s16(type+"_drawback") < 0)this.set_s16(type+"_drawback",this.get_s16(type+"_drawback")+5);
		if(this.get_s16(type+"_drawback") > 10){
			DoStab(this,damage,-getAimAngle(this),90);
			this.set_s16(type+"_drawback",-20);
		}
		if(this.get_s16(type+"_drawback") > 0)this.set_s16(type+"_drawback",0);
	}
	if(this.get_s16(type+"_drawback") != 0)this.Tag(type+"_stabing");
	else if(this.hasTag(type+"_stabing"))this.Untag(type+"_stabing");
}

void DoStab(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees)
{
	if (!getNet().isServer())
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
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, Hitters::stab, true);  // server_Hit() is server-side only
					CSprite @sprite = this.getSprite();

					
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

	return b.getTeamNum() != this.getTeamNum();

}