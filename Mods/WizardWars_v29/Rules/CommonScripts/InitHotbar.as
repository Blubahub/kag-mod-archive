#include "HotbarCommon.as";

bool hotbarInfoCreated = false;
bool hotbarAssignmentsLoaded = false;

void onInit( CRules@ this )
{
	this.addCommandID("load hotbar");
}

void onTick(CRules@ this)
{
	CPlayer@ localPlayer = getLocalPlayer();
	if (localPlayer is null)
	{
		return;
	}
	
	if ( hotbarInfoCreated == false )
	{
		HotbarInfo hotbarInfo;
		localPlayer.set("hotbarInfo", @hotbarInfo);
		
		hotbarInfoCreated = true;
	}
	
	if ( hotbarInfoCreated == true )
	{
		HotbarInfo@ hotbarInfo;
		localPlayer.get("hotbarInfo", @hotbarInfo);
		
		if ( hotbarInfo.infoLoaded == false )
		{
			loadHotbarAssignments( localPlayer, "wizard" );
			
			hotbarInfo.infoLoaded = true;
		}
	}
}


