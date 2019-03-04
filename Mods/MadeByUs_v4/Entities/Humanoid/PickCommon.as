
#include "Requirements.as";
#include "BuilderCommon.as";


//if(ismyplayer)
//{
//	Pickaxe(this);
//}

const s32 hit_frame = 2;
const f32 hit_damage = 3.0f;

//helper class to reduce function definition cancer
//and allow passing primitives &inout
class SortHitsParams
{
	Vec2f aimPos;
	Vec2f tilepos;
	Vec2f pos;
	bool justCheck;
	bool extra;
	bool hasHit;
	HitInfo@ bestinfo;
	f32 bestDistance;
};

void Pickaxe(CBlob@ this)
{
	HitData@ hitdata;
	CSprite @sprite = this.getSprite();
	bool strikeAnim = true;//sprite.isAnimation("strike");

	this.Tag("pickaxing");
	
	if(!strikeAnim)
	{
		this.get("hitdata", @hitdata);
		hitdata.blobID = 0;
		hitdata.tilepos = Vec2f_zero;
		return;
	}

	this.set_s16("pick_counter",this.get_s16("pick_counter")+1);
	if(this.get_s16("pick_counter") > 10)this.set_s16("pick_counter",0);
	
	// no damage cause we just check hit for cursor display
	bool justCheck = this.get_s16("pick_counter")/5 != hit_frame;
	bool adjusttime = this.get_s16("pick_counter")/5 < hit_frame - 1;

	// pickaxe!

	this.get("hitdata", @hitdata);

	if(hitdata is null) return;

	Vec2f blobPos = this.getPosition();
	Vec2f aimPos = this.getAimPos();
	Vec2f aimDir = aimPos - blobPos;

	// get tile surface for aiming at little static blobs
	Vec2f normal = aimDir;
	normal.Normalize();

	Vec2f attackVel = normal;

	if (!adjusttime)
	{
		if (!justCheck)
		{
			if (hitdata.blobID == 0)
			{
				SendHitCommand(this, null, hitdata.tilepos, attackVel, hit_damage);
			}
			else
			{
				CBlob@ b = getBlobByNetworkID(hitdata.blobID);
				if (b !is null)
				{
					SendHitCommand(this, b, (b.getPosition() + this.getPosition()) * 0.5f, attackVel, hit_damage);
				}
			}
		}
		return;
	}

	hitdata.blobID = 0;
	hitdata.tilepos = Vec2f_zero;

	f32 arcdegrees = 90.0f;

	f32 aimangle = aimDir.Angle();
	Vec2f pos = blobPos - Vec2f(2, 0).RotateBy(-aimangle);
	f32 attack_distance = this.getRadius() + 12;
	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;

	bool hasHit = false;

	const f32 tile_attack_distance = attack_distance * 1.5f;
	Vec2f tilepos = blobPos + normal * Maths::Min(aimDir.Length() - 1, tile_attack_distance);
	Vec2f surfacepos;
	map.rayCastSolid(blobPos, tilepos, surfacepos);

	Vec2f surfaceoff = (tilepos - surfacepos);
	f32 surfacedist = surfaceoff.Normalize();
	tilepos = (surfacepos + (surfaceoff * (map.tilesize * 0.5f)));

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@ bestinfo = null;
	f32 bestDistance = 100000.0f;

	HitInfo@[] hitInfos;

	//setup params for ferrying data in/out
	SortHitsParams@ hit_p = SortHitsParams();

	//copy in
	hit_p.aimPos = aimPos;
	hit_p.tilepos = tilepos;
	hit_p.pos = pos;
	hit_p.justCheck = justCheck;
	hit_p.extra = true;
	hit_p.hasHit = hasHit;
	@(hit_p.bestinfo) = bestinfo;
	hit_p.bestDistance = bestDistance;

	if (map.getHitInfosFromArc(pos, -aimangle, arcdegrees, attack_distance, this, @hitInfos))
	{
		SortHits(this, hitInfos, hit_damage, hit_p);
	}

	aimPos = hit_p.aimPos;
	tilepos = hit_p.tilepos;
	pos = hit_p.pos;
	justCheck = hit_p.justCheck;
	hasHit = hit_p.hasHit;
	@bestinfo = hit_p.bestinfo;
	bestDistance = hit_p.bestDistance;

	bool noBuildZone = map.getSectorAtPosition(tilepos, "no build") !is null;
	bool isgrass = false;

	if ((tilepos - aimPos).Length() < bestDistance - 4.0f && map.getBlobAtPosition(tilepos) is null)
	{
		Tile tile = map.getTile(surfacepos);

		if (!noBuildZone && !map.isTileGroundBack(tile.type))
		{
			//normal, honest to god tile
			if (map.isTileBackgroundNonEmpty(tile) || map.isTileSolid(tile))
			{
				hasHit = true;
				hitdata.tilepos = tilepos;
			}
			else if (map.isTileGrass(tile.type))
			{
				//NOT hashit - check last for grass
				isgrass = true;
			}
		}
	}

	if (!hasHit)
	{
		//copy in
		hit_p.aimPos = aimPos;
		hit_p.tilepos = tilepos;
		hit_p.pos = pos;
		hit_p.justCheck = justCheck;
		hit_p.extra = false;
		hit_p.hasHit = hasHit;
		@(hit_p.bestinfo) = bestinfo;
		hit_p.bestDistance = bestDistance;

		//try to find another possible one
		if (bestinfo is null)
		{
			SortHits(this, hitInfos, hit_damage, hit_p);
		}

		//copy out
		aimPos = hit_p.aimPos;
		tilepos = hit_p.tilepos;
		pos = hit_p.pos;
		justCheck = hit_p.justCheck;
		hasHit = hit_p.hasHit;
		@bestinfo = hit_p.bestinfo;
		bestDistance = hit_p.bestDistance;

		//did we find one (or have one from before?)
		if (bestinfo !is null)
		{
			hitdata.blobID = bestinfo.blob.getNetworkID();
		}
	}

	if (isgrass && bestinfo is null)
	{
		hitdata.tilepos = tilepos;
	}
}

void SendHitCommand(CBlob@ this, CBlob@ blob, const Vec2f tilepos, const Vec2f attackVel, const f32 attack_power)
{
	CBitStream params;
	params.write_netid(blob is null? 0 : blob.getNetworkID());
	params.write_Vec2f(tilepos);
	params.write_Vec2f(attackVel);
	params.write_f32(attack_power);

	this.SendCommand(this.getCommandID("pickaxe"), params);
}

bool RecdHitCommand(CBlob@ this, CBitStream@ params)
{
	u16 blobID;
	Vec2f tilepos, attackVel;
	f32 attack_power;

	if(!params.saferead_netid(blobID))
		return false;
	if(!params.saferead_Vec2f(tilepos))
		return false;
	if(!params.saferead_Vec2f(attackVel))
		return false;
	if(!params.saferead_f32(attack_power))
		return false;

	if(blobID == 0)
	{
		CMap@ map = getMap();
		if(map !is null)
		{
			if(map.getSectorAtPosition(tilepos, "no build") is null)
			{
				this.server_HitMap(tilepos, attackVel, 1.0f, Hitters::builder);
			}
		}
	}
	else
	{
		CBlob@ blob = getBlobByNetworkID(blobID);
		if(blob !is null)
		{
			bool isdead = blob.hasTag("dead");

			if(isdead) //double damage to corpses
			{
				attack_power *= 2.0f;
			}

			const bool teamHurt = !blob.hasTag("flesh") || isdead;
			this.server_Hit(blob, tilepos, attackVel, attack_power, Hitters::builder, teamHurt);
		}
	}

	return true;
}

void SortHits(CBlob@ this, HitInfo@[]@ hitInfos, f32 damage, SortHitsParams@ p)
{
	//HitInfo objects are sorted, first come closest hits
	for (uint i = 0; i < hitInfos.length; i++)
	{
		HitInfo@ hi = hitInfos[i];

		CBlob@ b = hi.blob;
		if (b !is null) // blob
		{
			if (!canHit(this, b, p.tilepos, p.extra))
			{
				continue;
			}

			if (!p.justCheck)
			{
				p.hasHit = true;
				SendHitCommand(this, hi.blob, hi.hitpos, hi.blob.getPosition() - p.pos, damage);
			}
			else
			{
				bool never_ambig = false;//neverHitAmbiguous(b);
				f32 len = never_ambig ? 1000.0f : (p.aimPos - b.getPosition()).Length();
				if (len < p.bestDistance)
				{
					if (!never_ambig)
						p.bestDistance = len;

					@(p.bestinfo) = hi;
				}
			}
		}
	}
}

bool canHit(CBlob@ this, CBlob@ b, Vec2f tpos, bool extra = true)
{

	if(b.hasTag("invincible"))
	{
		return false;
	}

	if(b.getTeamNum() == this.getTeamNum())
	{
		//no hitting friendly carried stuff
		if(b.isAttached())
			return false;

		//yes hitting corpses
		if(b.hasTag("dead"))
			return true;

		//no hitting friendly mines (grif)
		if(b.getName() == "mine")
			return false;

		//no hitting friendly living stuff
		if(b.hasTag("flesh") || b.hasTag("player"))
			return false;
	}
	//no hitting stuff in hands
	else if(b.isAttached() && !b.hasTag("player"))
	{
		return false;
	}

	//static/background stuff
	CShape@ b_shape = b.getShape();
	if(!b.isCollidable() || (b_shape !is null && b_shape.isStatic()))
	{
		//maybe we shouldn't hit this..
		//check if we should always hit
			if(!b.isCollidable())
			{
				//TODO: use a better overlap check here
				//this causes issues with quarters and
				//any other case where you "stop overlapping"
				if(!this.isOverlapping(b))
					return false;
			}
			return true;
		//otherwise no hit
		return false;
	}

	return true;
}

/*
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("pickaxe"))
	{
		if(!RecdHitCommand(this, params))
			warn("error when recieving pickaxe command");
	}
}*/