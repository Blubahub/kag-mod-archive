//WraithArcher Include

namespace WraithArcherParams
{
	enum Aim
	{
		not_aiming = 0,
		readying,
		charging,
		fired,
		no_arrows,
		stabbing,
		legolas_ready,
		legolas_charging
	}

	const ::s32 ready_time = 11;

	const ::s32 shoot_period = 30;
	const ::s32 shoot_period_1 = WraithArcherParams::shoot_period / 3;
	const ::s32 shoot_period_2 = 2 * WraithArcherParams::shoot_period / 3;
	const ::s32 legolas_period = WraithArcherParams::shoot_period * 3;

	const ::s32 fired_time = 7;
	const ::f32 shoot_max_vel = 17.59f;

	const ::s32 legolas_charge_time = 5;
	const ::s32 legolas_arrows_count = 1;
	const ::s32 legolas_arrows_volley = 3;
	const ::s32 legolas_arrows_deviation = 5;
	const ::s32 legolas_time = 60;
}

namespace ArrowType
{
	enum type
	{
		normal = 0,
		water,
		fire,
		bomb,
		count
	};
}

shared class WraithArcherInfo
{
	s8 charge_time;
	u8 charge_state;
	bool has_arrow;
	u8 stab_delay;
	u8 fletch_cooldown;
	u8 arrow_type;

	u8 legolas_arrows;
	u8 legolas_time;

	f32 cache_angle;

	WraithArcherInfo()
	{
		charge_time = 0;
		charge_state = 0;
		has_arrow = false;
		stab_delay = 0;
		fletch_cooldown = 0;
		arrow_type = ArrowType::normal;
	}
};

const string[] arrowTypeNames = { "mat_arrows",
                                  "mat_waterarrows",
                                  "mat_firearrows",
                                  "mat_bombarrows"
                                };

const string[] arrowNames = { "Regular arrows",
                              "Water arrows",
                              "Fire arrows",
                              "Bomb arrow"
                            };

const string[] arrowIcons = { "$Arrow$",
                              "$WaterArrow$",
                              "$FireArrow$",
                              "$BombArrow$"
                            };

void SetArrowType(CBlob@ this, const u8 type)
{
	WraithArcherInfo@ WraithArcher;
	if (!this.get("WraithArcherInfo", @WraithArcher))
	{
		return;
	}
	WraithArcher.arrow_type = type;
}

u8 getArrowType(CBlob@ this)
{
	WraithArcherInfo@ WraithArcher;
	if (!this.get("WraithArcherInfo", @WraithArcher))
	{
		return 0;
	}
	return WraithArcher.arrow_type;
}
