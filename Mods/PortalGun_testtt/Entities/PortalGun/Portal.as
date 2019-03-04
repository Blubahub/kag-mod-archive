#include "TeamColour.as"; // probs should take this out and set light in portalbullet.as.

const f32 MIN_EXIT_VELOCITY = 5.0f; // makes a blob pop out higher.
const f32 MAX_EXIT_VELOCITY = 20.0f; // prevents round the world trips in one jump.

void onInit( CBlob@ this )
{
	this.SetLight(true);
	this.SetLightColor(getTeamColor(this.getTeamNum()));
	this.SetLightRadius(32.0f);
	this.getSprite().SetZ(1000.0f);
	
	CShape@ shape = this.getShape();
	shape.getConsts().net_threshold_multiplier = 4.0f;
	this.setAngleDegrees( this.get_f32("pangle"));
	shape.SetStatic(true);
	this.Tag("no falldamage");
}

CBlob@ getBlob(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (!b.getShape().isStatic() && b.getName() != "portalbullet")
			{
				return b;
			}
		}
	}
	return null;
}

CBlob@ getPortal(CBlob@ this)
{	
	CMap@ map = this.getMap();
	const u16 mapWidth = map.tilemapwidth * map.tilesize;
	const u16 mapHeight = map.tilemapheight * map.tilesize;
	Vec2f br = Vec2f(mapWidth,mapHeight);
	CBlob@[] blobs;
	map.getBlobsInBox(Vec2f_zero, br, @blobs);
	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ p = blobs[i];
				
		if (p.getName() == "portal" && p.getTeamNum() != this.getTeamNum() && p.get_u16( "ownerID") == this.get_u16( "ownerID") )
		{
			return p;			
		}
	}
	return null;
}

void onTick(CBlob@ this)
{	
	if (getGameTime() % 10 == 0) // not sure when this is nessesary, why not.
	{
		TileCheck(this); // check if portal are being supported or overlapped.
	}

	CBlob@ portal = getPortal(this); // get the other portal.
	if(portal !is null)
	{
		CBlob @blob = getBlob(this); // get the blob we want to teleport.
		if(blob !is null)
		{		
			if (getGameTime() > blob.get_u32("portal timer") + 4) // prevent being teleported agian straight away.
			{
				Vec2f velocity_old = blob.getOldVelocity();
				Vec2f exitVelocity = Vec2f(velocity_old.x/2, Maths::Min(Maths::Max(velocity_old.y, MIN_EXIT_VELOCITY), MAX_EXIT_VELOCITY));
				f32 pangle = portal.getAngleDegrees();						

				Vec2f dir = Vec2f(4.0f, 0.0f); // offset out from the exit portal.
				dir.RotateBy(pangle);
				float velangle = dir.AngleWith(velocity_old);

				blob.setPosition(portal.getPosition()+dir);
				blob.setVelocity(exitVelocity.RotateBy(pangle-90));

				blob.set_u32("portal timer", getGameTime()); 
			}
		}
	}	
}

void TileCheck(CBlob@ this) // blob check?
{
	f32 angle = this.getAngleDegrees();
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	const f32 ts = map.tilesize;

	Vec2f off = Vec2f(pos + Vec2f(-ts, 0).RotateBy(angle));
	Vec2f upperoff = Vec2f(pos + Vec2f(-ts, -ts).RotateBy(angle));
	Vec2f loweroff = Vec2f(pos + Vec2f(-ts, ts).RotateBy(angle));
	Vec2f uppermid = Vec2f(pos + Vec2f(0, -ts).RotateBy(angle));
	Vec2f lowermid = Vec2f(pos + Vec2f(0, ts).RotateBy(angle));

	bool hastilespaces = (!map.isTileSolid(pos) && map.isTileSolid(off) && map.isTileSolid(upperoff)
				 && map.isTileSolid(loweroff) && !map.isTileSolid(uppermid) && !map.isTileSolid(lowermid));
	if (!hastilespaces)
	{
		this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("/PortalDie");
}