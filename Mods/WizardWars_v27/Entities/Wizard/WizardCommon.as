//Wizard Include
const u8 WIZARD_TOTAL_HOTKEYS = 17;

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
	u16 iconFrame;
	string spellDesc;
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

	Spell(string i_typeName, string i_name, u16 i_iconFrame, string i_spellDesc, u8 i_type, s32 i_mana, s32 i_cast_period, s32 i_cooldownTime, bool fully_loaded = false)
	{
		typeName = i_typeName;
		name = i_name;
		iconFrame = i_iconFrame;
		spellDesc = i_spellDesc;
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
			SpellType::other, 2, 40, 120),
			
		Spell("teleport", "Teleport to Target", 7, "Point to any visible position and teleport there.",
			SpellType::other, 20, 10, 480, true),
			
		Spell("counter_spell", "Counter Spell", 15, "Destroy all spells around you. Severely damages summoned creatures.",
			SpellType::other, 20, 15, 120, true),
			
		Spell("magic_missile", "Missiles of Magic", 16, "Barrage your nearest foes with deadly homing missiles. Does minor damage, is slow moving and easily countered.",
			SpellType::other, 20, 50, 120, true),
			
		Spell("frost_ball", "Ball of Frost", 12, "Send forth a slow travelling ball of pure cold essence to freeze your enemies in place and deal a small amount of damage. Freeze duration increases as the health of your enemy declines.",
			SpellType::other, 15, 60, 120, true),
			
		Spell("heal", "Lesser Heal", 13, "Salves the least of your allies' wounds to restore a moderate portion of their health. Fully charge in order to heal yourself with less efficiency.",
			SpellType::other, 15, 20, 120, true), 
			 
		Spell("firebomb", "Fire Bomb", 10, "Throw a high velocity condensed ball of flames that explodes on contact with enemies, igniting them. Has a minimum engagement distance of about 10 blocks.",
			SpellType::other, 25, 70, 120, true),
			 
		Spell("fire_sprite", "Fire Sprites", 11, "Create long-ranged explosive balls of energy which follow your aim for an extended period of time.",
			SpellType::other, 15, 40, 120, true),	
			 
		Spell("meteor_strike", "Meteor Strike", 8, "Bring flaming meteors crashing down wherever you desire.",
			SpellType::other, 40, 75, 120, true),
			 
		Spell("revive", "Revive", 14, "Bring trusty allies back from the dead by aiming a reviving missile at their gravestone.",
			SpellType::other, 50, 80, 120, true),
			 
		Spell("slow", "Slow", 18, "Deprive a player of his speed and ability to teleport for a few moments.",
			SpellType::other, 15, 20, 120, true), 
			 
		Spell("zombie", "Summon Zombie", 1, "Summon an undead minion to fight by your side. Summons at the aim location.",
			SpellType::summoning, 20, 25, 30, true),
			 
		Spell("magic_barrier", "Magic Barrier", 20, "Create a wall of pure magical energy in front of you that blocks most small projectiles.",
			SpellType::other, 30, 20, 120, true),
			 
		Spell("black_hole", "Black Hole", 17, "Open a portal into outer space, pulling your enemies into the airless void. Also drains the mana of enemies in the area and gives it to the caster.",
			SpellType::other, 50, 40, 30, true),
			 
		//Spell("greg", "Greg", 3, "Testing",
			//SpellType::summoning, 50, 50, 30, true),
			 
		Spell("haste", "Haste", 19, "Give your allies some added speed and maneuverability. Fully charge to hasten yourself.",
			SpellType::other, 10, 20, 120, true),
			 
		Spell("zombieknight", "Summon ZKnight", 4, "TEST SPELL",
			SpellType::summoning, 60, 100, 120, true),
			
		Spell("skeleton_rain", "Skeleton Rain", 9, "TEST SPELL",
			SpellType::other, 45, 90, 120),
			
		Spell("arrow_rain", "Arrow Rain", 21, "Cause a long volley of randomly assorted arrows to fall upon thy foe. Great for area denial, and possibly overpowered!",
			SpellType::other, 80, 40, 120, true)
	};
}

shared class WizardInfo
{
	s32 charge_time;
	u8 charge_state;
	s32 mana;
	s32 maxMana;
	u8 fletch_cooldown;
	u8 primarySpellID;
	u8 primaryHotkeyID;
	u8 secondarySpellID;
	u8 aux1SpellID;
	u8 customSpellID;
	u8[] hotbarAssignments;

	WizardInfo()
	{
		charge_time = 0;
		charge_state = 0;
		maxMana = 100;
		mana = 0;
		fletch_cooldown = 0;
		primarySpellID = 0;
		primaryHotkeyID = 0;
		secondarySpellID = 1;	
		aux1SpellID = 2;
	}
}; 

void SetPrimarySpell( CBlob@ this, const u8 id )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return;
	}
	wizard.primarySpellID = id;
}

void SetSecondarySpell( CBlob@ this, const u8 id )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return;
	}
	wizard.secondarySpellID = id;
}

void SetCustomSpell( CBlob@ this, const u8 id )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return;
	}
	wizard.customSpellID = id;
}

u8 getPrimarySpellID( CBlob@ this )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return 0;
	}
	return wizard.primarySpellID;
}

u8 getSecondarySpellID( CBlob@ this )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return 0;
	}
	return wizard.secondarySpellID;
}

void assignHotkey( CBlob@ this, const u8 hotkeyID, const u8 spellID )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return;
	}
	
	wizard.hotbarAssignments[hotkeyID] = spellID;
	wizard.primarySpellID = wizard.hotbarAssignments[wizard.primaryHotkeyID];
	wizard.secondarySpellID = wizard.hotbarAssignments[15];
	wizard.aux1SpellID = wizard.hotbarAssignments[16];
	
	saveHotbarAssignments( this );
}

void defaultHotbarAssignments( CBlob@ this )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return;
	}
	
	wizard.hotbarAssignments.clear();
	
	int spellsLength = WizardParams::spells.length;
	for (uint i = 0; i < WIZARD_TOTAL_HOTKEYS; i++)
	{
		if ( i < 15 )
			wizard.hotbarAssignments.push_back(i);
		else if ( i == 15 )
			wizard.hotbarAssignments.push_back(1);	//assign secondary to teleport
		else if ( i == 16 )
			wizard.hotbarAssignments.push_back(2);	//assign aux1 to counter spell
	}	
}

void saveHotbarAssignments( CBlob@ this )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return;
	}
	
	if (getNet().isClient())
	{
		ConfigFile cfg;
		for (uint i = 0; i < wizard.hotbarAssignments.length; i++)
		{		
			cfg.add_u32("wizard hotkey" + i, wizard.hotbarAssignments[i]);
		}
		cfg.saveFile( "WizardWars_hotkeys.cfg" );
	}	
}

void loadHotbarAssignments( CBlob@ this )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard ))
	{
		return;
	}
	
	wizard.hotbarAssignments.clear();
	
	int spellsLength = WizardParams::spells.length;
	for (uint i = 0; i < WIZARD_TOTAL_HOTKEYS; i++)
	{
		if ( i < 15 )
			wizard.hotbarAssignments.push_back(i);
		else if ( i == 15 )
			wizard.hotbarAssignments.push_back(1);	//assign secondary to teleport
		else if ( i == 16 )
			wizard.hotbarAssignments.push_back(2);	//assign aux1 to counter spell
	}
	
	if (getNet().isClient()) 
	{	
		u8[] loadedHotkeys;
		ConfigFile cfg;
		if ( cfg.loadFile("../Cache/WizardWars_hotkeys.cfg") )
		{
			for (uint i = 0; i < wizard.hotbarAssignments.length; i++)
			{		
				if ( cfg.exists( "wizard hotkey"+i ) )
				{
					if ( i < spellsLength )
						loadedHotkeys.push_back(cfg.read_u32("wizard hotkey" + i));
					else
						loadedHotkeys.push_back(0);
				}
				else
					loadedHotkeys.push_back(0);
			}
			wizard.hotbarAssignments = loadedHotkeys;
			print("Hotkey config file loaded.");
		}
	}
	
	wizard.primarySpellID = wizard.hotbarAssignments[0];
	wizard.secondarySpellID = wizard.hotbarAssignments[15];
	wizard.aux1SpellID = wizard.hotbarAssignments[16];
}