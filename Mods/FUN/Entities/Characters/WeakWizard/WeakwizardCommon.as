const int TELEPORT_FREQUENCY = 20 * 30; //20 secs
const int TELEPORT_DISTANCE = 10 * 8 ;//getMap().tilesize;

const int FIRE_FREQUENCY = 15;
const f32 ORB_SPEED = 3.0f;
const u8 ORB_LIMIT = 2;
const u32 ORB_BURST_COOLDOWN = 20 * 30; //20 secs
const float ORB_TIME_TO_DIE = 7.0f;


namespace OrbType
{
enum type
{
    normal = 0,
	water,
	count
};
}

shared class WizardInfo
{
	bool has_orb;
	u8 orb_type;

	WizardInfo()
	{
		has_orb = false;
		orb_type = OrbType::normal;
	}
};

const string[] orbTypeNames = { "mat_orbs",
								"mat_waterorbs"
                                };
const string[] orbNames = { "Regular Orb",
							"Water Orb"
                            };

const string[] orbIcons = { "$Orb$",
							"$WaterOrb$"
};

u8 getOrbType( CBlob@ this )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard )) {
		return 0;

	}						 
	return wizard.orb_type;
}
void SetOrbType( CBlob@ this, const u8 type )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard )) {
		return;

	}		  	
	wizard.orb_type = type;
}

bool hasOrbs( CBlob@ this )
{
	WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard )) {
		return false;

	}
	if (wizard.orb_type >= 0 && wizard.orb_type < orbTypeNames.length) {
		return this.getBlobCount( orbTypeNames[wizard.orb_type] ) > 0;
	}

	return false;
}