//Wizard Include
#include "WizardCommon.as";
#include "MagicCommon.as";

const u8 WIZARD_TOTAL_HOTKEYS = 17;

shared class HotbarInfo
{
	bool infoLoaded;

	u8 primarySpellID;
	u8 primaryHotkeyID;
	u8 secondarySpellID;
	u8 aux1SpellID;
	u8 customSpellID;
	u8[] hotbarAssignments_Wizard;

	HotbarInfo()
	{
		infoLoaded = false;
	
		primarySpellID = 0;
		primaryHotkeyID = 0;
		secondarySpellID = 1;	
		aux1SpellID = 2;
	}
};

void SetPrimarySpell( CPlayer@ this, const u8 id )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return;
	}
	hotbarInfo.primarySpellID = id;
}

void SetSecondarySpell( CPlayer@ this, const u8 id )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return;
	}
	hotbarInfo.secondarySpellID = id;
}

void SetCustomSpell( CPlayer@ this, const u8 id )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return;
	}
	hotbarInfo.customSpellID = id;
}

u8 getPrimarySpellID( CPlayer@ this )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return 0;
	}
	return hotbarInfo.primarySpellID;
}

u8 getSecondarySpellID( CPlayer@ this )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return 0;
	}
	return hotbarInfo.secondarySpellID;
}

void assignHotkey( CPlayer@ this, const u8 hotkeyID, const u8 spellID, string playerClass )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return;
	}
	
	if ( playerClass == "wizard" )
	{
		hotbarInfo.hotbarAssignments_Wizard[hotkeyID] = spellID;
		hotbarInfo.primarySpellID = hotbarInfo.hotbarAssignments_Wizard[hotbarInfo.primaryHotkeyID];
		hotbarInfo.secondarySpellID = hotbarInfo.hotbarAssignments_Wizard[15];
		hotbarInfo.aux1SpellID = hotbarInfo.hotbarAssignments_Wizard[16];
	}
	
	saveHotbarAssignments( this, playerClass );
}

void defaultHotbarAssignments( CPlayer@ this, string playerClass )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return;
	}
	
	if ( playerClass == "wizard" )
	{
		hotbarInfo.hotbarAssignments_Wizard.clear();
		
		int spellsLength = WizardParams::spells.length;
		for (uint i = 0; i < WIZARD_TOTAL_HOTKEYS; i++)
		{
			if ( i < 15 )
				hotbarInfo.hotbarAssignments_Wizard.push_back(i);
			else if ( i == 15 )
				hotbarInfo.hotbarAssignments_Wizard.push_back(1);	//assign secondary to teleport
			else if ( i == 16 )
				hotbarInfo.hotbarAssignments_Wizard.push_back(2);	//assign aux1 to counter spell
		}	
	}
}

void saveHotbarAssignments( CPlayer@ this, string playerClass )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return;
	}
	
	if (getNet().isClient())
	{
		ConfigFile cfg;
		
		if ( playerClass == "wizard" )
		{
			for (uint i = 0; i < hotbarInfo.hotbarAssignments_Wizard.length; i++)
			{		
				cfg.add_u32("wizard hotkey" + i, hotbarInfo.hotbarAssignments_Wizard[i]);
			}
		}
		
		cfg.saveFile( "WizardWars_hotkeys.cfg" );
	}	
}

void loadHotbarAssignments( CPlayer@ this, string playerClass )
{
	HotbarInfo@ hotbarInfo;
	if (!this.get( "hotbarInfo", @hotbarInfo ))
	{
		return;
	}
	
	if ( playerClass == "wizard" )
	{
		hotbarInfo.hotbarAssignments_Wizard.clear();
		
		int spellsLength = WizardParams::spells.length;
		for (uint i = 0; i < WIZARD_TOTAL_HOTKEYS; i++)
		{
			if ( i < 15 )
				hotbarInfo.hotbarAssignments_Wizard.push_back(i);
			else if ( i == 15 )
				hotbarInfo.hotbarAssignments_Wizard.push_back(1);	//assign secondary to teleport
			else if ( i == 16 )
				hotbarInfo.hotbarAssignments_Wizard.push_back(2);	//assign aux1 to counter spell
		}
		
		if (getNet().isClient()) 
		{	
			u8[] loadedHotkeys;
			ConfigFile cfg;
			if ( cfg.loadFile("../Cache/WizardWars_hotkeys.cfg") )
			{
				for (uint i = 0; i < hotbarInfo.hotbarAssignments_Wizard.length; i++)
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
				hotbarInfo.hotbarAssignments_Wizard = loadedHotkeys;
				print("Hotkey config file loaded.");
			}
		}
		
		hotbarInfo.primarySpellID = hotbarInfo.hotbarAssignments_Wizard[0];
		hotbarInfo.secondarySpellID = hotbarInfo.hotbarAssignments_Wizard[15];
		hotbarInfo.aux1SpellID = hotbarInfo.hotbarAssignments_Wizard[16];
	}
}

