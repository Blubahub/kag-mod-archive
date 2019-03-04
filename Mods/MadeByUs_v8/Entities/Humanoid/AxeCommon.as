void ManageAxe(CBlob @this, bool holding, string type){

	if(holding){
		if(this.get_s16(type+"_axe_drawback") < 15)this.set_s16(type+"_axe_drawback",this.get_s16(type+"_axe_drawback")+1);
		else {
			DoHack(this,4.0,-getAimAngle(this),40);
			if(this.get_s16(type+"_axe_drawback") > 0)this.set_s16(type+"_axe_drawback",0);
			if(this.get_s16(type+"_axe_drawback") < 0)this.set_s16(type+"_axe_drawback",0);
		}
	} else this.set_s16(type+"_axe_drawback",0);
		
	if(this.get_s16(type+"_axe_drawback") != 0)this.Tag(type+"_axeing");
	else if(this.hasTag(type+"_axeing"))this.Untag(type+"_axeing");
}

void DoHack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees)
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

	f32 attack_distance = Maths::Min(12 + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), 16);

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

				if (!canHitaxe(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity/10, damage, Hitters::saw, true);  // server_Hit() is server-side only
					CSprite @sprite = this.getSprite();
				}
			}
		}
	}
}

bool canHitaxe(CBlob@ this, CBlob@ b)
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