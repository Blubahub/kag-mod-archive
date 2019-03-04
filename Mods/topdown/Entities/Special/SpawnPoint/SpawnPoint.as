// TDM Ruins logic

#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);

	this.setPosition(this.getPosition()+Vec2f(0, -16));
	addPlayerClass(this, "Person", "$archer_class_icon$", "person", "A humanoid");
	addPlayerClass(this, "Builder", "$archer_class_icon$", "builder", "The Ranged Advantage.");
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("class menu");

	this.Tag("change class drop inventory");
	this.Tag("spawn point");

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

void onTick(CBlob@ this)
{

	this.getCurrentScript().tickFrequency = 60;
	CMap@ map = this.getMap();

	if (!this.hasTag("set") && map !is null)
	{
		s32 area = 128;
		s32 height = 72;
		//Vec2f basepos = this.get_Vec2f("basepos");
		Vec2f basepos = this.getPosition();
		//print("base position: "+basepos.x +", "+ basepos.y);

		s32 mapwidth = map.tilemapwidth * map.tilesize;
		s32 mapmiddle = (map.tilemapwidth * map.tilesize)/2;
		s32 mapheight = map.tilemapheight * map.tilesize;

		Vec2f upleft = Vec2f(0, 0);
		Vec2f upright = Vec2f(mapwidth, 0);
		Vec2f upper = Vec2f(0, basepos.y-height);

		Vec2f midleft = Vec2f(basepos.x-area, mapheight);
		Vec2f midright = Vec2f(basepos.x+area, mapheight);
/*
		map.server_AddSector(upleft, midleft, "no build");
		map.server_AddSector(upright, midright, "no build");
		map.server_AddSector(upright, upper, "no build");
		this.Tag("set");
		print("sectors set");*/

	}

	if(map is null) print("map null -_-");
}