#include "SimpleBrainCommon.as"

namespace SimpleBrain
{
	shared enum MoveType
	{
		RANDOM,
		LEFT,
		RIGHT,
		LADDER_UP,
		LADDER_DOWN,
		JUMP_OVER,
		JUMP_DOWN
	}

	const string[] MOVETYPE_NAMES = { "RANDOM", "LEFT", "RIGHT", "LADDER_UP", "LADDER_DOWN", "JUMP_OVER", "JUMP_DOWN" };

	shared class Vars
	{
		MoveType state;
		int time;
		int ladderProbability;
		int onWallTime;

		Vars()
		{
			state = RANDOM;
			ladderProbability = 10;
		}
	};

	void SetupMoveVars(States@ states)
	{
		//move state
		SimpleBrain::State@ move = states.available[0];
		SimpleBrain::Vars movevars;
		move.vars.set("movestate", movevars);

		//selfcare state
		SimpleBrain::State@ care = states.available[1];
		care.vars.set("movestate", movevars);
	}

	Random _move_rand(0x1998);

	void SwitchMoveState(Vars@ move, MoveType state)
	{
		if (state != move.state)
		{
			//printf("movestate: " + MOVETYPE_NAMES[int(state)]);
			move.state = state;
			move.time = 100;
		}
	}

	void GoombaMovement(CBlob@ blob, SimpleBrain::State@ state)
	{
		CBrain@ brain = blob.getBrain();
		CBlob @target = brain.getTarget();
		CMap@ map = getMap();
		Vec2f mypos = blob.getPosition();
		const f32 radius = blob.getRadius();

		Vars@ move;
		state.vars.get("movestate", @move);
		if (move is null)
		{
			warn("no movestate");
			return;
		}

		// hack for parachute
		if (!blob.isOnGround() && blob.getTickSinceCreated() < 60 + XORRandom(30))
		{
			return;
		}

		const bool randomDirection = getRules().get_string("gamemode") == "Skirmish"; // HACK:!
		const float rayDist = map.tilesize * 2.0f;

		// move left or right

		if (move.state == LEFT || move.state == RIGHT)
		{
			const bool left = move.state == LEFT;
			const float dir = left ? -1.0f : 1.0f;
			SimpleBrain::ComplexGoTowards(blob, blob.getPosition() + Vec2f(dir * rayDist, 0.0f));

			// switch directions on wall
			{
				map.debugRaycasts = true;
				const bool upper = map.rayCastSolid(mypos + Vec2f(0.0f, -7.5f), mypos + Vec2f(dir * rayDist, -7.5f));
				const bool lower = map.rayCastSolid(mypos, mypos + Vec2f(dir * rayDist,  0.0f));
				map.debugRaycasts = false;
				if (upper || (lower && map.isTileSolid(mypos + Vec2f(0.0f, -radius * 2.0f))))
				{
					move.time -= 5;
				}
			}

			// switch direction on screen edge
			{
				if (mypos.x < map.tilesize * 1.0f || mypos.x > (map.tilemapwidth - 1.0f)*map.tilesize)
				{
					move.time -= 5;
				}
			}

			// ladder?
			const bool onLadder = map.hasTileFlag(map.getTileOffset(mypos), Tile::LADDER);
			if (onLadder || map.hasTileFlag(map.getTileOffset(mypos + Vec2f(0.0f, -map.tilesize * 3.0f)), Tile::LADDER))
			{
				if (_move_rand.NextRanged(move.ladderProbability) == 0)
				{
					SwitchMoveState(move, LADDER_UP);
				}
				else
				{
					if (move.ladderProbability > 5)
						move.ladderProbability--;
				}
			}
			if (!blob.isOnGround() &&
			        (onLadder || map.hasTileFlag(map.getTileOffset(mypos + Vec2f(0.0f, map.tilesize * 3.0f)), Tile::LADDER)))
			{
				//printf("ladder downb");
				if (_move_rand.NextRanged(move.ladderProbability) == 0)
				{
					SwitchMoveState(move, LADDER_DOWN);
				}
				else
				{
					if (move.ladderProbability > 5)
						move.ladderProbability--;
				}
			}

			// fall down randomly in pit
			bool pit = !onLadder && !map.rayCastSolid(mypos, mypos + Vec2f(0.0f, map.tilesize * 5.0f));
			if (pit && XORRandom(25) == 0)
			{
				SwitchMoveState(move, JUMP_DOWN);
			}

			// timeout if oging in wrong direction
			if (!randomDirection && ((blob.getTeamNum() == 0 && left) || (blob.getTeamNum() == 1 && !left)))
			{
				move.time -= 1;
			}

			// switch side if 'timeout'

			if (move.time < 0)
			{
				SwitchMoveState(move, left ? RIGHT : LEFT);
			}
		}

		// ladder up/down

		if (move.state == LADDER_UP || move.state == LADDER_DOWN)
		{
			const bool up = move.state == LADDER_UP;

			// stay on ladder

			if (map.hasTileFlag(map.getTileOffset(mypos + Vec2f(map.tilesize, 0.0f)), Tile::LADDER))
			{
				blob.setKeyPressed(key_right, true);
			}
			else if (map.hasTileFlag(map.getTileOffset(mypos + Vec2f(-map.tilesize, 0.0f)), Tile::LADDER))
			{
				blob.setKeyPressed(key_left, true);
			}
			else if (!map.hasTileFlag(map.getTileOffset(mypos), Tile::LADDER))
			{
				move.time -= 10;
				//printf("no ladder");
			}

			if (!up && blob.isOnGround())
			{
				move.time -= 20;
			}

			// move up/down ladder

			if (up)
			{
				blob.setKeyPressed(key_jump, true);
			}
			else
			{
				blob.setKeyPressed(key_crouch, true);
			}

			if (move.time < 0)
			{
				SwitchMoveState(move, RANDOM);
			}

			move.ladderProbability = 40;
		}

		if (move.state == JUMP_DOWN)
		{
			bool pit = !map.rayCastSolid(mypos, mypos + Vec2f(0.0f, map.tilesize * 3.0f));
			move.time -= pit ? 5 : 20;
			const bool onLadder = map.hasTileFlag(map.getTileOffset(mypos), Tile::LADDER);
			if (onLadder)
			{
				SwitchMoveState(move, LADDER_DOWN);
			}
			else if (move.time < 0)
			{
				SwitchMoveState(move, RANDOM);
			}
		}

		if (move.state == RANDOM)
		{
			// HACK:
			if (randomDirection)
			{
				SwitchMoveState(move, _move_rand.NextRanged(2) == 0 ? LEFT : RIGHT);
			}
			else
			{
				SwitchMoveState(move, blob.getTeamNum() == 0 ? RIGHT : LEFT);
			}
		}
	}

	void EscapeExplosive(CBlob@ blob, SimpleBrain::State@ state)
	{
		CBrain@ brain = blob.getBrain();
		CBlob @target = brain.getTarget();
		Vec2f pos = blob.getPosition();
		CBlob@ grenade = SimpleBrain::getVisibleBlobWithTag(pos, "explosive", SimpleBrain::EXPLOSIVE_DISTANCE);
		if (grenade !is null)
		{
			Vec2f grenadePos = grenade.getPosition();
			Vec2f targetPos;
			if (grenadePos.x > pos.x)
				targetPos.Set(grenadePos.x - 1.5f * SimpleBrain::EXPLOSIVE_DISTANCE, pos.y);
			else
				targetPos.Set(grenadePos.x + 1.5f * SimpleBrain::EXPLOSIVE_DISTANCE, pos.y);

			Vec2f escapePos = brain.getClosestNodeAtPosition(targetPos);
			SimpleBrain::JustGo(blob, escapePos);

			if (SimpleBrain::isObstacleInFrontOfTarget(blob.getPosition(), true, grenade.getPosition()))
			{
				blob.setKeyPressed(key_jump, false);
				blob.setKeyPressed(key_crouch, true);
			}
		}
	}

	bool GoToMedkit(CBlob@ blob)
	{
		CBrain@ brain = blob.getBrain();
		CBlob @target = brain.getTarget();
		Vec2f pos = blob.getPosition();

		// CBlob@[] supplies;
  //       getBlobsByName( "supply", @supplies );
		// CBlob@ medkit = SimpleBrain::getClosestBlobFromArray(pos, supplies);

		CBlob@ medkit = SimpleBrain::getVisibleBlobByName(pos, "supply", 150);
		if (medkit !is null)
		{
			Vec2f medkitPos = medkit.getPosition();
			SimpleBrain::JustGo(blob, medkitPos, 0.2f);

			if (SimpleBrain::isObstacleInFrontOfTarget(blob.getPosition(), true, medkitPos))
			{
				blob.setKeyPressed(key_jump, true);
			}
			return true;
		}
		return false;
	}	

}
