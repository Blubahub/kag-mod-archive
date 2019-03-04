//common BallPlayer header
namespace BallPlayerStates
{
	enum States
	{
		normal = 0,
		smack_drawn,
		smack_ing,
		smack_coolingdown,
	}
}

namespace BallPlayerVars
{
	const ::s32 resheath_time = 25;

	const ::s32 smack_charge = 15;
	const ::s32 smack_charge_level2 = 38;
	const ::s32 smack_charge_limit = smack_charge_level2 + smack_charge + 10;
	const ::s32 smack_move_time = 4;

	const ::f32 smack_move_max_speed = 3.5f;
}

shared class BallPlayerInfo
{
	u8 smackTimer;
	f32 chargeAmount;

	u8 state;
	Vec2f smack_direction;
};

//checking state stuff

bool isSmackState(u8 state)
{
	return (state > BallPlayerStates::smack_drawn && state <= BallPlayerStates::smack_ing);
}

bool inMiddleOfAttack(u8 state)
{
	return (state > BallPlayerStates::smack_drawn && state <= BallPlayerStates::smack_ing);
}

const int DELTA_BEGIN_ATTACK = 2;
const int DELTA_END_ATTACK = 10;
const f32 ATTACK_DISTANCE = 16.0f;