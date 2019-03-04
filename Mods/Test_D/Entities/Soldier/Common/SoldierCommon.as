namespace Soldier
{
	//avoid direct lookups
	namespace Commands
	{
		enum S_CMD
		{
			//provide a buffer for any other hardcoded cmds
			SOLDIERCMD_START = 30,

			//common
			DIE,
			FIRE,
			CROSSHAIR,
			REVIVE,

			//items
			GRENADE,
			CRATE,

			//sniper
			CHANGE_CAMO,

			//engie
			ENGIE_SHOOT,
			ENGIE_CONTROL,
			ENGIE_BOMB,

			//commando
			COMMANDO_STAB,
			COMMANDO_RUSH,
			COMMANDO_FLASHBANG,

			//medic
			MEDIC_SUPPLY,

			//civilian
			CIVILIAN_CIGAR,
			CIVILIAN_DRINK,
			CIVILIAN_COFFEE,
			CIVILIAN_LOADSKIN,
			THROWBALL,

			SOLDIERCMD_END
		}
	}

	const float walkSpeed = 1.1f;
	const float jumpSpeed = 3.85f;
	const float ledgeClimbForce = 2.3f;

	const float maxThrow = 13.0f;

	const int startIdleTicks = 30;

	const int recoverTicks = 140;
	const int crouchLockTicks = 3;

	const float ladderSpeed = 1.0f;

	const int deadScreamInterval = 40;
	const int biteInterval = 5;

	const int medicSupplyInterval = 5 * 30;
	const int medicHealDelay = 90;

	const int GRENADE = 0;
	const int FLASHBANG = 1;

	shared class Data
	{
		// class
		int type;
		//camera
		Vec2f cameraTarget;
		// jumping
		int jumpMax;
		int jumpCounter;
		int airTime;
		// ledge climbing
		bool ledgeClimb;
		bool oldLedgeClimb;
		bool canLedgeClimb;
		// shooting
		u32 fireTime;
		u32 fireRate;
		f32 fireSpread;
		f32 fireMuzzleVelocity;
		f32 bulletLifeSecs;
		f32 bulletDamage;
		// timers
		int idleTime;
		// variables
		s32 shotTime;
		// grenade
		f32 grenadeStep;
		f32 grenadeDistance;
		f32 grenadeTimeout;
		int grenades;
		int initialGrenades;
		int grenadeType;
		// crosshair
		Vec2f crosshairOffset;
		f32 defaultCrosshairDistance;
		bool crosshair;
		f32 crosshairEasing;
		f32 crosshairMaxDist;
		int crosshairDownAllowed;
		int crosshairUpAllowed;
		int crosshairRightAllowed;
		int crosshairLeftAllowed;
		int crosshairAllowedTicks;
		int crosshairTime;
		float crosshairSpeed;
		int crosshairMinTime;
		// crouch
		bool crouching;
		bool oldCrouching;
		int lockCrouch;
		// slide
		bool sliding;
		bool oldSliding;
		// death
		bool dead;
		int deadTime;
		// weapons
		int ammo;
		int initialAmmo;
		// stunned
		bool stunned;
		s8 stunTime;
		//AI
		Vec2f ai_grenadeOffset;
		int reactionTime;
		int aiTimer1, aiTimer2;
		// movement
		bool onLadder;
		bool canJump;
		bool canWalk;
		bool canCrouch;
		bool allowWalk;
		bool allowJump;
		bool allowCrouch;
		// anims
		bool specialAnim;
		// modifiers
		f32 walkSpeedModifier;
		f32 jumpSpeedModifier;
		// dead
		int deadScreamTime;
		int biteTime;
		// effects/locale cache
		bool inWater, oldInWater;
		bool waterSurface, oldWaterSurface;
		// sounds
		f32 pitch;

		// class specific
		// (consider some way of making this less wasteful)
		// sniper
		Vec2f lastSoundCrosshairOffset;
		int camoMode;
		// medic
		bool shield;
		int healTime;
		int supplyTime;
		// commando
		bool wallGrab;
		bool oldWallGrab;
		int flashbangEndTime;
		Vec2f flashbangPos;
		// engineer
		u8 engineerState;
		u16 missileId;
		u8 bombs, initialBombs;

		string primaryName, secondaryName;

		//variables
		CBlob@ blob;
		CMap@ map;
		Vec2f pos;
		Vec2f vel;
		f32 vellen;
		Vec2f aimpos;
		bool inMenu;
		bool up;
		bool down;
		bool left;
		bool right;
		bool fire;
		bool fire2;
		bool jump;
		bool crouch;
		bool isMyPlayer;
		bool onGround;
		bool onWall;
		bool facingLeft;
		bool attached;
		f32 direction;
		bool local;
		f32 radius;
		CSprite@ sprite;
		CShape@ shape;
		u32 gametime;

		//constructor
		Data()
		{
			type = 0;
			jumpCounter = 0;
			airTime = 0;
			jumpMax = 10;
			oldLedgeClimb = ledgeClimb = false;
			fireTime = 0;
			fireRate = 0;
			fireSpread = 0.0f;
			fireMuzzleVelocity = 0.0f;
			ammo = initialAmmo = 0;
			bulletLifeSecs = 0.4f;
			bulletDamage = 1.0f;
			idleTime = 0;
			shotTime = 0;
			grenadeStep = 0.0f;
			grenadeTimeout = 0;
			grenades = initialGrenades = 0;
			oldCrouching = crouching = false;
			lockCrouch = 0;
			crosshair = false;
			crosshairDownAllowed = 0;
			crosshairUpAllowed = 0;
			crosshairRightAllowed = 0;
			crosshairLeftAllowed = 0;
			crosshairAllowedTicks = 11;
			crosshairMaxDist = 128.0f;
			crosshairTime = 0;
			defaultCrosshairDistance = 42.0f;
			crosshairEasing = 0.0f;
			crosshairSpeed = 5.0f;
			crosshairMinTime = 10;
			oldSliding = sliding = false;
			dead = false;
			deadTime = 0;
			grenades = 0;
			ammo = initialAmmo = 0;
			stunned = false;
			stunTime = 0;
			specialAnim = false;
			camoMode = 0;
			canCrouch = true;
			allowWalk = allowJump = allowCrouch = true;
			walkSpeedModifier = jumpSpeedModifier = 1.0f;
			shield = false;
			missileId = 0;
			reactionTime = 0;
			wallGrab = false;
			attached = false;
			healTime = 0;
		}
	};

	// helper functions

	Data@ getData(CBlob@ this)
	{
		Soldier::Data@ data;
		this.get("data", @data);
		return data;
	}

	//

	bool inAir(Data@ data)
	{
		return (!data.onGround && !data.inWater && !data.onLadder);
	}

	void SetCrouching(CBlob@ this, Data@ data, const bool crouching)
	{
		data.oldCrouching = data.crouching;
		data.crouching = crouching;
		if (data.crouching != data.oldCrouching)
		{
			data.crouching ? this.Tag("crouching") : this.Untag("crouching");
		}
	}

	Vec2f getFireOffset(CBlob@ this, Data@ data)
	{
		return Vec2f(0.0f, data.crouching ? -1.0f : -7.0f);
	}

	Vec2f wrapRay(Vec2f start, Vec2f direction, float len, float &out newlen)
	{
		CMap@ map = getMap();
		Vec2f normdir = direction;
		normdir.Normalize();
		Vec2f side = Vec2f(1, 0);
		float facdir = Maths::Abs(normdir * side) * len;
		float mapsize = map.tilemapwidth * map.tilesize;
		float sidedist = Maths::Min(start.x, mapsize - start.x);
		newlen = 0;
		if (facdir > sidedist)
		{
			Vec2f oldstart = start;
			//other edge first
			start = Vec2f(direction.x <= 0 ? 0.01f : mapsize - 0.01f, start.y + (normdir * Vec2f(0, 1) * sidedist));
			newlen = len - (oldstart - start).Length();
			//set correct edge after getting length
			start.x = direction.x > 0 ? 0.01f : mapsize - 0.01f;
		}
		return start;
	}

	Vec2f wrappedPos(Vec2f pos)
	{
		CMap@ map = getMap();
		float mapsize = map.tilesize * map.tilemapwidth;
		if (pos.x < 0)
			pos.x += mapsize;
		if (pos.x > mapsize)
			pos.x -= mapsize;

		return pos;
	}

	//used here and there for dmg functions
	//returns if a wall was hit, but not where
	bool GatherStuffInRay(CBlob@ this, HitInfo@[]@ hits, Vec2f start, Vec2f direction, f32 len = 500.0f)
	{
		CMap@ map = getMap();
		HitInfo@[] hitInfos;

		f32 mapsize = map.tilesize * map.tilemapwidth;
		Vec2f normdir = direction; normdir.Normalize();

		f32 newlen = 0.0f;
		Vec2f wrapped = wrapRay(start, direction, len, newlen);

		Vec2f[] starts = {start, wrapped};
		f32[] lens = {len, newlen};

		for (uint i = 0; i < starts.length; i++)
		{
			HitInfo@[] theseinfos;
			map.getHitInfosFromRay(starts[i], -direction.Angle(), lens[i], this, @theseinfos);

			for (uint j = 0; j < theseinfos.length; j++)
			{
				theseinfos[j].distance += (len - lens[i]);
				hitInfos.push_back(theseinfos[j]);
			}
		}

		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;

			if (b is null) //blocked by tiles
			{
				if (hi.hitpos.x > 0 && hi.hitpos.x < mapsize)
				{
					hits.push_back(hi);
					return true;
				}
				continue;
			}
			//hack: only collect players and explosives
			if (b is this || b.getTeamNum() == this.getTeamNum() || (!b.hasTag("player") && !b.hasTag("explosive")))
			{
				continue;
			}


			//check crouching overlaps
			if (b.hasTag("crouching"))
			{
				if (normdir.y < 0.87 && //not moving down more than 60deg
				    hi.hitpos.y < b.getPosition().y - b.getRadius() * 0.5f)
					continue;
			}

			//check if already there
			for (uint j = 0; j < hits.length; j++)
			{
				if (hits[j].blob is b)
				{
					continue;
				}
			}

			hits.push_back(hi);
		}

		return false;
	}

	int getTeamColorForSprite(CBlob@ blob)
	{
		return blob.getTeamNum();
	}

};
