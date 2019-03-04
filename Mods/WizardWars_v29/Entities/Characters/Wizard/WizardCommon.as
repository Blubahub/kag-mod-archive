//Wizard Include

#include "MagicCommon.as";

const f32 MAX_ATTACK_DIST = 360.0f;
const s32 MAX_MANA = 100;
const s32 MANA_REGEN = 3;

const string[] zombieTypes = {"zombie", "skeleton", "greg", "wraith"};

namespace WizardParams
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

	const ::Spell[] spells = 
	{
		Spell("orb", "Orb", 5, "Fire a basic orb which ricochets off of most surfaces until impacting an enemy and exploding, dealing minor damage.",
			SpellType::other, 2, 40, 120, 360.0f),
			
		Spell("teleport", "Teleport to Target", 7, "Point to any visible position and teleport there.",
			SpellType::other, 20, 10, 480, 270.0f, true),
			
		Spell("counter_spell", "Counter Spell", 15, "Destroy all spells around you. Also able to severely damage summoned creatures.",
			SpellType::other, 15, 15, 120, 8.0f, true),
			
		Spell("magic_missile", "Missiles of Magic", 16, "Barrage your nearest foes with deadly homing missiles. Does minor damage, is slow moving and easily countered.",
			SpellType::other, 25, 40, 120, 360.0f, true),
			
		Spell("frost_ball", "Ball of Frost", 12, "Send forth a slow travelling ball of pure cold essence to freeze your enemies in place and deal a small amount of damage. Freeze duration increases as the health of your enemy declines.",
			SpellType::other, 15, 20, 120, 360.0f, true),
			
		Spell("heal", "Lesser Heal", 13, "Salves the least of your allies' wounds to restore a moderate portion of their health. Fully charge in order to heal yourself with less efficiency.",
			SpellType::other, 15, 20, 120, 360.0f, true), 
			 
		Spell("firebomb", "Fire Bomb", 10, "Throw a high velocity condensed ball of flames that explodes on contact with enemies, igniting them. Has a minimum engagement distance of about 10 blocks.",
			SpellType::other, 25, 50, 120, 360.0f, true),
			 
		Spell("fire_sprite", "Fire Sprites", 11, "Create long-ranged explosive balls of energy which follow your aim for an extended period of time.",
			SpellType::other, 15, 20, 120, 360.0f, true),	
			 
		Spell("meteor_strike", "Meteor Strike", 8, "Bring flaming meteors crashing down wherever you desire.",
			SpellType::other, 40, 60, 120, 360.0f, true),
			 
		Spell("revive", "Revive", 14, "Bring trusty allies back from the dead by aiming a reviving missile at their gravestone.",
			SpellType::other, 50, 80, 120, 360.0f, true),
			 
		Spell("slow", "Slow", 18, "Deprive a player of his speed and ability to teleport for a few moments.",
			SpellType::other, 15, 20, 120, 360.0f, true), 
			 
		Spell("zombie", "Summon Zombie", 1, "Summon an undead minion to fight by your side. Summons at the aim location.",
			SpellType::summoning, 20, 25, 30, 64.0f, true),
			 
		Spell("magic_barrier", "Magic Barrier", 20, "Create a wall of pure magical energy in front of you that blocks most small projectiles.",
			SpellType::other, 25, 20, 120, 32.0f, true),
			 
		Spell("black_hole", "Black Hole", 17, "Open a portal into outer space, pulling your enemies into the airless void. Also drains the mana of enemies in the area and gives it to the caster.",
			SpellType::other, 45, 40, 30, 180.0f, true),
			 
		//Spell("greg", "Greg", 3, "Testing",
			//SpellType::summoning, 50, 50, 30, true),
			 
		Spell("haste", "Haste", 19, "Give your allies some added speed and maneuverability. Fully charge to hasten yourself.",
			SpellType::other, 10, 20, 120, 360.0f, true),
			 
		Spell("zombieknight", "Summon ZKnight", 4, "TEST SPELL",
			SpellType::summoning, 60, 60, 120, 64.0f, true),
			
		Spell("skeleton_rain", "Skeleton Rain", 9, "TEST SPELL",
			SpellType::other, 45, 60, 120, 64.0f, true),
			
		Spell("arrow_rain", "Arrow Rain", 21, "Cause a long volley of randomly assorted arrows to fall upon thy foe. Great for area denial, and possibly overpowered!",
			SpellType::other, 80, 30, 120, 360.0f, true)
	};
}

shared class WizardInfo
{
	s32 charge_time;
	u8 charge_state;
	u8 fletch_cooldown;

	WizardInfo()
	{
		charge_time = 0;
		charge_state = 0;
		fletch_cooldown = 0;
	}
}; 

