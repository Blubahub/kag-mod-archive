// TDM Ruins logic

#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);
	AddIconToken("$musketman_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 32);
	AddIconToken("$ninja_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 33);
	AddIconToken("$berserker_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 34);
	AddIconToken("$collector_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 37);
	//TDM classes
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
	addPlayerClass(this, "Collector", "$collector_class_icon$", "collector", "Collect items.");
	addPlayerClass(this, "Ninja", "$ninja_class_icon$", "ninja", "The Slash an Hack.");
	addPlayerClass(this, "Musketeer", "$musketman_class_icon$", "musketman", "The Pew Pew.");
	addPlayerClass(this, "Berserker", "$berserker_class_icon$", "berserker", "The Slash an Hack.");

	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("class menu");

	this.Tag("change class drop inventory");

	this.getSprite().SetZ(-50.0f);   // push to background
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("class menu"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null && caller.isMyPlayer())
		{
			BuildRespawnMenuFor(this, caller);
		}
	}
	else
	{
		onRespawnCommand(this, cmd, params);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (canChangeClass(this, caller))
	{
		Vec2f pos = this.getPosition();
		if ((pos - caller.getPosition()).Length() < this.getRadius())
		{
			BuildRespawnMenuFor(this, caller);
		}
		else
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$change_class$", Vec2f(0, 6), this, this.getCommandID("class menu"), "Change class", params);
		}
	}

	// warning: if we don't have this button just spawn menu here we run into that infinite menus game freeze bug
}
