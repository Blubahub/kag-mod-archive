#include "SoldierCommon.as"
#include "Shells.as"
#include "ExplosionParticles.as"

Random _effects_r(0x511);

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	Soldier::Data@ data = Soldier::getData( this );

	if (cmd == Soldier::Commands::FIRE && data.ammo > 0)
	{
		CBlob@ caller = getBlobByNetworkID( params.read_netid() );
		Vec2f pos = params.read_Vec2f();
		Vec2f velocity = params.read_Vec2f();
		const f32 time = params.read_f32();
		const f32 dmg = params.read_f32();

		Vec2f direction = velocity;
		f32 vellen = direction.Normalize();

		pos -= direction * 8.0f;

		//sniper bullet
		
		if(vellen >= 90.0f)
		{
			//perp for offset to get around corners (dont be too picky)
			Vec2f perp = direction;
			perp.RotateBy(90.0f, Vec2f_zero);

			//hit
			
			HitInfo@[] current;
			Soldier::GatherStuffInRay(this, current, pos,        direction);
			Soldier::GatherStuffInRay(this, current, pos+perp*3, direction);
			Soldier::GatherStuffInRay(this, current, pos-perp*3, direction);

			Vec2f end = pos;

			CMap@ map = getMap();

			f32 dist = 500;

			if(current.length > 0)
			{
				HitInfo@ hi = current[0];

				end = hi.hitpos;
				dist = hi.distance;	
				if (getNet().isServer())
				{
					if(hi.blob !is null)
					{
						CBlob@ b = hi.blob;
						this.server_Hit( b, b.getPosition(), direction * 10.0f, dmg, 0, true);
					}
				}
			}
			else
			{
				end = Soldier::wrappedPos(pos + direction * dist);
			}

			//hit tile
			map.server_DestroyTile(end, 1.0f);
			
			//effects

			//smash
			Particles::DirectionalSparks(pos + direction * dist - direction, 15, direction * 6.0f, 3.0f);
			Particles::DirectionalSparks(pos + direction * dist - direction, 10, Vec2f_zero, 4.0f);
			Particles::TinyDusts(pos + direction * dist, 5, direction * -2.0f, 1.5f);
			Particles::MicroDusts(pos + direction * dist, 10, direction * -2.0f, 3.5f);

			//trail
			f32 sinoffset = _effects_r.NextRanged(360) + _effects_r.NextRanged(180) + _effects_r.NextRanged(720);
			f32 trailpos = 1.0f;
			while(trailpos < dist)
			{
				f32 densitycurve = 0.05f;
				f32 relativepos = trailpos / dist;
				f32 density = Maths::Max(0.01f, Maths::Min(0.90f,
							  (1.0f/relativepos + 1.0f/(-relativepos+1.0f))/20.0f
							  ));
				trailpos += (1.0f - density) * 7.5f * _effects_r.NextFloat();
				Vec2f partpos = Soldier::wrappedPos(pos + direction * trailpos);
				Vec2f partvel = direction * (1.5f + _effects_r.NextFloat() * 3.0f) +
								perp * Maths::Sin(trailpos * 0.1f + sinoffset) * 10.0f * (1.0f-density);
				
				Particles::MicroAirSpecs(partpos, 1, partvel*0.1f, 0.5f);
			}

			//puff at gun
			Particles::TinySmokes(pos + direction * 4.0f, 5, Vec2f_zero, 1.5f);
			Particles::TinyFires(pos + direction * 4.0f, 3, Vec2f_zero, 0.5f);

		}
		//normal bullet
		else
		{
			if (getNet().isServer())
			{
				CBlob@ bullet = server_CreateBlob( "bullet", this.getTeamNum(), pos );
				if (bullet !is null)
				{
					if (caller !is null){
						bullet.SetDamageOwnerPlayer( caller.getPlayer() );
					}
					bullet.setVelocity( velocity );
					//bullet.server_SetTimeToDie( time );
					bullet.set_f32( "damage", dmg );
				}
			}
		}

		if (!getRules().get_bool("infinite ammo") && !sv_test)
			data.ammo--;
	}
}
