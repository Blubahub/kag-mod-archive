//common knight header
namespace JuggernautStates
{
	enum States
	{
		normal = 0,
		stun,
		charging,
		chargedAttack,
		kickAttack,
		grabbing,
		grabbed,
		throwing,
		fatality
	}
}
namespace JuggernautVars
{
	const ::u8 chargeTime=	15;
	const ::u8 chargeLimit=	25;
	const ::u8 attackTime=	18;
	const ::u8 kickTime=	12;
	const ::u8 grabTime=	12;
	const ::u8 throwTime=	12;
	const ::u8 fatalityTime=88;
	
	const ::u8 attackDelay=	6;

	const ::f32 chargeMaxMoveSpeed=	3.5f;
}
shared class JuggernautInfo
{
	u8 stun;
	u8 actionTimer;
	u8 attackDelay;
	u8 tileDestructionLimiter;
	bool dontHitMore;

	u8 state;
	u8 prevState;
	Vec2f slash_direction;
	bool normalSprite;
};
//shared attacking/bashing constants (should be in JuggernautVars but used all over)

/*const int DELTA_BEGIN_ATTACK = 2;
const int DELTA_END_ATTACK = 5;
const f32 DEFAULT_ATTACK_DISTANCE = 16.0f;
const f32 MAX_ATTACK_DISTANCE = 18.0f;
const f32 SHIELD_KNOCK_VELOCITY = 3.0f;

const f32 SHIELD_BLOCK_ANGLE = 175.0f;
const f32 SHIELD_BLOCK_ANGLE_GLIDING = 140.0f;
const f32 SHIELD_BLOCK_ANGLE_SLIDING = 160.0f;*/