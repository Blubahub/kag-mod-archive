// explode include

#include "SoldierCommon.as";

void ExplodeAtPosition( CBlob@ this, Vec2f pos, f32 radius, f32 damage )
{
	CMap@ map = getMap();

	if (getNet().isServer())
	{
		//hit tiles
		float map_damage_radius = (radius * 1.1f);
		int tile_rad = int( map_damage_radius / map.tilesize ) + 1;
        Vec2f m_pos = (pos / map.tilesize);
        m_pos.x = Maths::Floor(m_pos.x);
        m_pos.y = Maths::Floor(m_pos.y);
        m_pos = (m_pos * map.tilesize) + Vec2f(map.tilesize / 2, map.tilesize / 2);

        //explode outwards (prevents bias after tiles are destroyed)
        for (int x_step = 0; x_step <= tile_rad; ++x_step)
        {
            for (int y_step = 0; y_step <= tile_rad; ++y_step)
            {
                Vec2f offset = (Vec2f(x_step, y_step) * map.tilesize);
                f32 dist = offset.Length();

                for (int i = 0; i < 4; i++)
                {
                    if (i == 1 || i == 3)
                    {
                        if (x_step == 0) { continue; }
                        offset.x = -offset.x;
                    }

                    if (i == 2)
                    {
                        if (y_step == 0) { continue; }
                        offset.y = -offset.y;
                    }

                    if (dist < map_damage_radius)
                    {
                        //do we need to raycast?
                        bool canHit = dist < map.tilesize;

						if (!canHit)
						{
							Vec2f v = offset;
							v.Normalize();
							v = v * (dist - map.tilesize);
							canHit = !( map.rayCastSolid (m_pos, m_pos + v) );
						}

                        if (canHit)
                        {
							Vec2f tpos = m_pos + offset;
							
							map.server_DestroyTile(tpos, 1.0f, this);
                        }
                    }
                }
            }
        }
    }
}

void Explode( CBlob@ this, f32 radius, f32 damage )
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();

	ExplodeAtPosition( this, pos, radius, damage );

	if (getNet().isServer())
	{
		//hit blobs
		CBlob@[] blobs;
		map.getBlobsInRadius( pos, radius, @blobs );

		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ hit_blob = blobs[i];
			if (hit_blob is this)
				continue;

			u8 hitter = 0;
			RayHit( this, hit_blob, radius, damage, hitter, true, false );
		}
	}		
}

bool RayHit( CBlob@ this, CBlob@ hit_blob, f32 radius, f32 damage, const u8 hitter,
			  const bool bother_raycasting = true, const bool should_teamkill = false )
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	Vec2f hit_blob_pos = hit_blob.getPosition();
	Vec2f wall_hit;
	Vec2f hitvec = hit_blob_pos - pos;

	if (!hit_blob.hasTag("crouching"))
	{
		hit_blob_pos.y -= hit_blob.getRadius();
	}

	if(bother_raycasting) // have we already checked the rays?
	{
		// no wall in front

		if (map.rayCastSolidNoBlobs(pos, hit_blob_pos, wall_hit)) { return false; }

		// no blobs in front

		HitInfo@[] hitInfos;
		if (map.getHitInfosFromRay( pos, -hitvec.getAngle(), hitvec.getLength(), this, @hitInfos ))
		{
			bool blocked = false;
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];

				if (hi.blob !is null) // blob
				{
					if (hi.blob is this || hi.blob is hit_blob || !hi.blob.isCollidable()) {
						continue;
					}

					// only shield and heavy things block explosions
					if ( hi.blob.getShape().isStatic() && !hi.blob.hasTag("explosive") ) {
						return false;
					}
				}
			}
		}
	}

	bool selfkill = this.getDamageOwnerPlayer() is hit_blob.getPlayer() && hit_blob.getPlayer() !is null;
	f32 scale;
	Vec2f bombforce = getBombForce( this, radius, hit_blob_pos, pos, hit_blob.getMass(), scale );
	//hit the object
	this.server_Hit(    hit_blob, hit_blob_pos,
						bombforce, damage * scale,
						hitter, 
						should_teamkill || selfkill
					);
	return true;
}

Vec2f getBombForce( CBlob@ this, f32 radius, Vec2f hit_blob_pos, Vec2f pos, f32 hit_blob_mass, f32 &out scale ) 
{
	Vec2f offset = hit_blob_pos - pos;
	f32 distance = offset.Length();
	//set the scale (2 step)
	scale = (distance > (radius * 0.7)) ? 0.5f : 1.0f;
	//the force, copy across
	Vec2f bombforce = offset;
	bombforce.Normalize();
	bombforce *= 2.0f;
	bombforce.y -= 0.2f; // push up for greater cinematic effect
	bombforce.x = Maths::Round(bombforce.x);
	bombforce.y = Maths::Round(bombforce.y);
	bombforce /= 2.0f;
	bombforce *= hit_blob_mass * (0.2f) * scale;
	return bombforce;
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	hitBlob.setVelocity( Vec2f( velocity.x, -Maths::Abs(velocity.y) ) );
	Soldier::Data@ theirdata = Soldier::getData( hitBlob );
	if(theirdata !is null)
	{
		theirdata.stunTime = 90;
	}

	if (this.hasTag("crush"))
	{
		this.getSprite().PlaySound("Crush");
		//this.server_Die();
	}


	Vec2f vel = this.getVelocity();
	this.setVelocity( Vec2f( vel.x, -vel.y*0.75f) );
}

