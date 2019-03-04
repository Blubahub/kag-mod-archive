#define SERVER_ONLY

#include "SimpleStates.as"
#include "SoldierCommon.as"
#include "SimpleCommonStates.as"

void onInit(CBrain@ this)
{
	CBlob@ blob = this.getBlob();
	SimpleBrain::States@ states = SimpleBrain::getStates(blob);

	states.available.push_back(SimpleBrain::State("move", Prioritize_Move, Do_Move));
	states.available.push_back(SimpleBrain::State("selfcare", Prioritize_SelfCare, Do_SelfCare));
	states.available.push_back(SimpleBrain::State("enemy visible", Prioritize_EnemyVisible, Do_EnemyVisible));
	states.available.push_back(SimpleBrain::State("escape grenade", Prioritize_EscapeGrenade, Do_EscapeGrenade));
	states.available.push_back(SimpleBrain::State("throw grenade", Prioritize_ThrowGrenade, Do_ThrowGrenade));
	SimpleBrain::SetupMoveVars(states);
}

// MOVE

void Prioritize_Move(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;

	p += 0.5f;
	if (state.type == "throw grenade")
	{
		p -= 0.5f;
	}

	state.priority = p;
}

void Do_Move(CBlob@ blob, SimpleBrain::State@ state)
{
	Vec2f pos = blob.getPosition();

	SimpleBrain::GoombaMovement(blob, state);

	// fire

	CBlob@[] players;
	getBlobsByTag("player", @players);
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		if (potential !is blob && blob.getTeamNum() != potential.getTeamNum()
		        && !potential.hasTag("dead") && isInLineOfFire(blob.getPosition(), potential.getPosition())
		   )
		{
			AttackBlob(blob, potential, false);
		}
	}
}

// SELF_CARE
// either go to medic or wander and look for medkits

void Prioritize_SelfCare(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;

	Soldier::Data@ data;
	blob.get("data", @data);

	if (data.ammo == 0 || data.dead)
		p += 2;

	state.priority = p;
}

void Do_SelfCare(CBlob@ blob, SimpleBrain::State@ state)
{
	if (!SimpleBrain::GoToMedkit(blob)){
		SimpleBrain::GoombaMovement(blob, state);
	}
}

// ENEMY_VISIBLE

void Prioritize_EnemyVisible(CBlob@ blob, SimpleBrain::State@ state)
{
	CBlob@ enemy = SimpleBrain::getVisibleEnemy(blob, SimpleBrain::VISIBLE_DISTANCE);

	f32 p = 0.0f;
	if (enemy !is null)
	{
		const bool facingEnemy = (blob.isFacingLeft() && enemy.getPosition().x < blob.getPosition().x)
		                         || (!blob.isFacingLeft() && enemy.getPosition().x > blob.getPosition().x);
		p += facingEnemy ? 0.55f : 0.65f;

		if (!isInLineOfFire(blob.getPosition(), enemy.getPosition()))
		{
			p -= 0.5f;
		}
	}
	if (state.type == "throw grenade")
	{
		p -= 0.5f;
	}

	state.priority = p;
}

void Do_EnemyVisible(CBlob@ blob, SimpleBrain::State@ state)
{
	CBrain@ brain = blob.getBrain();
	CBlob @target = brain.getTarget();

	// find enemy target if no target
	if (target is null)
	{
		@target = SimpleBrain::getVisibleEnemy(blob, SimpleBrain::VISIBLE_DISTANCE);
		brain.SetTarget(target);
	}
	else
	{
		AttackBlob(blob, target, true);
	}
}

// ESCAPE_GRENADE

void Prioritize_EscapeGrenade(CBlob@ blob, SimpleBrain::State@ state)
{
	f32 p = 0.0f;
	Vec2f pos = blob.getPosition();
	CBlob@ grenade = SimpleBrain::getVisibleBlobWithTag(pos, "explosive", SimpleBrain::EXPLOSIVE_DISTANCE);
	if (grenade !is null && !grenade.getShape().isStatic())
	{
		p += 1.0f;
	}

	state.priority = p;
}

void Do_EscapeGrenade(CBlob@ blob, SimpleBrain::State@ state)
{
	SimpleBrain::EscapeExplosive(blob, state);
}

// THROW GRENADE

void Prioritize_ThrowGrenade(CBlob@ blob, SimpleBrain::State@ state)
{
	Vec2f pos = blob.getPosition();
	Soldier::Data@ data = Soldier::getData(blob);
	CBlob@ grenadeNearby = SimpleBrain::getNearbyBlobWithTag(pos, "explosive", SimpleBrain::VISIBLE_DISTANCE);
	CBlob@ nearby = SimpleBrain::getNearbyEnemy(blob, SimpleBrain::VISIBLE_DISTANCE);

	f32 p = 0.0f;

	if (data.crosshair)  // dont do anything else while cooking nade
	{
		p += 10.0f;
	}

	if (nearby !is null)
	{
		const f32 goodDist = 15.0f;
		if ((pos - nearby.getPosition()).getLength() > SimpleBrain::EXPLOSIVE_DISTANCE) // not too close, so we dont get hurt
		{
			bool reachTarget = false;
			Vec2f drop1 = TestGrenadeDropPoint(blob, SimpleBrain::getGrenadeLobOffset(blob));
			Vec2f drop2 = TestGrenadeDropPoint(blob, SimpleBrain::getGrenadeStraightOffset(blob));
			Vec2f drop3 = TestGrenadeDropPoint(blob, SimpleBrain::getGrenadeDropOffset(blob));

			if ((drop1 - nearby.getPosition()).getLength() < goodDist)
			{
				data.ai_grenadeOffset = SimpleBrain::getGrenadeLobOffset(blob) ;
				reachTarget = true;
			}
			if ((drop2 - nearby.getPosition()).getLength() < goodDist && (drop2 - pos).getLength() > SimpleBrain::EXPLOSIVE_DISTANCE)
			{
				data.ai_grenadeOffset = SimpleBrain::getGrenadeStraightOffset(blob) ;
				reachTarget = true;
			}
			if ((drop3 - nearby.getPosition()).getLength() < goodDist)
			{
				data.ai_grenadeOffset = SimpleBrain::getGrenadeDropOffset(blob) ;
				reachTarget = true;
			}

			if (reachTarget)
			{
				p += 0.55f;
				if (grenadeNearby !is null)
				{
					p -= 0.5f;
				}
				if (blob.getShape().vellen > 0.01f)
				{
					p -= 0.25f;
				}
				if (!blob.isOnGround())
				{
					p -= 0.5f;
				}
				if (SimpleBrain::isObstacleInFrontOfTarget(blob.getPosition(), false, nearby.getPosition()))
				{
					p += 0.5f;
				}
				if (nearby.hasTag("crouching"))
				{
					p += 0.2f;
				}
			}
		}
	}

	state.priority = p;
}

void Do_ThrowGrenade(CBlob@ blob, SimpleBrain::State@ state)
{
	CBrain@ brain = blob.getBrain();
	CBlob @target = brain.getTarget();
	Vec2f pos = blob.getPosition();

	// find enemy target if no target
	if (target is null)
	{
		@target = SimpleBrain::getNearbyEnemy(blob, SimpleBrain::VISIBLE_DISTANCE);
		brain.SetTarget(target);
	}
	else
	{
		Soldier::Data@ data;
		blob.get("data", @data);
		bool hold = true;
		if (data.crosshair)
		{
			Vec2f pos = blob.getPosition();
			Vec2f desiredAim = pos + data.ai_grenadeOffset;
			Vec2f aim = pos + data.crosshairOffset;
			if (
			    ((desiredAim - aim).getLength() <= data.crosshairSpeed || data.crosshairOffset.getLength() >= data.crosshairMaxDist * 0.95f)
			    && desiredAim.y < aim.y
			    && data.grenadeStep > data.grenadeTimeout * 0.4f
			)
			{
				hold = false;
			}
			else
			{
				Vec2f vector = desiredAim - aim;
				vector.Normalize();
				data.crosshairOffset += vector * data.crosshairSpeed * 0.5f;
			}
		}

		if (hold)
		{
			blob.setKeyPressed(key_action2, true);
		}
	}
}

//

Vec2f getGrenadeLobOffset(CBlob@ blob)
{
	return Vec2f((blob.isFacingLeft() ? -1.0f : 1.0f) * 50.0f, -50.0f);
}

Vec2f getGrenadeStraightOffset(CBlob@ blob)
{
	return Vec2f((blob.isFacingLeft() ? -1.0f : 1.0f) * 180.0f, -40.0f);
}

Vec2f getGrenadeDropOffset(CBlob@ blob)
{
	return Vec2f((blob.isFacingLeft() ? -1.0f : 1.0f) * 10.0f, -10.0f);
}

Vec2f TestGrenadeDropPoint(CBlob@ blob, Vec2f offset)
{
	CMap@ map = blob.getMap();
	const f32 grenadeRadius = 2.0f;
	Vec2f current = blob.getPosition() + Vec2f((blob.isFacingLeft() ? -1.0f : 1.0f) * blob.getRadius() * 0.5f, -blob.getRadius() + grenadeRadius);
	Vec2f vel = offset * 0.1f; // HACK : VARS FROM SOLDIER.aas Grenade()
	const f32 len = vel.Normalize();
	vel *= Maths::Min(len, Soldier::maxThrow);
	Vec2f col;
	int timeout = 30;
	const f32 BOX2D_SCALE = 0.025f * 2.0f;
	while (!map.rayCastSolid(current, current + vel, col) && timeout > 0)
	{
		current += vel;
		vel.y += BOX2D_SCALE * sv_gravity;
		timeout--;
	}
	return current;
}

// ATTACK

bool isInLineOfFire(Vec2f pos, Vec2f targetPos)
{
	const f32 radius = 1.0f + 2.0f * Consts::SOLDIER_RADIUS;
	Vec2f offset = Vec2f(0.0f, -radius * 0.5f);
	Vec2f col;
	CMap@ map = getMap();
	return Maths::Abs(targetPos.y - pos.y) <= radius
	       && SimpleBrain::isScreenDistance(pos, targetPos)
	       && (!map.rayCastSolid(pos, targetPos, col)
	           || !map.rayCastSolid(pos + offset, targetPos + offset, col));
}

void AttackBlob(CBlob@ blob, CBlob @target, const bool move)
{
	if (target is null)
		return;
	CMap@ map = blob.getMap();
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	bool fire = true;
	bool enemyFire = SimpleBrain::areBulletsFlying(target, 50.0f);
	f32 height = Maths::Abs(targetPos.y - mypos.y);
	const bool targetCrouching = target.hasTag("crouching");
	const bool targetLower = targetPos.y - 4.0f > mypos.y;
	const bool targetHigher = targetPos.y + 4.0f < mypos.y;
	const bool onground = blob.isOnGround();
	Soldier::Data@ data = Soldier::getData(blob);

	// turn side

	const bool tooClose = Maths::Abs(mypos.x - targetPos.x) < 2.2f * target.getRadius();

	if (move)
	{
		bool facingleft = blob.isFacingLeft();
		if (targetPos.x > mypos.x && facingleft)
		{
			blob.setKeyPressed(key_left, false);
			blob.setKeyPressed(key_right, true);
		}
		else if (targetPos.x < mypos.x && !facingleft)
		{
			blob.setKeyPressed(key_right, false);
			blob.setKeyPressed(key_left, true);
		}

		if (tooClose && blob.isOnGround())
		{
			if (mypos.x > targetPos.x)
			{
				blob.setKeyPressed(key_right, true);
				blob.setKeyPressed(key_left, false);
			}
			else
			{
				blob.setKeyPressed(key_left, true);
				blob.setKeyPressed(key_right, false);
			}
		}
	}

	// enemy ducking?
	if (onground && !tooClose && (/*targetCrouching || */targetLower || enemyFire) && data.reactionTime <= 0)
	{
		//printf("lower");
		blob.setKeyPressed(key_crouch, true);
	}
	else if (targetHigher && !enemyFire)
	{
		//printf("higher "  + height);
		if (height < 4.0f * map.tilesize)
			blob.setKeyPressed(key_jump, true);
		else
		{
			fire = false;
			//printf("too high");
		}
	}

	const bool crouching = blob.isKeyPressed(key_crouch) && blob.isOnGround();
	const bool obstacleInFront = SimpleBrain::isObstacleInFrontOfTarget(mypos, crouching, targetPos, targetCrouching, target.getRadius());

	if (obstacleInFront || (!crouching && targetCrouching))
	{
		fire = false;
	}

	// reaction time
	if (data.reactionTime > 0)
	{
		fire = false;
	}
	data.reactionTime -= 2;

	// printf("fire " + fire + " obstacleInFront " + obstacleInFront + " rt " + data.reactionTime);

	// fire
	if (fire)
	{
		blob.setKeyPressed(key_action1, true);
	}
}
