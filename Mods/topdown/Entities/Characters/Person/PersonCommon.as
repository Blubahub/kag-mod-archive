//Person Include

namespace PersonParams
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
	const ::s32 shoot_period_1 = PersonParams::shoot_period / 3;
	const ::s32 shoot_period_2 = 2 * PersonParams::shoot_period / 3;
	const ::s32 legolas_period = PersonParams::shoot_period * 3;

	const ::s32 fired_time = 7;
	const ::f32 shoot_max_vel = 17.59f;

	const ::s32 legolas_charge_time = 5;
	const ::s32 legolas_arrows_count = 1;
	const ::s32 legolas_arrows_volley = 3;
	const ::s32 legolas_arrows_deviation = 5;
	const ::s32 legolas_time = 60;
}

//TODO: move vars into person params namespace
const f32 person_grapple_length = 72.0f;
const f32 person_grapple_slack = 16.0f;
const f32 person_grapple_throw_speed = 20.0f;

const f32 person_grapple_force = 2.0f;
const f32 person_grapple_accel_limit = 1.5f;
const f32 person_grapple_stiffness = 0.1f;

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

shared class PersonInfo
{
	s8 charge_time;
	u8 charge_state;
	bool has_arrow;
	u8 stab_delay;
	u8 fletch_cooldown;
	u8 arrow_type;

	u8 legolas_arrows;
	u8 legolas_time;

	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	f32 cache_angle;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	PersonInfo()
	{
		charge_time = 0;
		charge_state = 0;
		has_arrow = false;
		stab_delay = 0;
		fletch_cooldown = 0;
		arrow_type = ArrowType::normal;
		grappling = false;
	}
};

const string grapple_sync_cmd = "grapple sync";

void SyncGrapple(CBlob@ this)
{
	PersonInfo@ person;
	if (!this.get("personInfo", @person)) { return; }

	CBitStream bt;
	bt.write_bool(person.grappling);

	if (person.grappling)
	{
		bt.write_u16(person.grapple_id);
		bt.write_u8(u8(person.grapple_ratio * 250));
		bt.write_Vec2f(person.grapple_pos);
		bt.write_Vec2f(person.grapple_vel);
	}

	this.SendCommand(this.getCommandID(grapple_sync_cmd), bt);
}

//TODO: saferead
void HandleGrapple(CBlob@ this, CBitStream@ bt, bool apply)
{
	PersonInfo@ person;
	if (!this.get("personInfo", @person)) { return; }

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
		person.grappling = grappling;
		if (person.grappling)
		{
			person.grapple_id = grapple_id;
			person.grapple_ratio = grapple_ratio;
			person.grapple_pos = grapple_pos;
			person.grapple_vel = grapple_vel;
		}
	}
}

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


bool hasArrows(CBlob@ this)
{
	PersonInfo@ person;
	if (!this.get("personInfo", @person))
	{
		return false;
	}
	if (person.arrow_type >= 0 && person.arrow_type < arrowTypeNames.length)
	{
		return this.getBlobCount(arrowTypeNames[person.arrow_type]) > 0;
	}
	return false;
}

bool hasArrows(CBlob@ this, u8 arrowType)
{
	return this.getBlobCount(arrowTypeNames[arrowType]) > 0;
}

void SetArrowType(CBlob@ this, const u8 type)
{
	PersonInfo@ person;
	if (!this.get("personInfo", @person))
	{
		return;
	}
	person.arrow_type = type;
}

u8 getArrowType(CBlob@ this)
{
	PersonInfo@ person;
	if (!this.get("personInfo", @person))
	{
		return 0;
	}
	return person.arrow_type;
}
