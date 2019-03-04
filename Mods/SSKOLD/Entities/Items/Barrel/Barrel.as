#include "Hitters.as";
#include "LimitedAttacks.as";
#include "SSKMovesetCommon.as";
#include "MakeDustParticle.as"

const array<string> ITEMS_LIST =
{
	"bomb",
	"waterbomb",
	"keg",
	"mine",
	"boulder",
	"green_shell",
	"smart_bomb",
	"food",
	"steak",
	"drill",
	"grenade"
};

const int pierce_amount = 8;

const f32 hit_amount_ground = 0.5f;
const f32 hit_amount_air = 1.0f;
const f32 hit_amount_air_fast = 3.0f;
const f32 hit_amount_cata = 10.0f;

const f32 BARREL_SPEED = 3.0f;
const f32 BOUNCE_SPEED = 7.0f;
const u16 LIFETIME = 30;
const u8 ITEM_COUNT = 2;
const f32 ITEM_VEL = 4.0f;

void onInit(CBlob @ this)
{
	this.set_u8("launch team", 255);
	this.server_setTeamNum(-1);
	this.Tag("heavy weight");
	this.Tag("ignore fall");

	LimitedAttack_setup(this);

	this.set_u8("blocks_pierced", 0);
	u32[] tileOffsets;
	this.set("tileOffsets", tileOffsets);

	this.set_bool("isRolling", false);
	this.addCommandID("sync state");

	this.SetMapEdgeFlags( u8(CBlob::map_collide_none) | u8(CBlob::map_collide_nodeath) );	// fall out of map in every direction

	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
    const u16 mapWidth = map.tilemapwidth * map.tilesize;
    const u16 mapHeight = map.tilemapheight * map.tilesize;

	//rock and roll mode
	if (!this.getShape().getConsts().collidable)
	{
		Vec2f vel = this.getVelocity();
		f32 angle = vel.Angle();
		Slam(this, angle, vel, this.getShape().vellen * 1.5f);
	}

	bool isRolling = this.get_bool("isRolling");
	if (isRolling) //not sliding
    {	
  		const f32 ts = map.tilesize;
		const f32 y_ts = ts * 1.6f;
		const f32 x_ts = ts * 1.9f;

		this.getSprite().SetAnimation("roll");	

    	if (this.isFacingLeft())
    	{
    		this.setVelocity(Vec2f( -BARREL_SPEED, this.getVelocity().y ));

    		if ( (pos.x - x_ts) > 0)
    		{
	    		bool surface_left = map.isTileSolid(pos + Vec2f(-x_ts, -y_ts)) || map.isTileSolid(pos + Vec2f(-x_ts, 0)) || map.isTileSolid(pos + Vec2f(-x_ts, y_ts));
	    		if (surface_left)
	    		{
					if (getNet().isServer())
					{
						this.SetFacingLeft(false);	
						SyncState(this);
					}
					this.getSprite().PlayRandomSound("/WoodHeavyBump", 1.0f);
	    		}
    		}
    	}
    	else
    	{
    		this.setVelocity(Vec2f( BARREL_SPEED, this.getVelocity().y ));

    		if ( (pos.x + x_ts) < mapWidth)
    		{
	    		bool surface_right = map.isTileSolid(pos + Vec2f(x_ts, -y_ts)) || map.isTileSolid(pos + Vec2f(x_ts, 0)) || map.isTileSolid(pos + Vec2f(x_ts, y_ts));
	    		if (surface_right)
	    		{
					if (getNet().isServer())
					{
						this.SetFacingLeft(true);	
						SyncState(this);
					}
					this.getSprite().PlayRandomSound("/WoodHeavyBump", 1.0f);
	    		}
	    	}
    	}

    	// bounce
		//bool surface_below = map.isTileSolid(pos + Vec2f(y_ts, x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts, x_ts));
		if (this.isOnGround())
		{
			this.setVelocity(Vec2f( this.getVelocity().x, -BOUNCE_SPEED ));
			this.getSprite().PlayRandomSound("/WoodHeavyHit", 1.0f);
			ParticleAnimated( "Sprites/dust.png",
							pos,
							Vec2f(0.0,0.0f),
							1.0f, 1.0f, 
							3, 
							0.0f, true );
		}
    }
    else
    {
    	this.getSprite().SetAnimation("default");	
    }

    // die when falling below map
   	if (pos.y > mapHeight)
	{
		this.server_Die();
	}

	// warp to at sides of map
   	if (pos.x < 0)
	{
		this.setPosition(Vec2f(mapWidth, pos.y));
	}	
   	else if (pos.x > mapWidth)
	{
		this.setPosition(Vec2f(0, pos.y));
	}	
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached.getName() == "catapult") // rock n' roll baby
	{
		this.getShape().getConsts().mapCollisions = false;
		this.getShape().getConsts().collidable = false;
		this.getCurrentScript().tickFrequency = 3;
	}
	this.set_u8("launch team", detached.getTeamNum());

	if (getNet().isServer())
	{
		this.set_bool("isRolling", true);	

		SyncState(this);
	}

	this.server_SetTimeToDie( LIFETIME );
}

void SyncState( CBlob@ this )
{
	bool isRolling = this.get_bool( "isRolling" );	
	bool isFacingLeft = this.isFacingLeft();	
	CBitStream bt;
	bt.write_bool( isRolling );	
	bt.write_bool( isFacingLeft );	
	this.SendCommand( this.getCommandID("sync state"), bt );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if( cmd == this.getCommandID("sync state") )
    {
		bool isRolling = params.read_bool();
		bool isFacingLeft = params.read_bool();
		this.set_bool("isRolling", isRolling);
		this.SetFacingLeft(isFacingLeft);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if(attached.getPlayer() !is null)
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
	}

	if (attached.getName() != "catapult") // end of rock and roll
	{
		this.getShape().getConsts().mapCollisions = true;
		this.getShape().getConsts().collidable = true;
		this.getCurrentScript().tickFrequency = 1;
	}
	this.set_u8("launch team", attached.getTeamNum());
}

void Slam(CBlob @this, f32 angle, Vec2f vel, f32 vellen)
{
	if (!this.get_bool("isRolling"))
		return;

	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	HitInfo@[] hitInfos;
	u8 team = this.get_u8("launch team");

	if (map.getHitInfosFromArc(pos, -angle, 30, vellen, this, false, @hitInfos))
	{
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			f32 dmg = 10.0f;

			if (hi.blob is null) // map
			{
				if (BoulderHitMap(this, hi.hitpos, hi.tileOffset, vel, dmg, Hitters::cata_boulder))
					return;
			}
			else if (team != u8(hi.blob.getTeamNum()))
			{
				CustomHitData customHitData(10, 4.0f, 0.04f);
				server_customHit(this, hi.blob, pos, Vec2f(vel.x, vel.y*0.4f), dmg, Hitters::cata_boulder, true, customHitData);

				// die when hit something large
				if (hi.blob.getRadius() > 32.0f)
				{
					//this.server_Hit(this, pos, vel, 30, Hitters::cata_boulder, true);
				}
			}
		}
	}

	// chew through backwalls

	Tile tile = map.getTile(pos);
	if (map.isTileBackgroundNonEmpty(tile))
	{
		if (map.getSectorAtPosition(pos, "no build") !is null)
		{
			return;
		}
		map.server_DestroyTile(pos + Vec2f(7.0f, 7.0f), 10.0f, this);
		map.server_DestroyTile(pos - Vec2f(7.0f, 7.0f), 10.0f, this);
	}
}

bool BoulderHitMap(CBlob@ this, Vec2f worldPoint, int tileOffset, Vec2f velocity, f32 damage, u8 customData)
{
	//check if we've already hit this tile
	u32[]@ offsets;
	this.get("tileOffsets", @offsets);

	if (offsets.find(tileOffset) >= 0) { return false; }

	this.getSprite().PlaySound("ArrowHitGroundFast.ogg");
	f32 angle = velocity.Angle();
	CMap@ map = getMap();
	TileType t = map.getTile(tileOffset).type;
	u8 blocks_pierced = this.get_u8("blocks_pierced");
	bool stuck = false;

	if (map.isTileCastle(t) || map.isTileWood(t))
	{
		Vec2f tpos = this.getMap().getTileWorldPosition(tileOffset);
		if (map.getSectorAtPosition(tpos, "no build") !is null)
		{
			return false;
		}

		//make a shower of gibs here

		map.server_DestroyTile(tpos, 100.0f, this);
		Vec2f vel = this.getVelocity();
		this.setVelocity(vel * 0.8f); //damp
		this.push("tileOffsets", tileOffset);

		if (blocks_pierced < pierce_amount)
		{
			blocks_pierced++;
			this.set_u8("blocks_pierced", blocks_pierced);
		}
		else
		{
			stuck = true;
		}
	}
	else
	{
		stuck = true;
	}

	if (velocity.LengthSquared() < 5)
		stuck = true;

	if (stuck)
	{
		//this.server_Hit(this, worldPoint, velocity, 10, Hitters::crush, true);
	}

	return stuck;
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!this.get_bool("isRolling"))
		return;
	
	if (solid && blob !is null)
	{
		Vec2f hitvel = this.getVelocity();
		Vec2f hitvec = point1 - this.getPosition();
		f32 coef = hitvec * hitvel;

		if (coef < 0.706f) // check we were flying at it
		{
			return;
		}

		f32 vellen = hitvel.Length();

		u8 tteam = this.get_u8("launch team");
		CPlayer@ damageowner = this.getDamageOwnerPlayer();

		//not hitting static stuff
		if (blob.getShape() !is null && blob.getShape().isStatic())
		{
			return;
		}

		//hitting less or similar mass
		if (this.getMass() < blob.getMass() - 1.0f)
		{
			return;
		}

		//get the dmg required
		hitvel.Normalize();
		f32 dmg = vellen > 8.0f ? 30.0f : (vellen > 4.0f ? 20.0f : 10.0f);

		//bounce off if not gibbed
		if(dmg < 4.0f)
		{
			this.setVelocity(blob.getOldVelocity() + hitvec * -Maths::Min(dmg * 0.33f, 1.0f));
		}

		//hurt
		if (blob.getName() == "barrel")
		{
			this.server_Hit(blob, point1, hitvel, 0.5f, Hitters::cata_boulder, true);	
		}
		else
		{
			CustomHitData customHitData(6, 4.0f, 0.04f);
			server_customHit(this, blob, point1, Vec2f(hitvel.x, hitvel.y*0.4f), dmg, Hitters::cata_boulder, true, customHitData);			
		}

		return;

	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return damage *= 0.5f;
	}

	if (hitterBlob.getName() == "barrel" && hitterBlob.get_bool("isRolling"))
	{
		if (getNet().isServer())
		{
			this.set_bool("isRolling", true);
			this.SetFacingLeft(!this.isFacingLeft());	
			SyncState(this);
		}
		this.server_SetTimeToDie( LIFETIME );
		this.getSprite().PlayRandomSound("/WoodHeavyBump", 1.0f);		
	}

	return damage;
}

//sprite

void onInit(CSprite@ this)
{
	this.animation.frame = (this.getBlob().getNetworkID() % 4);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (!this.get_bool("isRolling"));
}

// spawn random items!
void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		for (int i = 0; i < ITEM_COUNT; i++)
	    {
	        string randomItemName = ITEMS_LIST[XORRandom(ITEMS_LIST.length())];
			CBlob @blob = server_CreateBlob(randomItemName, -1, this.getPosition());
			if (blob !is null)
			{
				blob.Tag("Item");

				if (blob.getName() == "bomb")
				{
					blob.Tag("activated");
				}

				Vec2f randVel = getRandomVelocity(0.0f, ITEM_VEL, 360.0f);
				blob.setVelocity(randVel);
			}
	    }		
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	string name = blob.getName();
	if (name == "barrel" && this.get_bool("isRolling"))
	{
		return false;
	}

	return true;
}
