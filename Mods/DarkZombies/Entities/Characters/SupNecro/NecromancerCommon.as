//Necromancer Include
namespace SpellType
{
enum type
{
	summoning,
	other
};
}

shared class Spell
{
	string typeName;
	string name;
	string icon;
	u8 type;
	s32 mana;

	s32 fullChargeTime;
	s32 readyTime;
	s32 cooldownTime;


	s32 ready_time;

	s32 cast_period;
	s32 cast_period_1;
	s32 cast_period_2;
	s32 full_cast_period;

	bool needs_full;

	Spell(string i_typeName, string i_name, string i_icon, u8 i_type, s32 i_mana, s32 i_cast_period, s32 i_cooldownTime, bool fully_loaded = false)
	{
		typeName = i_typeName;
		name = i_name;
		icon = i_icon;
		type = i_type;
		mana = i_mana;
		cooldownTime = i_cooldownTime;

		cast_period = i_cast_period;
		cast_period_1 = cast_period/3;
		cast_period_2 = 2*cast_period/3;
		full_cast_period = cast_period*3;

		needs_full = fully_loaded;
	}
};

const string[] zombieTypes = {"Zombie", "Skeleton", "Wraith"};

namespace NecroParams
{
	enum Aim {
		not_aiming = 0,
		charging,
		cast_1,
		cast_2,
		cast_3,
		extra_ready,
		}

	const ::f32 shoot_max_vel = 8.0f;

	const ::Spell[] spells = {
		Spell("Skeleton", "Skeleton", "$Skeleton$", SpellType::summoning, 1, 15, 0, true),
		Spell("Zombie", "Zombie", "$Zombie$", SpellType::summoning, 4, 25, 30, true),
		Spell("Wraith", "Wraith", "$Wraith$", SpellType::summoning, 10, 40, 30, true),
		Spell("ZombieKnight", "Zombie Knight", "$ZK$", SpellType::summoning, 20, 100, 120, true),
		Spell("orb", "Orb", "$Orb$", SpellType::other, 2, 40, 120),
		Spell("zombie_rain", "Zombie Rain", "$ZombieRain$", SpellType::other, 40, 150, 240),
		Spell("teleport", "Teleportation", "$Teleport$", SpellType::other, 30, 10, 480, true),
		Spell("meteor_rain", "Meteor Rain", "$MeteorRain$", SpellType::other, 40, 180, 240),
		Spell("skeleton_rain", "Skeleton Rain", "$SkeletonRain$", SpellType::other, 20, 90, 120)
	};
}

shared class NecromancerInfo
{
	s32 charge_time;
	u8 charge_state;
	s32 mana;
	s32 maxMana;
	u8 fletch_cooldown;
	u8 primarySpellID;
	u8 secondarySpellID;

	NecromancerInfo()
	{
		charge_time = 0;
		charge_state = 0;
		maxMana = 100;
		mana = maxMana;
		fletch_cooldown = 0;
		primarySpellID = 1;
		secondarySpellID = 5;
	}
};

void SetPrimarySpell( CBlob@ this, const u8 id )
{
	NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer ))
	{
		return;
	}
	necromancer.primarySpellID = id;
}

void SetSecondarySpell( CBlob@ this, const u8 id )
{
	NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer ))
	{
		return;
	}
	necromancer.secondarySpellID = id;
}

u8 getPrimarySpellID( CBlob@ this )
{
	NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer ))
	{
		return 0;
	}
	return necromancer.primarySpellID;
}

u8 getSecondarySpellID( CBlob@ this )
{
	NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer ))
	{
		return 0;
	}
	return necromancer.secondarySpellID;
}
