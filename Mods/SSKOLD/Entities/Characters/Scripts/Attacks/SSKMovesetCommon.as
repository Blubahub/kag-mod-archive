#include "SSKStatusCommon.as"
#include "StandardControlsCommon.as"
#include "Hitters.as"

// common move functions

shared class MoveAnimation
{
	u8 moveType;
	string name;

	int tick;
	u16 currFrameIndex;

	MoveFrame@[] moveFrames;

	CustomHitData@ customHitData;

	MoveAnimation() {} // required for handles to work

	MoveAnimation(u8 _moveType, string _name, MoveFrame@[] _moveFrames)
	{
		moveType = _moveType;
		name = _name;
		moveFrames = _moveFrames;

		tick = 0;
		currFrameIndex = 0;

		int tickSum = 0;
		for(int i = 0; i < moveFrames.length(); i++)
		{
			tickSum += moveFrames[i].holdTime;
			moveFrames[i].endTick = tickSum;
		}	
	}

	MoveAnimation(u8 _moveType, string _name, MoveFrame@[] _moveFrames, CustomHitData@ _customHitData)
	{
		moveType = _moveType;
		name = _name;
		moveFrames = _moveFrames;
		customHitData = _customHitData;

		tick = 0;
		currFrameIndex = 0;

		int tickSum = 0;
		for(int i = 0; i < moveFrames.length(); i++)
		{
			tickSum += moveFrames[i].holdTime;
			moveFrames[i].endTick = tickSum;
		}	
	}

	bool opEquals(const int &in otherMoveType)
	{
		return moveType == otherMoveType;
	}
};

shared class MoveFrame
{
	u16 spriteFrameNum;
	u8 holdTime;

	int endTick;

	f32 attackAngle;
	f32 attackArc;
	f32 attackRange;
	f32 damage;

	bool isGrabFrame;

	bool noPhysics;

	MoveFrame() {} // required for handles to work

	MoveFrame(u16 _spriteFrameNum, u8 _holdTime = 1, f32 _attackAngle = 0.0f, f32 _attackArc = 0.0f, f32 _attackRange = 0.0f, f32 _damage = 0.0f, bool _isGrabFrame = false, bool _noPhysics = false)
	{
		spriteFrameNum = _spriteFrameNum;

		holdTime = _holdTime;

		attackAngle = _attackAngle;
		attackArc = _attackArc;
		attackRange = _attackRange;
		damage = _damage;

		isGrabFrame = _isGrabFrame;

		noPhysics = _noPhysics;
	}
};

shared class CustomHitData
{
	u8 hitstunTime;
	f32 minKnockback;
	f32 scalingKnockback;
	u16 dazeTime;

	CustomHitData(u8 _hitstunTime = 0, f32 _minKnockback = 0.0f, f32 _scalingKnockback = 0.0f, u16 _dazeTime = 0)
	{
		hitstunTime = _hitstunTime;
		minKnockback = _minKnockback;
		scalingKnockback = _scalingKnockback;
		dazeTime = _dazeTime;
	}
};

namespace MoveTypes
{
	enum type
	{
		GRAB = 0,
		THROW,
		STANDARD_ATTACK,
		UP_SPECIAL,
		NUM_MOVE_TYPES
	};
}

int getMoveIndexByType(MoveAnimation@[] moveset, u8 moveType)
{
	for(int i = 0; i < moveset.length(); i++)
	{
		if (moveset[i] == moveType)
		{
			return i;
		}
	}	

	return -1;
}

void handleStartMove(CBlob@ blob, MoveAnimation@ moveAnim)
{
	SSKStatusVars@ statusVars;
	if (!blob.get("statusVars", @statusVars)) 
	{ 
		return; 
	}

	CSprite@ sprite = blob.getSprite();

	Animation@ spriteAnim = sprite.getAnimation(moveAnim.name);
	if (spriteAnim is null)
	{
		@spriteAnim = sprite.addAnimation(moveAnim.name, 0, false);
		for(int i = 0; i < moveAnim.moveFrames.length(); i++)
		{
			spriteAnim.AddFrame(moveAnim.moveFrames[i].spriteFrameNum);
		}	
	}

	sprite.SetAnimation(moveAnim.name);

	moveAnim.tick = 0;
	moveAnim.currFrameIndex = 0; 

	statusVars.inMoveAnimation = true;
	statusVars.currMoveAnimation = moveAnim;

	// face mouse aim position before attack
 	bool faceLeft = (blob.getAimPos().x <= blob.getPosition().x);
	statusVars.isAttackingLeft = faceLeft;
}

void updateCommonMoves(CBlob@ blob, SSKStatusVars@ statusVars, MoveAnimation@ moveAnim)
{
	if (moveAnim.currFrameIndex >= moveAnim.moveFrames.length())
	{
		statusVars.inMoveAnimation = false;
		return;
	}

	CSprite@ sprite = blob.getSprite();
	Animation@ spriteAnim = sprite.getAnimation(moveAnim.name);
	u16 animFrame = sprite.getFrame();

	MoveFrame@ currMoveFrame = moveAnim.moveFrames[moveAnim.currFrameIndex];

	if (currMoveFrame.damage > 0.0f && !statusVars.hitThisFrame)
	{
		arcAttack(blob, statusVars.isAttackingLeft, currMoveFrame.damage, currMoveFrame.attackAngle, currMoveFrame.attackArc, currMoveFrame.attackRange, Hitters::sword, moveAnim.customHitData);
	}

	if (currMoveFrame.isGrabFrame)
	{
		arcGrab(blob, statusVars.isAttackingLeft, currMoveFrame.attackAngle, currMoveFrame.attackArc, currMoveFrame.attackRange);
	}

	spriteAnim.SetFrameIndex(moveAnim.currFrameIndex);

	if (moveAnim.tick >= currMoveFrame.endTick)
	{
		moveAnim.currFrameIndex++;
		statusVars.hitThisFrame = false;
	}

	moveAnim.tick++;
}

void arcAttack(CBlob@ blob, bool isFacingLeft, f32 damage, f32 aimangle, f32 arcdegrees, f32 attack_distance, u8 type, CustomHitData@ customHitData)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (isFacingLeft)
	{
		aimangle = 180 - aimangle;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	Vec2f aimVec(1, 0);
	aimVec.RotateBy(aimangle);
	Vec2f pos = blobPos + vel + Vec2f(0, -2);
	vel.Normalize();
	
	CMap@ map = blob.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;

	//get the actual aim angle
	f32 exact_aimangle = (blob.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, attack_distance, blob, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (b.hasTag("ignore sword")) continue;

				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canAttackHit(blob, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					server_customHit(blob, b, hi.hitpos, velocity, damage, type, true, customHitData);	// server_customHit() is server-side only

					SSKStatusVars@ statusVars;
					if (blob.get("statusVars", @statusVars))
					{
						statusVars.hitThisFrame = true;
					}

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else  // hitmap
				if (!dontHitMoreMap )
				{
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					if (ground || wood || dirt_stone || gold)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);
						f32 tileangle = offset.Angle();
						f32 dif = Maths::Abs(exact_aimangle - tileangle);
						if (dif > 180)
							dif -= 360;
						if (dif < -180)
							dif += 360;

						dif = Maths::Abs(dif);
						//print("dif: "+dif);

						if (dif < 20.0f)
						{
							//detect corner

							int check_x = -(offset.x > 0 ? -1 : 1);
							int check_y = -(offset.y > 0 ? -1 : 1);
							if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
							        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
								continue;

							bool canhit = true; //default true

							//dont dig through no build zones
							canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

							dontHitMoreMap = true;
							if (canhit)
							{
								map.server_DestroyTile(hi.hitpos, 0.1f, blob);
							}
						}
					}
				}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f))    // aiming down or slash
	{
		f32 tilesize = map.tilesize;
		f32 radius = blob.getRadius();
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = blob.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, blob);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

bool canAttackHit(CBlob@ blob, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (blob.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != blob.getTeamNum();
}

bool canGrab(CBlob@ blob, CBlob@ b)
{
	if (b.hasTag("player") && b.getTeamNum() == blob.getTeamNum())
		return false;
	else
		return true;
}

void arcGrab(CBlob@ blob, bool isFacingLeft, f32 aimangle, f32 arcdegrees, f32 attack_distance)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (isFacingLeft)
	{
		aimangle = 180 - aimangle;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	Vec2f aimVec(1, 0);
	aimVec.RotateBy(aimangle);
	Vec2f pos = blobPos + vel + Vec2f(0, -2);
	vel.Normalize();
	
	CMap@ map = blob.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;

	//get the actual aim angle
	f32 exact_aimangle = (blob.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, attack_distance, blob, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;

			if (b is blob)
				continue;

			if (b !is null && !dontHitMore) // blob
			{
				if (!canGrab(blob, b))
				{
					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					if (b.canBePickedUp(blob) || b.hasTag("player"))
					{
						SSKStatusVars@ blobStatusVars;
						if (b.get("statusVars", @blobStatusVars))
						{
							if (getNet().isServer())
							{
								SyncGrabEvent(b);
							}
						}

						blob.server_Pickup(b);
						dontHitMore = true;
					}
				}
			}
		}
	}
}