// get spawn points for CTF

#include "HallCommon.as"

shared void PopulateSpawnList(CBlob@[]@ respawns, const int teamNum)
{
	
	CBlob@[] halls;
	getBlobsByTag("respawn", @halls);
	getBlobsByTag("bed", @halls);

	for (uint i = 0; i < halls.length; i++)
	{
		CBlob@ blob = halls[i];

		if (blob.getTeamNum() == teamNum
		        && !isHallDepleted(blob)
		        && (!isUnderRaid(blob))
		   )
		{
			respawns.push_back(blob);
		}
	}
}
