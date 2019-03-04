// random sparks particles

namespace Particles
{

	const string STREAMER_EMIT = "_explosion_streamer";
	const string SMOKE_EMIT = "_smoke_streamer";
	const string FIREWORK_EMIT = "_firework_streamer";

	Random _expl_r(0x1998);
	Vec2f getRandomExtraVel(Vec2f vel, f32 speed, f32 minfac = 0.25f)
	{
		Vec2f myVel( (minfac + _expl_r.NextFloat()*(1.0f-minfac)) * speed, 0);
		myVel.RotateBy(_expl_r.NextFloat() * 360.0f);

		myVel += vel;

		return myVel;
	}

	void FireSmokePuffs(Vec2f pos, int amount, Vec2f vel)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel, 4.0f);

			CParticle@ p = ParticleAnimated( "particle_firesmoke.png",
											 pos,
											 myVel,
											 0.0f,
											 1.0f,
											 3 + _expl_r.NextRanged(4), //animtime
											 -0.1f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.damping = 0.85f;

			p.deadeffect = 255;

			p.collides = false;
			p.Z = 1000.0f;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.width = p.height = 2.0f;
		}
	}

	void TinyFires(Vec2f pos, int amount, Vec2f vel, f32 addvel = 2.0f)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel, addvel);

			CParticle@ p = ParticleAnimated( "particle_fire_tiny.png",
											 pos,
											 myVel,
											 0.0f,
											 1.0f,
											 3 + _expl_r.NextRanged(4), //animtime
											 -0.1f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.damping = 0.85f;

			p.collides = false;
			p.Z = 1000.0f;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.width = p.height = 2.0f;
		}
	}

	void DirectionalSparks(Vec2f pos, int amount, Vec2f vel, f32 extravel = 12.0f)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel * 0.5f, extravel);

			CParticle@ p = ParticleAnimated( "particle_spark.png",
											 pos,
											 myVel,
											 0.0f,
											 1.0f,
											 3 + _expl_r.NextRanged(5), //animtime
											 0.2f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.freerotation = true;
			p.rotates = true;
			p.stretches = true;

			p.collides = true;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.damping = 0.95f;

			p.deadeffect = 255;

			p.scale = 0.5f + _expl_r.NextFloat();
			p.growth = -0.1f;

			p.width = p.height = 2.0f;
		}
	}

	//////////////////////////////////////
	// smoke stuff
	//////////////////////////////////////

	void TinySmokes(Vec2f pos, int amount, Vec2f vel, f32 extravel = 2.0f, f32 z = 1000.f)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel, extravel);

			CParticle@ p = ParticleAnimated( "particle_smoke_tiny.png",
											 pos,
											 myVel,
											 0.0f,
											 1.0f,
											 3 + _expl_r.NextRanged(6), //animtime
											 -0.1f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.damping = 0.85f;

			p.collides = false;
			p.Z = z;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.width = p.height = 2.0f;
		}
	}

	void SmokeBombPuffs(Vec2f pos, int amount, Vec2f vel)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel, 12.0f, 0.1f);
			f32 angle = _expl_r.NextRanged(4)*90;

			CParticle@ p = ParticleAnimated( "particle_bigsmoke.png",
											 pos,
											 myVel,
											 angle,
											 1.0f,
											 4 + _expl_r.NextRanged(6), //animtime
											 -0.05f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.damping = 0.80f;

			p.deadeffect = 255;

			p.collides = false;
			p.Z = 1000.0f;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.width = p.height = 2.0f;
		}
	}

	void SmokePuffs(Vec2f pos, int amount, Vec2f vel, f32 extravel = 4.0f, f32 z = 1000.0f)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel, extravel);

			CParticle@ p = ParticleAnimated( "particle_smoke.png",
											 pos,
											 myVel,
											 0.0f,
											 1.0f,
											 3 + _expl_r.NextRanged(4), //animtime
											 -0.1f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.damping = 0.85f;

			p.deadeffect = 255;

			p.collides = false;
			p.Z = z;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.width = p.height = 2.0f;
		}
	}

	//////////////////////////////////////
	// dusts
	//////////////////////////////////////

	void TinyDusts(Vec2f pos, int amount, Vec2f vel, f32 extravel = 2.0f, f32 z = 1000.0f)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel, extravel);

			CParticle@ p = ParticleAnimated( "particle_dust_tiny.png",
											 pos,
											 myVel,
											 0.0f,
											 1.0f,
											 3 + _expl_r.NextRanged(3), //animtime
											 -0.1f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.damping = 0.85f;

			p.collides = false;
			p.Z = z;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.width = p.height = 2.0f;
		}
	}

	void MicroDusts(Vec2f pos, int amount, Vec2f vel, f32 extravel = 2.0f, f32 z = 1000.0f)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel, extravel);

			CParticle@ p = ParticleAnimated( "particle_dust_micro.png",
											 pos,
											 myVel,
											 0.0f,
											 1.0f,
											 2 + _expl_r.NextRanged(3), //animtime
											 -0.1f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.damping = 0.85f;

			p.collides = false;
			p.Z = z;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.width = p.height = 2.0f;
		}
	}

	void MicroAirSpecs(Vec2f pos, int amount, Vec2f vel, f32 extravel = 2.0f)
	{
		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel = getRandomExtraVel(vel, extravel);

			CParticle@ p = ParticleAnimated( "particle_air_micro.png",
											 pos,
											 myVel,
											 0.0f,
											 1.0f,
											 1 + _expl_r.NextRanged(3), //animtime
											 -0.1f,
											 true );

			if(p is null) return; //bail if we stop getting particles

			p.damping = 0.85f;

			p.collides = false;
			p.Z = 1000.0f;
			p.slide = 1.0f;
			p.bounce = 1.0f;

			p.width = p.height = 2.0f;
		}
	}

	//////////////////////////////////////
	// emitters
	//////////////////////////////////////

	void FireStreamers(Vec2f pos, int amount, Vec2f vel, f32 speed, int time_min, int time_bonus)
	{
		EnsureRegistered();

		f32 minfac = 0.5f;

		f32 myangle = _expl_r.NextFloat() * 360.0f;
		f32 anglestep = (360.0f / amount);

		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel( (minfac + _expl_r.NextFloat()*(1.0f-minfac)) * speed, 0);
			myVel.RotateBy(myangle + anglestep * (j + _expl_r.NextFloat() * 0.5f - 0.25f) );

			myVel += vel;

			CParticle@ p = ParticlePixel( pos, myVel, SColor(0xffffffff), true );

			if(p is null) return; //bail if we stop getting particles

			p.timeout = time_min + _expl_r.NextRanged(time_bonus);

			p.AddDieFunction("ExplosionEmissionCallbacks.as", "AddFireSmokePuff");
			p.emiteffect = GetCustomEmitEffectID(STREAMER_EMIT);

			p.diesoncollide = true;

			p.damping = 0.85f;
			p.gravity *= 0.5f;
		}
	}

	void SmokeStreamers(Vec2f pos, int amount, Vec2f vel, f32 speed, int time_min, int time_bonus)
	{
		EnsureRegistered();

		f32 minfac = 0.5f;

		f32 myangle = _expl_r.NextFloat() * 360.0f;
		f32 anglestep = (360.0f / amount);

		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel( (minfac + _expl_r.NextFloat()*(1.0f-minfac)) * speed, 0);
			myVel.RotateBy(myangle + anglestep * (j + _expl_r.NextFloat() * 0.5f - 0.25f) );

			myVel += vel;

			CParticle@ p = ParticlePixel( pos, myVel, SColor(0xff1d286f), true );

			if(p is null) return; //bail if we stop getting particles

			p.timeout = time_min + _expl_r.NextRanged(time_bonus);

			p.AddDieFunction("ExplosionEmissionCallbacks.as", "AddSmokePuff");
			p.emiteffect = GetCustomEmitEffectID(SMOKE_EMIT);

			p.diesoncollide = true;

			p.damping = 0.55f;
			p.gravity *= 0.5f;
		}
	}

	void Fireworks(Vec2f pos, int amount, Vec2f vel, f32 speed, int time_min, int time_bonus)
	{
		EnsureRegistered();

		f32 minfac = 0.5f;

		f32 myangle = _expl_r.NextFloat() * 360.0f;
		f32 anglestep = (360.0f / amount);

		for (int j = 0; j < amount; j++)
		{
			Vec2f myVel( (minfac + _expl_r.NextFloat()*(1.0f-minfac)) * speed, 0);
			myVel.RotateBy(myangle + anglestep * (j + _expl_r.NextFloat() * 0.5f - 0.25f) );

			myVel += vel;

			CParticle@ p = ParticlePixel( pos, myVel, SColor(0xffffffff), true );

			if(p is null) return; //bail if we stop getting particles

			p.timeout = time_min + _expl_r.NextRanged(time_bonus);

			p.AddDieFunction("ExplosionEmissionCallbacks.as", "FireworkPuff");
			p.emiteffect = GetCustomEmitEffectID(FIREWORK_EMIT);

			p.diesoncollide = false;
			p.growth = 0.025f;

			p.rotates = true;
			p.rotation = Vec2f(1,0).RotateBy(45);

			p.damping = 0.6f;
			p.gravity *= 0.5f;
		}

		Sound::Play(Sound::getFileVariation("FireworkLaunch?", 1, 2), pos );
	}

	//////////////////////////////////////
	// tile gibs
	///////////////////////////////////////

	void TileGibs(Vec2f pos, int amount, f32 speed, int type)
	{
		Random _prandom(int(pos.x * pos.y + type + speed));
		Vec2f vel;
		for(int i = 0; i < 5; i++)
		{
			string[] gibfileLUT = {"Effects/plant_gibs.png" ,  "Effects/wood_gibs.png" , "Effects/stone_gibs.png"};
			string gibfile = gibfileLUT[type];

			string[] gibsoundfileLUT = {"", "" , ""};
			string gibsoundfile = gibsoundfileLUT[type];

			vel = Vec2f(_prandom.NextFloat() * speed, 0).RotateBy(_prandom.NextFloat() * 360.0f) + Vec2f(0,-5.0f);
			CParticle@ p = makeGibParticle( gibfile, pos,
											vel, _prandom.NextRanged(4), _prandom.NextRanged(2),
											Vec2f(8,8), 1.0f, 0, gibsoundfile );

			if(p is null) break;

			p.damping = 1.0f;

			p.collides = true;
			p.Z = 50.0f;
			p.slide = 0.5f;
			p.bounce = 0.5f;

			p.width = p.height = 2.0f;
		}
	}

	//////////////////////////////////////
	// combined effects
	//////////////////////////////////////

	void Explosion(Vec2f pos, int amount, Vec2f vel )
	{
		EnsureRegistered();

		//1 streamer per amount
		//0.5-1 seconds streamer
		FireStreamers(pos, amount, vel * 0.3f + Vec2f(0.0f,-4.0f), 8.0f, 5, 25);

		for (int i = 0; i < amount; i++)
		{
			//4 smoke puffs
			FireSmokePuffs(pos, 4, vel * 0.8f);

			//3 sparks
			DirectionalSparks(pos, 3, vel*0.5f);

			//7 fire bits
			TinyFires(pos, 7, vel);
		}
	}

	//////////////////////////////////////
	// emission registration
	//////////////////////////////////////

	void EnsureRegistered()
	{
		//setup custom emit if needed

		if(!CustomEmitEffectExists( STREAMER_EMIT ))
		{
			SetupCustomEmitEffect( STREAMER_EMIT,
									"ExplosionEmissionCallbacks.as",
									"AddTinyFire",
									5, 4, 90 );
		}

		if(!CustomEmitEffectExists( SMOKE_EMIT ))
		{
			SetupCustomEmitEffect( SMOKE_EMIT,
									"ExplosionEmissionCallbacks.as",
									"AddTinySmoke",
									5, 4, 90 );
		}

		if(!CustomEmitEffectExists( FIREWORK_EMIT ))
		{
			SetupCustomEmitEffect( FIREWORK_EMIT,
									"ExplosionEmissionCallbacks.as",
									"AddSpark",
									1, 0, 120 );
		}
	}


}

