//common ninja header
/*
/rcon CPlayer@ player=getPlayerByUsername('cirpons');CBlob@ blob=player.getBlob();CBlob@ test = server_CreateBlobNoInit('ninja');test.setPosition(blob.getPosition());blob.server_Die();test.Init();test.server_SetPlayer(player);test.server_setTeamNum(player.getTeamNum());
*/

namespace NinjaStates
{
	enum States
	{
		normal = 0,
		sword_drawn,
		sword_cut_mid,
		sword_cut_mid_down,
		sword_cut_up,
		sword_cut_down,
		sword_power,
		sword_power_super
	}
}

const f32 ninja_grapple_length = 72.0f / 2;
const f32 ninja_grapple_slack = 16.0f;
const f32 ninja_grapple_throw_speed = 20.0f;

const f32 ninja_grapple_force = 2.0f;
const f32 ninja_grapple_accel_limit = 1.5f *2;
const f32 ninja_grapple_stiffness = 0.1f;

namespace NinjaVars
{
	const ::s32 resheath_time = 2;

	const ::s32 slash_charge = 13;
	const ::s32 slash_charge_level2 = 34;
	const ::s32 slash_charge_limit = slash_charge_level2 + slash_charge + 14;
	const ::s32 slash_move_time = 4;
	const ::s32 slash_time = 13;
	const ::s32 double_slash_time = 8;

	const ::f32 slash_move_max_speed = 3.5f;

}

shared class NinjaInfo
{
	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	f32 cache_angle;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	u8 swordTimer;
	bool doubleslash;
	u8 tileDestructionLimiter;
	u32 slideTime;

	u8 state;
	Vec2f slash_direction;

	NinjaInfo()
	{
		grappling = false;
	}
};

const string grapple_sync_cmd = "grapple sync";

void SyncGrapple(CBlob@ this)
{
	NinjaInfo@ ninja;
	if (!this.get("ninjaInfo", @ninja)) { return; }

	CBitStream bt;
	bt.write_bool(ninja.grappling);

	if (ninja.grappling)
	{
		bt.write_u16(ninja.grapple_id);
		bt.write_u8(u8(ninja.grapple_ratio * 250));
		bt.write_Vec2f(ninja.grapple_pos);
		bt.write_Vec2f(ninja.grapple_vel);
	}

	this.SendCommand(this.getCommandID(grapple_sync_cmd), bt);
}

//TODO: saferead
void HandleGrapple(CBlob@ this, CBitStream@ bt, bool apply)
{
	NinjaInfo@ ninja;
	if (!this.get("ninjaInfo", @ninja)) { return; }

	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	grappling = bt.read_bool();

	if (grappling)
	{
		grapple_id = bt.read_u16();
		u8 temp = bt.read_u8();
		grapple_ratio = temp / 250.0f;
		grapple_pos = bt.read_Vec2f();
		grapple_vel = bt.read_Vec2f();
	}

	if (apply)
	{
		ninja.grappling = grappling;
		if (ninja.grappling)
		{
			ninja.grapple_id = grapple_id;
			ninja.grapple_ratio = grapple_ratio;
			ninja.grapple_pos = grapple_pos;
			ninja.grapple_vel = grapple_vel;
		}
	}
}

namespace BombType
{
	enum type
	{
		bomb = 0,
		water,
		count
	};
}

const string[] bombNames = { "Bomb",
                             "Water Bomb"
                           };

const string[] bombIcons = { "$Bomb$",
                             "$WaterBomb$"
                           };

const string[] bombTypeNames = { "mat_bombs",
                                 "mat_waterbombs"
                               };


//checking state stuff

bool isSwordState(u8 state)
{
	return (state >= NinjaStates::sword_drawn && state <= NinjaStates::sword_power_super);
}

bool inMiddleOfAttack(u8 state)
{
	return ((state > NinjaStates::sword_drawn && state <= NinjaStates::sword_power_super));
}

//checking angle stuff

f32 getCutAngle(CBlob@ this, u8 state)
{
	f32 attackAngle = (this.isFacingLeft() ? 180.0f : 0.0f);

	if (state == NinjaStates::sword_cut_mid)
	{
		attackAngle += (this.isFacingLeft() ? 30.0f : -30.0f);
	}
	else if (state == NinjaStates::sword_cut_mid_down)
	{
		attackAngle -= (this.isFacingLeft() ? 30.0f : -30.0f);
	}
	else if (state == NinjaStates::sword_cut_up)
	{
		attackAngle += (this.isFacingLeft() ? 80.0f : -80.0f);
	}
	else if (state == NinjaStates::sword_cut_down)
	{
		attackAngle -= (this.isFacingLeft() ? 80.0f : -80.0f);
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
		tempState = NinjaStates::sword_cut_up;
	}
	else if (direction == 0)
	{
		if (aimpos.y < this.getPosition().y)
		{
			tempState = NinjaStates::sword_cut_mid;
		}
		else
		{
			tempState = NinjaStates::sword_cut_mid_down;
		}
	}
	else
	{
		tempState = NinjaStates::sword_cut_down;
	}

	return getCutAngle(this, tempState);
}

//shared attacking/bashing constants (should be in NinjaVars but used all over)

const int DELTA_BEGIN_ATTACK = 2;
const int DELTA_END_ATTACK = 5;
const f32 DEFAULT_ATTACK_DISTANCE = 16.0f;
const f32 MAX_ATTACK_DISTANCE = 18.0f;
