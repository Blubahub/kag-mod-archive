/* RP_Dungeon.as
 * author: Aphelion
 */

#include "GameMessages.as";

void onRestart( CRules@ this )
{
    this.set_bool("dungeon_open", false);
	this.set_bool("dungeon_cleared", false);
}
 
void onBlobDie( CRules@ this, CBlob@ blob )
{
    string name = blob.getName();
	
	if (name == "zombie_portal")
	{
		CBlob@[] portals;
		getBlobsByName("zombie_portal", @portals);
		
		this.set_bool("dungeon_open", portals.length == 0);
	}
	else if(name == "noom")
	{
		if(getNet().isServer())
		{
			CBlob@[] doors;
			getBlobsByName("dungeon_door", @doors);
			
			for(uint i = 0; i < doors.length; i++)
			{
		    	doors[i].server_setTeamNum(255); // open
			}
		}
		sendMessage("The evil necromancer, Noom, has been defeated!");
		
		this.set_bool("dungeon_cleared", true);
	}
}

bool isDungeonOpen( CRules@ this )
{
    return this.get_bool("dungeon_open");
}

bool isBossDefeated( CRules@ this )
{
    return this.get_bool("dungeon_cleared");
}
