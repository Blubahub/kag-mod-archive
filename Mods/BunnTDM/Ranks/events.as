/*
MOD name: Ranks
Author: SnIcKeRs
*/

#include "commonStats.as"

const uint SAVE_PERIOD = 10 * 60 * getTicksASecond();//10 minutes
uint oldTime = getGameTime();

//save all stats every SAVE_PERIOD minutes
void onTick(CRules@ this)
{
	if(getGameTime() - oldTime > SAVE_PERIOD)
	{
		oldTime = getGameTime();
		saveAllStats();
	}
}

void onBlobDie( CRules@ this, CBlob@ blob )
{
	if (blob !is null)
	{
		CPlayer@ killer = blob.getPlayerOfRecentDamage();
		CPlayer@ victim = blob.getPlayer();

		if (victim !is null)
		{
			Stats@ vicStats = getStats(victim);
			if(vicStats !is null)
			{
				vicStats.deaths += 1;
			}
			
			if (killer !is null) //requires victim so that killing trees matters
			{
				if (killer.getTeamNum() != blob.getTeamNum())
				{
					Stats@ kilStats = getStats(killer);
					if(kilStats !is null)
					{
						kilStats.kills+= 1;
					}
				}
			}
			
		}
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	if(player is null) return;
	Stats@ stats = readStats(player);//read stats from file
	allStats.insertLast(stats);
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	if(player is null) return;

	for(uint i = 0; i<allStats.length(); i++)
	{
		if(allStats[i].player is player)
		{
			saveStats(allStats[i]);
			print("Kills: "+ allStats[i].kills);
			print("Deaths: "+ allStats[i].deaths);
			allStats.removeAt(i);
			print("Stats array length: " + allStats.length());
			return;
		}
	}
}
