void ManagePick(CBlob @this, bool holding, string type){

	CBlob @item = getEquippedBlob(this,type+"_arm");

	if(item is null)return;
	
	float damage = item.get_f32("damage");

	if(holding){
		if(this.get_s16(type+"_drawback") < 30)this.set_s16(type+"_drawback",this.get_s16(type+"_drawback")+1+item.get_u8("speed"));
		else {
			DoPick(this,damage,-getAimAngle(this),60,item);
			if(this.get_s16(type+"_drawback") > 0)this.set_s16(type+"_drawback",0);
			if(this.get_s16(type+"_drawback") < 0)this.set_s16(type+"_drawback",0);
		}
		Vec2f HitPos = this.getAimPos();
		getMap().rayCastSolidNoBlobs(this.getPosition(),this.getAimPos(),HitPos);
		if(canHitWorldPick(this,HitPos,item))this.Tag("draw_cursor");
		
	} else this.set_s16(type+"_drawback",0);
		
	if(this.get_s16(type+"_drawback") != 0)this.Tag(type+"_pickaxing");
	else if(this.hasTag(type+"_pickaxing"))this.Untag(type+"_pickaxing");
	
	
}

void DoPick(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, CBlob @item)
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
	
	////World destruction logics:
	
	
	this.Untag("draw_cursor");
	if(canHitWorldPick(this,HitPos,item)){
	
		this.server_HitMap(HitPos, Vec2f(0,0), damage, Hitters::builder);
		this.Tag("draw_cursor");
		return;
	
	}
	
	
	///If we didn't hit the world, hit blobs:
	
	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(20 + (1.5f * this.getShape().vellen),40);

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

				//big things block attacks
				const bool large = !b.isAttached() && b.isCollidable();

				if (!canHitPick(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity/10, damage, Hitters::builder, true);  // server_Hit() is server-side only
					CSprite @sprite = this.getSprite();
				}
			}
		}
	}
}

bool canHitPick(CBlob@ this, CBlob@ b)
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

bool canHitWorldPick(CBlob@ this, Vec2f position, CBlob@ item){
	
	string name = "pick";
	
	if(item !is null)name = item.getName();
	
	position = getMap().getAlignedWorldPos(position)+Vec2f(4,4);
	
	CMap@ map = getMap();
	
	Vec2f Direction = position-this.getPosition();
    Direction.Normalize();
	
	float Distance = Maths::Sqrt(Maths::Pow(position.x-this.getPosition().x,2)+Maths::Pow(position.y-this.getPosition().y,2));
	
	if(map.rayCastSolid(this.getPosition(), position-Direction*8) || Distance > 32.0f){
	
		return false;
	
	}
	
	TileType tile = map.getTile(position).type;
	
	if(name == "pick")if(map.isTileSolid(tile) || (map.isTileBackground(map.getTile(position)) && !map.isTileGroundBack(tile)))return true;
	
	if(name == "hammer")if(map.isTileCastle(tile) || map.isTileWood(tile) || (map.isTileBackground(map.getTile(position)) && !map.isTileGroundBack(tile)))return true;
	
	return false;

}