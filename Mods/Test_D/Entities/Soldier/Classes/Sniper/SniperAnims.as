#include "SoldierCommon.as"
#include "MapCommon.as"

void onInit(CSprite@ this)
{
	this.ReloadSprite( "actor_sniper.png" ); // fixes engine bug (consts.filename = filename not set in ReloadSprite overload)
	this.ReloadSprite("actor_sniper.png", 24, 24, Soldier::getTeamColorForSprite(this.getBlob()), 0 );

	// layers
	{
		this.RemoveSpriteLayer("camo1");
		CSpriteLayer@ camo = this.addSpriteLayer("camo1", "Sprites/world.png", 8, 8, 0, 0);
		if (camo !is null)
		{
			camo.SetOffset(this.getOffset() + Vec2f(0.0f, 8.0f));
			camo.SetVisible(false);
		}
	}
	{
		this.RemoveSpriteLayer("camo2");
		CSpriteLayer@ camo = this.addSpriteLayer("camo2", "Sprites/world.png", 8, 8, 0, 0);
		if (camo !is null)
		{
			camo.SetOffset(this.getOffset() + Vec2f(0.0f, 0.0f));
			camo.SetVisible(false);
		}
	}

	// anims
	{
		Animation@ anim = this.addAnimation("stand", 0, false);
		anim.AddFrame(0);
	}
	{
		Animation@ anim = this.addAnimation("run", 3, true);
		int[] frames = {2, 3, 4, 7, 8, 9};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("jump up", 3, false);
		int[] frames = {15, 16, 17};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("jump down", 3, false);
		int[] frames = {17, 18, 19};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("fire", 0, false);
		int[] frames = {33, 6, 28, 31 };
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("aim", 0, false);
		int[] frames = {32, 5, 27, 30 };
		anim.AddFrames(frames);
	}


	{
		Animation@ anim = this.addAnimation("crouch", 2, false);
		int[] frames = {10, 11, 12};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("stand up", 1, false);
		int[] frames = {12, 13, 10};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("slide start", 3, false);
		int[] frames = {13, 25, 26};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("slide", 3, true);
		int[] frames = {25, 26};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("die", 2, false);
		int[] frames = {20, 21, 22, 23};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("ground", 0, false);
		anim.AddFrame(23);
	}
	{
		Animation@ anim = this.addAnimation("fall up", 0, false);
		anim.AddFrame(22);
	}
	{
		Animation@ anim = this.addAnimation("fall down", 0, false);
		anim.AddFrame(24);
	}
	{
		Animation@ anim = this.addAnimation("crawl", 3, true);
		int[] frames = {22, 22, 23, 24, 24, 23};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("bite", 3, false);
		int[] frames = {24, 24, 23};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("agony", 5, false);
		int[] frames = {23, 23, 22, 23, 22};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("camo", 0, false);
		int[] frames = {44};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("flip", 4, false);
		int[] frames = {14};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("ladder", 0, false);
		int[] frames = {35, 36};
		anim.AddFrames(frames);
	}
}

u8 transformCamo(u8 tile, u32 index)
{
	if (TWMap::isTileBush(tile))
		tile = TWMap::tile_bush;
	if (TWMap::isTileBunker(tile))
		tile = TWMap::tile_bunker;
	if (TWMap::isTileSand(tile))
		tile = TWMap::tile_cactus_1 + index % 2;

	return tile;
}

bool isAllowedCamo(u8 tile)
{
	return tile == TWMap::tile_bush ||
	       TWMap::isTileCactus(tile) ||
	       tile == TWMap::tile_bunker ||
	       tile == TWMap::tile_rubble;
}

u8 getCamoTile(Random@ r, Vec2f position, CMap@ map)
{
	u8 ret = TWMap::tile_crate_1 + r.NextRanged(2); //crate

	u8 found = 0;

	u32 count = 15;
	while (count-- > 0 && !isAllowedCamo(found))
	{
		u32 index = TWMap::offsetAt(map, position);
		found = map.getTile(index).type;
		found = transformCamo(found, index);
		position += Vec2f((r.NextFloat() - 0.5f) * 16.0f, (r.NextFloat() - 0.5f) * 16.0f);
	}
	if (isAllowedCamo(found))
	{
		ret = found;
	}

	return ret;
}

u8 matchingCamo(u8 feet, Random@ r)
{
	//bushes
	if (feet == TWMap::tile_bush)
		return TWMap::tile_bush_corner;

	//crates
	if (feet == TWMap::tile_crate_1 || feet == TWMap::tile_crate_2)
		return TWMap::tile_crate_1 + r.NextRanged(2);

	//cactus
	if (feet == TWMap::tile_cactus_1)
		return TWMap::tile_cactus_2;
	if (feet == TWMap::tile_cactus_2)
		return TWMap::tile_cactus_1;

	//rocks
	if (feet >= TWMap::tile_mountstone_1 && feet <= TWMap::tile_mountstone_6)
		return TWMap::tile_rubble;

	return feet;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Soldier::Data@ data = Soldier::getData(blob);

	if (data.dead)
	{
		CSpriteLayer@ camo1 = this.getSpriteLayer("camo1");
		camo1.SetVisible(false);
		CSpriteLayer@ camo2 = this.getSpriteLayer("camo2");
		camo2.SetVisible(false);
		return;
	}

	const bool shot = data.shotTime >= data.gametime - 4;
	data.specialAnim = shot || data.crosshair || data.camoMode != 0;

	if (data.specialAnim)
	{
		// aiming
		if (data.crosshair)
		{
			Vec2f aimdir = data.crosshairOffset;
			aimdir.Normalize();

			s32 aimframe = 1;
			if (aimdir.y < -0.3f)
			{
				aimframe = 0;
			}
			else if (aimdir.y > 0.7f)
			{
				aimframe = 3;
			}
			else if (aimdir.y > 0.3f)
			{
				aimframe = 2;
			}

			if (data.shotTime >= data.gametime - 3)
			{
				this.SetAnimation("fire");
			}
			else if (shot || data.crosshair)
			{
				this.SetAnimation("aim");
			}
			this.SetFrameIndex(aimframe);
		}
		else if (data.camoMode != 0)
		{
			this.SetAnimation("camo"); // clear
		}
	}

	// camo
	CSpriteLayer@ camo = this.getSpriteLayer("camo1");
	CSpriteLayer@ camo2 = this.getSpriteLayer("camo2");
	if (data.camoMode != 0)
	{
		//ensure tiles dont flip
		camo.SetFacingLeft(false);
		camo2.SetFacingLeft(false);

		if (!camo.isVisible())
		{
			camo.SetVisible(true);
			camo2.SetVisible(true);

			Random _r(data.camoMode);

			//TODO: consider medkit/supply camo

			CMap@ map = getMap();
			u8 tile1 = getCamoTile(_r, data.pos, map);
			u8 tile2 = matchingCamo(tile1, _r);

			camo.SetFrame(tile1);
			camo2.SetFrame(tile2);
		}

		//wiggle when moving
		s32 wiggle = 0;
		if (data.vellen > 0.5f)
			wiggle = (s32(data.pos.x + 100) % 3) - 1;
		camo.ResetTransform();
		camo.TranslateBy(Vec2f(0, wiggle));
		camo2.ResetTransform();
		camo2.TranslateBy(Vec2f(0, wiggle));

		//ensure relative z is ok

		camo.SetRelativeZ(10);
		camo2.SetRelativeZ(10);
	}
	else
	{
		camo.SetVisible(false);
		camo2.SetVisible(false);
	}

	// laser

	// UpdateLaser( this, blob, data );
}

void UpdateLaser(CSprite@ this, CBlob@ blob, Soldier::Data@ data)
{
	CSpriteLayer@ laser = this.getSpriteLayer("laser");
	if (data.crosshair)
	{
		laser.SetVisible(true);
	}
	else
	{
		laser.SetVisible(false);
		return;
	}

	Vec2f gunOffset(blob.isFacingLeft() ? 11.0f : 11.0f, blob.isFacingLeft() ? 5.0f : -5.0f);
	Vec2f pos1 = data.pos;
	Vec2f pos2 = data.pos + data.crosshairOffset;
	Vec2f off = pos2 - pos1;

	data.map.rayCastSolid(pos1, pos1 + off * 10.0f, pos2);
	off = pos2 - pos1;

	f32 ropelen = Maths::Max(0.1f, off.Length() / 32.0f);
	if (ropelen < 1.0f || ropelen > 240.0f)
	{
		laser.SetVisible(false);
		return;
	}

	laser.ResetTransform();
	laser.ScaleBy(Vec2f(ropelen, 1.0f));
	laser.TranslateBy(Vec2f(ropelen * 16.0f, 0.0f) + gunOffset);
	laser.RotateBy(-off.Angle() , Vec2f());
}
