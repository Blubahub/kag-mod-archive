// Bomb logic

#include "Hitters.as";
#include "BombCommon.as";
#include "ShieldCommon.as";
#include "SSKMovesetCommon.as"

const s32 bomb_fuse = 50;

const s32 MAX_EXPLOSION_TIME = 120;
const f32 MIN_EXPLOSION_SCALE = 0.4f;
const f32 MAX_EXPLOSION_SCALE = 2.0f;

const f32 EXPLOSION_SPRITE_WIDTH = 64.0f;

void onInit(CBlob@ this)
{
	CSprite@ thisSprite = this.getSprite();

	this.getShape().getConsts().net_threshold_multiplier = 2.0f;

	this.set_s32("counter", 0);
	this.set_s32("explosion_time", 0);

	this.set_Vec2f("explosion_pos", Vec2f_zero);
	this.set_f32("spriteLayerScale", 1.0f);

	this.addCommandID("trigger explosion");
	this.addCommandID("die");

	// add explosion effect
	thisSprite.RemoveSpriteLayer("explosion");
	CSpriteLayer@ explosion = thisSprite.addSpriteLayer("explosion", "smartexplosion1.png", 64, 64);
	if (explosion !is null)
	{
		Animation@ anim = explosion.addAnimation("default", 3, true);
		int[] frames = {0, 1, 2, 3, 4 ,5 ,6 ,7, 8, 9, 10, 11};
		anim.AddFrames(frames);
		explosion.SetVisible(false);
		explosion.SetRelativeZ(1.0f);
	}
}

//sprite update
void onTick(CBlob@ this)
{
	CSprite@ thisSprite = this.getSprite();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	s32 counter = this.get_s32("counter");
	bool exploding = this.hasTag("exploding");

	if ( exploding )
	{
		s32 explosionTime = this.get_s32("explosion_time");

		if (explosionTime >= MAX_EXPLOSION_TIME)
		{
			if (getNet().isServer())
			{
				this.SendCommand(this.getCommandID("die"));
			}
		}
		else
		{
			Vec2f explosionPos = this.get_Vec2f("explosion_pos");
			this.setVelocity(Vec2f_zero);
			this.setPosition(explosionPos);

			f32 spriteLayerScale = this.get_f32("spriteLayerScale");
			f32 scaleFactor = Maths::Max(MIN_EXPLOSION_SCALE, MAX_EXPLOSION_SCALE*((1.0f*explosionTime)/(1.0f*MAX_EXPLOSION_TIME)));
			Vec2f scaleVec = Vec2f(scaleFactor, scaleFactor);

			if ( getGameTime() % 4 == 0 )
			{
				Explode_SB(this, (EXPLOSION_SPRITE_WIDTH/2.0f)*scaleFactor, 2.0f);	
			}

			// render explosion
			CSpriteLayer@ explosion = thisSprite.getSpriteLayer("explosion");
			if (explosion !is null)
			{
				explosion.SetVisible(true);
				if (true)
				{
					explosion.ResetTransform();

					Vec2f unScaleVec = Vec2f(1.0f/spriteLayerScale, 1.0f/spriteLayerScale);
					
					explosion.ScaleBy(unScaleVec);	// ResetTransform() does not reset scale back to 1.0f
					explosion.ScaleBy(scaleVec);
					
					this.set_f32("spriteLayerScale", scaleFactor);
				}
			}	

			if ( getGameTime() % 8 == 0 )
			{
				CParticle@ p = ParticleAnimated("blast1.png", explosionPos, Vec2f(0, 0), XORRandom(360), scaleFactor*0.9f, 3, 0.0f, true);
				if (p !is null)
				{
					p.Z = -100.0f;
				}

				ShakeScreen( 80, 30, pos );
			}
		}

		explosionTime++;
		this.set_s32("explosion_time", explosionTime);	
	}
	else if (this.hasTag("armed"))
	{
		if (counter >= bomb_fuse)
		{
			if (getNet().isServer())
			{
				this.SendCommand(this.getCommandID("trigger explosion"));
			}
		}
		else
		{
			counter++;
			this.set_s32("counter", counter);		
		}
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	bool exploding = this.hasTag("exploding");

	return !exploding;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (!this.hasTag("exploding") && getNet().isServer() && damage >= 1.0f)
	{
		this.SendCommand(this.getCommandID("trigger explosion"));
	}

	return 0.0f;
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		const u8 hitter = this.get_u8("custom_hitter");

		//all water bombs collide with enemies
		if (hitter == Hitters::water)
			return blob.getTeamNum() != this.getTeamNum();

		//collide with shielded enemies
		return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
	}

	string name = blob.getName();

	if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart")
	{
		return false;
	}

	return true;
}



void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	const f32 vellen = this.getOldVelocity().Length();
	if (!solid && !(blob.hasTag("player") && vellen > 1.0f))
	{
		return;
	}
	
	const u8 hitter = this.get_u8("custom_hitter");
	if (!this.hasTag("exploding") && vellen > 1.7f)
	{
		Sound::Play(!isExplosionHitter(hitter) ? "/WaterBubble" :
		            "/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f));
	}

	if (!this.isAttached() && !this.hasTag("exploding") && this.hasTag("armed"))
	{
		if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
		{
			this.Tag("_hit_water");
			Vec2f pos = this.getPosition();
			blob.Tag("force_knock");

			if (getNet().isServer())
			{
				this.SendCommand(this.getCommandID("trigger explosion"));
			}
		}
	}
}

void Explode_SB(CBlob@ this, f32 radius, f32 damage)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();

	//load custom properties
	//map damage
	f32 map_damage_radius = radius;

	f32 map_damage_ratio = 1.0f;

	bool map_damage_raycast = false;

	//actor damage
	u8 hitter = Hitters::explosion;

	if (this.exists("custom_hitter"))
	{
		hitter = this.get_u8("custom_hitter");
	}

	bool should_teamkill = true;

	const int r = (radius * (2.0 / 3.0));

	if (getNet().isServer())
	{
		//hit map if we're meant to
		if (map_damage_radius > 0.1f)
		{
			int tile_rad = int(map_damage_radius / map.tilesize) + 1;
			f32 rad_thresh = map_damage_radius * map_damage_ratio;
			Vec2f m_pos = (pos / map.tilesize);
			m_pos.x = Maths::Floor(m_pos.x);
			m_pos.y = Maths::Floor(m_pos.y);
			m_pos = (m_pos * map.tilesize) + Vec2f(map.tilesize / 2, map.tilesize / 2);

			//explode outwards
			for (int x_step = 0; x_step <= tile_rad; ++x_step)
			{
				for (int y_step = 0; y_step <= tile_rad; ++y_step)
				{
					Vec2f offset = (Vec2f(x_step, y_step) * map.tilesize);

					for (int i = 0; i < 4; i++)
					{
						if (i == 1)
						{
							if (x_step == 0) { continue; }

							offset.x = -offset.x;
						}

						if (i == 2)
						{
							if (y_step == 0) { continue; }

							offset.y = -offset.y;
						}

						if (i == 3)
						{
							if (x_step == 0) { continue; }

							offset.x = -offset.x;
						}

						f32 dist = offset.Length();

						if (dist < map_damage_radius)
						{
							//do we need to raycast?
							bool canHit = !map_damage_raycast || (dist < 0.1f);

							if (!canHit)
							{
								Vec2f v = offset;
								v.Normalize();
								v = v * (dist - map.tilesize);
								canHit = !(map.rayCastSolid(m_pos, m_pos + v));
							}

							if (canHit)
							{
								Vec2f tpos = m_pos + offset;

								TileType tile = map.getTile(tpos).type;
								if (canExplosionDamage_SB(map, tpos, tile))
								{
									if (!map.isTileBedrock(tile))
									{
										if (dist >= rad_thresh ||
										        !canExplosionDestroy_SB(map, tpos, tile))
										{
											map.server_DestroyTile(tpos, 1.0f, this);
										}
										else
										{
											map.server_DestroyTile(tpos, 100.0f, this);
										}
									}
								}
							}
						}
					}
				}
			}

			//end loops
		}

		//hit blobs
		CBlob@[] blobs;
		map.getBlobsInRadius(pos, radius, @blobs);

		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ hit_blob = blobs[i];
			if (hit_blob is this)
				continue;

			HitBlob_SB(this, hit_blob, radius, damage, Hitters::keg, true, should_teamkill);
		}
	}

}

bool HitBlob_SB(CBlob@ this, CBlob@ hit_blob, f32 radius, f32 damage, const u8 hitter,
             const bool bother_raycasting = true, const bool should_teamkill = false)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	Vec2f hit_blob_pos = hit_blob.getPosition();
	Vec2f wall_hit;
	Vec2f hitvec = hit_blob_pos - pos;

	f32 scale;
	Vec2f bombforce = getBombForce(this, radius, hit_blob_pos, pos, hit_blob.getMass(), scale);
	f32 dam = damage * scale;

	//explosion particle
	//makeSmallExplosionParticle_SB(hit_blob_pos);

	//hit the object
	CustomHitData customHitData(10, 4.0f, 0.04f);
	server_customHit(this, hit_blob, hit_blob_pos, bombforce, dam, hitter, true, customHitData);
	return true;
}

bool canExplosionDamage_SB(CMap@ map, Vec2f tpos, TileType t)
{
	return map.getSectorAtPosition(tpos, "no build") is null &&
	       (t != CMap::tile_ground_d0 && t != CMap::tile_stone_d0); //don't _destroy_ ground, hit until its almost dead tho
}

bool canExplosionDestroy_SB(CMap@ map, Vec2f tpos, TileType t)
{
	return !(map.isTileGroundStuff(t));
}

void makeSmallExplosionParticle_SB(Vec2f pos)
{
	ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png",
	                 pos, Vec2f(0,0), XORRandom(360), 1.0f,
	                 3 + XORRandom(3),
	                 0.0f, true);
}

void makeLargeExplosionParticle_SB(Vec2f pos)
{
	ParticleAnimated("Entities/Effects/Sprites/Explosion.png",
	                 pos, Vec2f(0,0), XORRandom(360), 1.0f,
	                 3 + XORRandom(3),
	                 0.0f, true);
}

Random _sprk_r();
void sparks(Vec2f pos, int amount, Vec2f pushVel = Vec2f(0,0))
{
	if ( !getNet().isClient() )
		return;

	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 3.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        CParticle@ p = ParticlePixel( pos, vel + pushVel, SColor( 255, 180+XORRandom(40), 0, 255), true );
        if(p is null) return; //bail if we stop getting particles

        p.timeout = 10 + _sprk_r.NextRanged(20);
        p.scale = 1.0f + _sprk_r.NextFloat();
        p.damping = 0.97f;
		p.gravity = Vec2f(0,0);
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("trigger explosion"))
	{
		this.set_s32("counter", bomb_fuse);

		this.Tag("exploding");
		this.server_DetachFromAll();

		this.set_Vec2f("explosion_pos", this.getPosition());
		this.Sync("explosion_pos", true);

		this.getSprite().PlaySound("smartbombexplosion.ogg", 3.0f, 0.8f);

		SetScreenFlash( 150, 0, 0, 0 );
	}
	else if (cmd == this.getCommandID("die"))
	{
		Vec2f pos = this.getPosition();
		f32 radius = MAX_EXPLOSION_SCALE * EXPLOSION_SPRITE_WIDTH/2.0f;

		Explode_SB(this, radius, 30.0f);	
		
		makeLargeExplosionParticle_SB(pos);
		
		const int r = (radius * (2.0 / 3.0));
		for (int i = 0; i < 20; i++)
		{
			Vec2f partpos = pos + Vec2f(XORRandom(r * 2) - r, XORRandom(r * 2) - r);
			Vec2f endpos = partpos;

			makeSmallExplosionParticle_SB(endpos);
		}

		CParticle@ blastP = ParticleAnimated("blast1.png", pos, Vec2f(0, 0), XORRandom(360), MAX_EXPLOSION_SCALE*0.9f, 3, 0.0f, true);
		if (blastP !is null)
		{
			blastP.Z = -100.0f;
		}

		CParticle@ smartP = ParticleAnimated("smartexplosion2.png", pos, Vec2f(0, 0), 0.0f, MAX_EXPLOSION_SCALE, 3, 0.0f, true);
		if (smartP !is null)
		{
			smartP.Z = 100.0f;
		}

		//sparks( pos, 20 );

		this.getSprite().PlaySound("smartbombecho.ogg", 2.0f, 0.9f);

		this.server_Die();
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.Tag("armed");
}