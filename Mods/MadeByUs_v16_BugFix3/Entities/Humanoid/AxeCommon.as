void ManageAxe(CBlob @this, bool holding, string type){

	CBlob @item = getEquippedBlob(this,type+"_arm");

	float damage = getItemDamage(item);

	if(holding){
		if(this.get_s16(type+"_axe_drawback") < 15)this.set_s16(type+"_axe_drawback",this.get_s16(type+"_axe_drawback")+1);
		else {
			DoHack(this,damage,-getAimAngle(this),40);
			if(this.get_s16(type+"_axe_drawback") > 0)this.set_s16(type+"_axe_drawback",0);
			if(this.get_s16(type+"_axe_drawback") < 0)this.set_s16(type+"_axe_drawback",0);
		}
		
		if(canHitWorldAxe(this,this.getAimPos()))this.Tag("draw_cursor");
		
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

	CMap@ map = this.getMap();
	Vec2f Aim = this.getAimPos();
	
	////World destruction logics:
	
	
	
	if(canHitWorldAxe(this,Aim)){
	
		this.server_HitMap(Aim, Vec2f(0,0), damage, Hitters::saw);
	
		return;
	
	}
	
	
	////If we didn't hit the world, hit blobs:
	
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
					this.server_Hit(b, hi.hitpos, velocity/10, damage, Hitters::saw, true);  // server_Hit() is server-side only
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

