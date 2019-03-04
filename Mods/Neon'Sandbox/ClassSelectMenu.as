//stuff for building repspawn menus

#include "RespawnCommandCommon.as"

//class for getting everything needed for swapping to a class at a building

shared class PlayerClass
{
	string name;
	string iconFilename;
	string iconName;
	string configFilename;
	string description;
};

const f32 CLASS_BUTTON_SIZE = 2;

//adding a class to a blobs list of classes

void addPlayerClass(CBlob@ this, string name, string iconName, string configFilename, string description)
{
	if (!this.exists("playerclasses"))
	{
		PlayerClass[] classes;
		this.set("playerclasses", classes);
	}

	PlayerClass p;
	p.name = name;
	p.iconName = iconName;
	p.configFilename = configFilename;
	p.description = description;
	this.push("playerclasses", p);
}

//helper for building menus of classes

void addClassesToMenu(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];

			CBitStream params;
			write_classchange(params, callerID, pclass.configFilename);

			CGridButton@ button = menu.AddButton(pclass.iconName, pclass.name, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
			//button.SetHoverText( pclass.description + "\n" );
		}
	}
}

void addClassesToMenuBuilder(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];

			if(pclass.configFilename != "builder" && pclass.configFilename != "runemaster" && pclass.configFilename != "sapper")continue;
			
			CBitStream params;
			write_classchange(params, callerID, pclass.configFilename);

			CGridButton@ button = menu.AddButton(pclass.iconName, pclass.name, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
			//button.SetHoverText( pclass.description + "\n" );
		}
	}
}

void addClassesToMenuHoly(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];

			if(pclass.configFilename != "priest" && pclass.configFilename != "paladin")continue;
			
			CBitStream params;
			write_classchange(params, callerID, pclass.configFilename);

			CGridButton@ button = menu.AddButton(pclass.iconName, pclass.name, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
			//button.SetHoverText( pclass.description + "\n" );
		}
	}
}

void addClassesToMenuMelee(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];

			if(pclass.configFilename != "knight" && pclass.configFilename != "samurai" && pclass.configFilename != "ninja")continue;
			
			CBitStream params;
			write_classchange(params, callerID, pclass.configFilename);

			CGridButton@ button = menu.AddButton(pclass.iconName, pclass.name, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
			//button.SetHoverText( pclass.description + "\n" );
		}
	}
}

void addClassesToMenuCaster(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];

			if(pclass.configFilename != "runescribe" && pclass.configFilename != "mindman" && pclass.configFilename != "brainswitcher" && pclass.configFilename != "waterman")continue;
			
			CBitStream params;
			write_classchange(params, callerID, pclass.configFilename);

			CGridButton@ button = menu.AddButton(pclass.iconName, pclass.name, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
			//button.SetHoverText( pclass.description + "\n" );
		}
	}
}

void addClassesToMenuRange(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];

			if(pclass.configFilename != "archer" && pclass.configFilename != "crossbow")continue;
			
			CBitStream params;
			write_classchange(params, callerID, pclass.configFilename);

			CGridButton@ button = menu.AddButton(pclass.iconName, pclass.name, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
			//button.SetHoverText( pclass.description + "\n" );
		}
	}
}

void addClassesToMenuEvil(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		for (uint i = 0 ; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];

			if(pclass.configFilename != "necro" && pclass.configFilename != "shadowman" && pclass.configFilename != "ghoul")continue;
			
			CBitStream params;
			write_classchange(params, callerID, pclass.configFilename);

			CGridButton@ button = menu.AddButton(pclass.iconName, pclass.name, SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
			//button.SetHoverText( pclass.description + "\n" );
		}
	}
}

PlayerClass@ getDefaultClass(CBlob@ this)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		return classes[0];
	}
	else
	{
		return null;
	}
}
