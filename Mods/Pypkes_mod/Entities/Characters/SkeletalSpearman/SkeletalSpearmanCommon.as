//common knight header
namespace SkeletalSpearmanStates
{
	enum States
	{
		normal = 0,
		shielding,
		shielddropping,
		spear_drawn,
		spear_cut,
		spear_cut_mid,
		spear_cut_up,
		spear_power,
		spear_power_super
	}
}

namespace SkeletalSpearmanVars
{
	const ::s32 resheath_time = 2;

	const ::s32 slash_charge = 15;
	const ::s32 slash_charge_level2 = 38;
	const ::s32 slash_charge_limit = slash_charge_level2 + slash_charge + 10;
	const ::s32 slash_move_time = 4;
	const ::s32 slash_time = 13;
	const ::s32 double_slash_time = 8;

	const ::f32 slash_move_max_speed = 8.2f;
	const u32 glide_down_time = 50;
}

shared class SkeletalSpearmanInfo
{
	u8 spearTimer;
	u8 shieldTimer;
	u8 tileDestructionLimiter;
	u32 slideTime;

	u8 state;
	Vec2f slash_direction;
	s32 shield_down;
};


//checking state stuff

bool isShieldState(u8 state)
{
	return (state >= SkeletalSpearmanStates::shielding);
}

bool isSpecialShieldState(u8 state)
{
	return (state > SkeletalSpearmanStates::shielding);
}

bool isSwordState(u8 state)
{
	return (state >= SkeletalSpearmanStates::spear_drawn && state <= SkeletalSpearmanStates::spear_power_super);
}

bool inMiddleOfAttack(u8 state)
{
	return ((state > SkeletalSpearmanStates::spear_drawn && state <= SkeletalSpearmanStates::spear_power_super));
}

//checking angle stuff

f32 getCutAngle(CBlob@ this, u8 state)
{
	f32 attackAngle = (this.isFacingLeft() ? 180.0f : 0.0f);

	if (state == SkeletalSpearmanStates::spear_cut_mid)
	{
		attackAngle += (this.isFacingLeft() ? 30.0f : -30.0f);
	}

	return attackAngle;
}

f32 getCutAngle(CBlob@ this)
{
	Vec2f aimpos = this.getMovement().getVars().aimpos;
	int tempState;
	Vec2f vec;
	int direction = this.getAimDirection(vec);

	if (direction == -1)
	{
		tempState = SkeletalSpearmanStates::spear_cut_up;
	}
	else if (direction == 0)
	{
		if (aimpos.y < this.getPosition().y)
		{
			tempState = SkeletalSpearmanStates::spear_cut_mid;
		}
	}

	return getCutAngle(this, tempState);
}

//shared attacking/bashing constants (should be in KnightVars but used all over)

const int DELTA_BEGIN_ATTACK = 2;
const int DELTA_END_ATTACK = 5;
const f32 DEFAULT_ATTACK_DISTANCE = 24.0f;
const f32 MAX_ATTACK_DISTANCE = 26.0f;
const f32 SHIELD_KNOCK_VELOCITY = 2.0f;

const f32 SHIELD_BLOCK_ANGLE = 175.0f;
const f32 SHIELD_BLOCK_ANGLE_SLIDING = 160.0f;