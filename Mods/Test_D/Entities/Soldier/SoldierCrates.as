#include "SoldierCommon.as"
#include "SoldierPlace.as"
#include "MapCommon.as"
#include "HoverMessage.as"

const int CRATES = 8;
const string crate_blob_name = "falling_tile";

const string crateprop = "crate count";
const float TOSS_VEL = 1.5f;
const float CRATE_VELOCITY = 5.0f;

void changeCrates(CBlob@ this, int by)
{
	setCrates(this, crateCount(this) + by);
}

void setCrates(CBlob@ this, int amount)
{
	this.set_u8(crateprop, amount);
	this.Sync(crateprop, true);
}

int crateCount(CBlob@ this)
{
	return this.get_u8(crateprop);
}

void onInit(CBlob@ this)
{
	setCrates(this, CRATES);
}

void onTick(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);
	if (data.dead || data.inMenu || !getRules().isMatchRunning())
		return;

	if (data.local && !data.inMenu && !data.crosshair && this.isKeyJustPressed(key_action2) && !data.fire)
	{
		CBitStream params;
		params.write_Vec2f(data.pos);
		params.write_Vec2f(data.vel);
		params.write_bool(data.facingLeft);
		this.SendCommand(Soldier::Commands::CRATE, params);
	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == Soldier::Commands::CRATE)
	{
		//TODO: saferead
		Vec2f pos = params.read_Vec2f();
		Vec2f vel = params.read_Vec2f();
		bool facingLeft = params.read_bool();
		PlaceCrate(this, pos, vel, facingLeft);
	}
}

void PlaceCrate(CBlob@ this, Vec2f pos, Vec2f vel, const bool facingLeft)
{
	CMap@ map = getMap();
	f32 distance = 8.0f;
	Vec2f facing_vector = Vec2f(facingLeft ? -1.0f : 1.0f, 0.0f);

	Soldier::Data@ data = Soldier::getData(this);

	if (data is null)
	{
		return;
	}

	Vec2f[] places =
	{
		pos + facing_vector*distance + Vec2f(0, 0),
		pos + facing_vector*distance + Vec2f(0, -8)
	};

	bool take_tiles = false;
	bool onladder = data.onLadder;

	//ladder drop
	//on ladder, not touching ground, not pressing to the side = ladder drop, below to kill chasing players
	bool ladderdrop = onladder && !this.isOnGround() && !(data.left || data.right);
	if (ladderdrop)
	{
		Vec2f placepos = pos + Vec2f(0, 10);
		int x = placepos.x / map.tilesize;
		int y = placepos.y / map.tilesize;
		u8 tile = TWMap::getTile(x, y);

		//check crate count and clear below
		if (!TWMap::isTileTypeSolid(tile) && crateCount(this) > 0)
		{
			changeCrates(this, -1);

			CBlob@ b = PlaceBlob(crate_blob_name, placepos, this, -1);
			if (b !is null)
			{
				b.set_bool("smash_fall", true);
				b.setVelocity(Vec2f(0, 0));
				//b.server_SetTimeToDie(2);
			}
		}

		return;
	}

	// shoot crate

	if (!data.crouch)
	{
		Vec2f placepos = pos + facing_vector * distance + Vec2f(0, -8);
		int x = placepos.x / map.tilesize;
		int y = placepos.y / map.tilesize;
		u8 tile = TWMap::getTile(x, y);

		//check crate count and clear ahead
		if (!TWMap::isTileTypeSolid(tile) && crateCount(this) > 0)
		{
			changeCrates(this, -1);

			CBlob@ b = PlaceBlob(crate_blob_name, placepos, this, -1);
			if (b !is null)
			{
				b.set_bool("smash_fall", true);
				b.setVelocity(facing_vector * CRATE_VELOCITY);
				b.getShape().SetGravityScale(0.0f);
				b.server_SetTimeToDie(0.4f);
			}

			return;
		}

		take_tiles = true;
	}

	//normal drop
	if (!take_tiles)
	{
		int frontcratecount = 0;
		for (uint i = 0; i < places.length; i++)
		{
			Vec2f placepos = places[i];
			//TODO: check for overlapping stuff

			int x = placepos.x / map.tilesize;
			int y = placepos.y / map.tilesize;
			u8 tile = TWMap::getTile(x, y);
			if (!TWMap::isTileTypeSolid(tile))
			{
				if (crateCount(this) > 0)
				{
					if (!TWMap::isTileTypeSolid(TWMap::getTile(x, y + 1)))
					{
						Vec2f pos = TWMap::getNearestTileCentrePos(map, placepos);
						changeCrates(this, -1);

						CBlob@ b = PlaceBlob(crate_blob_name, pos, this, -1);
						if (b !is null)
						{
							b.setVelocity(Vec2f(0, Maths::Abs(vel.y) > TOSS_VEL ? -4.5f : 0));
							//b.server_SetTimeToDie(2);
						}
					}
					else
					{
						TWMap::setTile(x, y, TWMap::tile_crate_1 + (getGameTime() % 2));
					}

					return;
				}
				else
				{
					AddMessageAbove(this, "no crates");
					this.getSprite().PlaySound("NoAmmo");
				}
			}
			else
			{
				if (TWMap::canTileFall(tile))
				{
					frontcratecount++;
					take_tiles = (frontcratecount >= 2);
				}
				else
				{
					take_tiles = true;
				}
			}
		}
	}

	if (take_tiles)
	{
		//top to bottom
		uint i = places.length;
		uint gained = 0;
		while (i-- > 0)
		{
			Vec2f placepos = places[i];
			int x = placepos.x / map.tilesize;
			int y = placepos.y / map.tilesize;
			u8 tile = TWMap::getTile(x, y);
			if (TWMap::canTileFall(tile))
			{
				map.server_DestroyTile(placepos, 1.0f, this);
				changeCrates(this, 1);
				gained++;
			}
		}

		if (gained > 0)
		{
			AddMessageAbove(this, "+crate" + (gained > 1 ? "s" : ""));
		}
	}
}
