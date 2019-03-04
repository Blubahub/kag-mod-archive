//stuff for building repspawn menus

#include "RespawnCommandCommon.as"

//class for getting everything needed for swapping to a class at a building

shared class LinkPlayerClass
{
	string name;
	string iconFilename;
	string iconName;
	string configFilename;
	string description;
};

const f32 CLASS_BUTTON_SIZE = 2;

//adding a class to a blobs list of classes

void addPlayerClass(CBlob@ this, string name, string iconName, string configFilename, string description, int typeclass )
{
	if (!this.exists("LinkPlayerClasses" + getTypeFromInt(typeclass)))
	{
		LinkPlayerClass[] classes;
		this.set("LinkPlayerClasses"+ getTypeFromInt(typeclass), classes);
	}

	LinkPlayerClass p;
	p.name = name;
	p.iconName = iconName;
	p.configFilename = configFilename;
	p.description = description;
	this.push("LinkPlayerClasses"+ getTypeFromInt(typeclass), p);
}

void addPlayerClass(CBlob@ this, string name, string iconName, string configFilename, string description)
{
	if (!this.exists("LinkPlayerClasses" + getTypeFromInt(0)))
	{
		LinkPlayerClass[] classes;
		this.set("LinkPlayerClasses"+ getTypeFromInt(0), classes);
	}

	LinkPlayerClass p;
	p.name = name;
	p.iconName = iconName;
	p.configFilename = configFilename;
	p.description = description;
	this.push("LinkPlayerClasses"+ getTypeFromInt(0), p);
}

//helper for building menus of classes
string getTypeFromInt(int men) {
	if(men == 1) return "DPS";
	else if (men == 2) return "Tank";
	else if (men == 3) return "Support";
	else if (men == 4) return "Specialist";
	
	return "";
}

void addClassesToMenu(CBlob@ this, CGridMenu@ menu, u16 callerID, int coins, int men)
{
	LinkPlayerClass[]@ classes;
	
	

	if (this.get("LinkPlayerClasses" + getTypeFromInt(men), @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			LinkPlayerClass @pclass = classes[i];

			CBitStream params;
			write_classchange(params, callerID, pclass.configFilename);

			CGridButton@ button = menu.AddButton(pclass.iconName, pclass.name, LinkSpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
      
      button.SetHoverText( pclass.description + "\n" );
		}
	}
}

LinkPlayerClass@ getDefaultClass(CBlob@ this)
{
	LinkPlayerClass[]@ classes;

	if (this.get("LinkPlayerClasses", @classes))
	{
		return classes[0];
	}
	else
	{
		return null;
	}
}
