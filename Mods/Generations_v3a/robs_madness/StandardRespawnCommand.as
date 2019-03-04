// REQUIRES:
//
//      onRespawnCommand() to be called in onCommand()
//
//  implementation of:
//
//      bool canChangeClass( CBlob@ this, CBlob @caller )
//
// Tag: "change class sack inventory" - if you want players to have previous items stored in sack on class change
// Tag: "change class store inventory" - if you want players to store previous items in this respawn blob

#include "ClassSelectMenu.as";
#include "SwapClass.as";

void InitRespawnCommand(CBlob@ this)
{
	this.addCommandID("class menu");
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius() * 2.0f + caller.getRadius());
}

bool canChangeClass(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}

// default classes
void InitClasses(CBlob@ this)
{
	AddIconToken("$builder_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$knight_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$archer_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$sapper_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 6);
	AddIconToken("$ghoul_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 3);
	AddIconToken("$waterman_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 4);
	AddIconToken("$crossbow_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 5);
	AddIconToken("$necro_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 7);
	AddIconToken("$runemaster_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 8);
	AddIconToken("$paladin_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 9);
	AddIconToken("$priest_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),10);
	AddIconToken("$samurai_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),11);
	AddIconToken("$ninja_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),16);
	AddIconToken("$mindman_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),12);
	AddIconToken("$shadowman_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),13);
	AddIconToken("$runescribe_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),14);
	AddIconToken("$brainswitch_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),15);
	
	AddIconToken("$change_class$", "GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	
	
	addPlayerClass(this, "Sapper", "$sapper_class_icon$", "sapper", "Destroy the world.");
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
	addPlayerClass(this, "Crossbowman", "$crossbow_class_icon$", "crossbow", "The Ranged Advantage.");

	addPlayerClass(this, "Rune Master", "$runemaster_class_icon$", "runemaster", "Rune carver.");
	addPlayerClass(this, "Paladin", "$paladin_class_icon$", "paladin", "Holy crusher.");
	addPlayerClass(this, "Priest", "$priest_class_icon$", "priest", "Holy smiter.");
	addPlayerClass(this, "Rune Scribe", "$runescribe_class_icon$", "runescribe", "The write and spell.");
	
	addPlayerClass(this, "Boring Necromancer", "$necro_class_icon$", "necro", "The summon and splode.");
	addPlayerClass(this, "Ghoul", "$ghoul_class_icon$", "ghoul", "Devour and consume.");
	addPlayerClass(this, "Mind Writer", "$brainswitch_class_icon$", "brainswitcher", "Body Switching!");
	addPlayerClass(this, "Elementalist", "$waterman_class_icon$", "waterman", "Burning water.");
	
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		
		int Width = 4;
		int Height = 3;
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(CLASS_BUTTON_SIZE * Width, CLASS_BUTTON_SIZE * Height), "Swap class");
		if (menu !is null)
		{
			addClassesToMenu(this, menu, caller.getNetworkID());
		}
		
		/*
		if(caller.getTeamNum() == 0){
			int Width = 5;
			int Height = 1;
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(CLASS_BUTTON_SIZE * Width, CLASS_BUTTON_SIZE * Height), "Swap class");
			if (menu !is null)
			{
				addClassesToMenuGeneric(this, menu, caller.getNetworkID());
			}
		}
		
		if(caller.getTeamNum() == 1){
			int Width = 4;
			int Height = 1;
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(CLASS_BUTTON_SIZE * Width, CLASS_BUTTON_SIZE * Height), "Swap class");
			if (menu !is null)
			{
				addClassesToMenuEvil(this, menu, caller.getNetworkID());
			}
		}
		
		if(caller.getTeamNum() == 2){
			int Width = 5;
			int Height = 1;
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(CLASS_BUTTON_SIZE * Width, CLASS_BUTTON_SIZE * Height), "Swap class");
			if (menu !is null)
			{
				addClassesToMenuCaster(this, menu, caller.getNetworkID());
			}
		}
		
		if(caller.getTeamNum() == 3){
			int Width = 4;
			int Height = 1;
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(CLASS_BUTTON_SIZE * Width, CLASS_BUTTON_SIZE * Height), "Swap class");
			if (menu !is null)
			{
				addClassesToMenuNinja(this, menu, caller.getNetworkID());
			}
		}
		
		if(caller.getTeamNum() == 4){
			int Width = 3;
			int Height = 1;
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(CLASS_BUTTON_SIZE * Width, CLASS_BUTTON_SIZE * Height), "Swap class");
			if (menu !is null)
			{
				addClassesToMenuHoly(this, menu, caller.getNetworkID());
			}
		}*/
		
		
	}
}

void onRespawnCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	switch (cmd)
	{
		case SpawnCmd::buildMenu:
		{
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller);
			}
		}
		break;

		case SpawnCmd::changeClass:
		{
			if (getNet().isServer())
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());

				if (caller !is null && canChangeClass(this, caller))
				{
					string classconfig = params.read_string();
					
					swapClass(caller,classconfig);
					
				}
			}
		}
		break;
	}

	//params.SetBitIndex( index );
}

void PutInvInStorage(CBlob@ blob)
{
	CBlob@[] storages;
	if (getBlobsByTag("storage", @storages))
		for (uint step = 0; step < storages.length; ++step)
		{
			CBlob@ storage = storages[step];
			if (storage.getTeamNum() == blob.getTeamNum())
			{
				blob.MoveInventoryTo(storage);
				return;
			}
		}
}
