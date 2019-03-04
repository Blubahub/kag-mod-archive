//Contains every script & it's magical code. .as is added on after because they'll all have that.
//Only one movement script per spell.
//No longer any need for caps locks in some of the stuff.
const string[][] movement = {
{"Fellar", //Chat name
"StraightLine" //Script name
},
{"Hest", "Gravity"},
{"Ondriss", "Orbit"},
{"Siltar", "SinGravity"},
{"Resvellar", "ReverseGravity"},
{"Aldotar", "Stationary"}
};

//Only one collision script per spell.
const string[][] collision = {
{"Bosun", "Bounce"},
{"Tessel", "TilePhase"},
{"Retus", "ReturnBounce"}
};

//Only one enemy collision script per spell.
const string[][] enemycollision = {
{"Huar", "Harm"},
{"Pef", "Pierce"},
//{"Aeldestas", "ArrowRain"},
{"Expondu", "Explode"},
{"Konkus", "Knock"}
};

//As many misc scripts as is gud.
const string[][] misc = {
{"Ergon", "Necromance"},
{"Endelfalar", "Nothing"},
{"Lonbus", "Lob"},
{"Ainirlan", "MagicMissile"}
};

const string[][] attackstyle = {
{"Plie", "Horon", FireStyle::Plain},
{"Ranpi", "Porfuse", FireStyle::Rapid},
{"Pio", "Gestaf", "Festil", "Poldufelgastrastanglest", FireStyle::SkySummon},
{"Tirs", "Estargar", "Feldestar", FireStyle::SpreadShot},
{"Erfugon", "Moltegon", "Polmanticon",FireStyle::Eruption}
};


const string[][][] allwords = {
movement,
collision,
enemycollision,
misc,
attackstyle
};



namespace FireStyle
{
	enum Aim
	{
		Plain = 0,
		Rapid,
		SkySummon,
		SpreadShot,
		Eruption
	}
}
const string[] Abilities = {
"Entil", //Leap
"Rendestus", //Regenerate
"Flagen" //Glide
};
const int[] minAbilityCharges = {
120, //Leap
80, //Regenerate
100 //Glide
};
namespace Ability
{
	enum type
	{
		Leap = 0,
		Regenerate,
		Glide
	}
}

int getSpellIndex(string word, int& out endex, int& out power)
{
	string[] incantation = word.split(","); //What to seperate powers from.
	power = 0;
	if(incantation.length < 0)
	{
		return -1;
	}
	string mainword = incantation[0];

	for(int i = 0; i < allwords.length; i++)
	{
		string[][] list = allwords[i];
		for(int step = 0; step < list.length; step++)
		{
			string[] listpart = list[step];
			if(listpart[0].toLower() == mainword.toLower())
			{
				for(int i = 1; i < listpart.length - 1 && i < incantation.length; i++) //Checking for stylepower upgrades.
				{
					string ensorcellor = incantation[i].toLower();
					if(ensorcellor == listpart[i].toLower())
					{
						power++;
					}
					
				}
				endex = step; //Set the spell to it's script-name
				return i; //Returns the index of the spell.
			}
		}
	}
	return -1; //-1 = nothing.
}

int getChargeMax(u8 firestyle, u8 stylepower)
{
	int[] stylelist = maxChargeLevels[firestyle];
	int maxnum = stylelist[Maths::Min(stylepower, stylelist.length - 1)]; //So it doesn't go out of bounds.
	return maxnum;
}
//Experimental
int getThreshold(u8 firestyle, u8 stylepower)
{
	return getChargeMax(firestyle, stylepower) * 0.75f; //Always return a quarter of max charge.
}
bool canCast(CBlob@ this)
{
	int charge = this.get_u16("charge");
	u8 firestyle = this.get_u8("firestyle");
	u8 stylepower = this.get_u8("stylepower");		
	if(charge > getThreshold(firestyle, stylepower))
	{
		return true;
	}
	return false;
}
//end 'sperimentl
const int[][] maxChargeLevels = {
	{80, 260},	//Plain
	{17, 7},		//Rapid
	{120, 180, 280, 550},		//SkySummon
	{70, 130, 400},		//SpreadShot
	{140, 200, 300}		//Eruption
};

void MagicHitBlob(CBlob@ this, CBlob@ blob, Vec2f position, Vec2f vel, f32 damage, u8 hitter, bool shouldTeamKill = false)
{
	this.server_Hit(blob, position, vel, damage, hitter, shouldTeamKill);
}