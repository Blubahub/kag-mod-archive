namespace Soldier
{
	shared enum Type
	{
		ASSAULT = 0,
		SNIPER,
		MEDIC,
		ENGINEER,
		COMMANDO,
		CIVILIAN,
		CLASS_COUNT
	};
}

const string[] CLASS_NAMES = { "Assault", "Sniper", "Medic", "Demolitions", "Commando", "Civilian" };
const int CLASS_COUNT = CLASS_NAMES.length;

const string[] CLASS_PRIMARIES = { "Fire", "Aim/Fire", "Shield", "Missile", "Knife", "N/A" };
const string[] CLASS_SECONDARIES = { "Grenade", "Disguise", "Supply / Trap", "Crate", "Flashbang", "N/A" };

int getClassIndexByName(const string &in name)
{
	for (uint i = 0; i < CLASS_COUNT; i++)
		if (name == CLASS_NAMES[i]){
			return i;
		}
	warn("class not found " + name);
	return 0;
}

int getClassIndexByName(CRules@ this, const string &in name)
{
	int[]@ classes = getClasses(this);
	for (uint i = 0; i < classes.length; i++)
	{
		if (CLASS_NAMES[classes[i]] == name)
		{
			return i;
		}
	}
	warn("class not found " + name);
	return 0;
}

int[] getClasses(CRules@ this)
{
	if (!this.exists("classes"))
	{
		ClearClasses(this);
	}
	int[]@ p_classes;
	this.get("classes", @p_classes);
	return p_classes;
}

void ClearClasses(CRules@ this)
{
	int[] classes;
	this.set("classes", classes);
}

void AddClass(CRules@ this, const int classNum)
{
	this.push("classes", classNum);
}

//

Random _namesrandom(0x7ea000);
const string[] ENGLISH_NAMES = { "Quack", "William", "Edward", "Roland", "Ted", "Yeti", "Urk", "Ivan", "Othello", "Frida"
                                 , "Adam", "Sebastian", "Donald", "Frederick", "Gustav", "Henry", "Jacob", "Kate", "Lucy"
                                 , "Zelda", "Peter", "Cinderella", "Vanessa", "Betty", "Noob", "Maximilian"
                               };