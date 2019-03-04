/*
MOD name: Ranks
Author: SnIcKeRs
*/

#define SERVER_ONLY

#include "rules_Commands.as"
#include "commonStats.as"
#include "events.as"

string TOP10 = "";
bool TOPshown = false;

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null) return true;
	CPlayer@ rankPlayer;

	string[] args = text_in.split(" ");

	if(args[0] != "/rank"){ return true; }

	if(args.length == 2)
	{
		if(args[1] == "-save")//&& player.isMod() doesnt work now
		{
			saveAllStats();
			return false;//dont show in chat
		}
		else if(args[1] == "-top")
		{
			if(!TOPshown)
			{
				//string top TOP10= getTop("../Cache/Stats/players.cfg");
				//TOP10 = "----------Top10----------\n"+top;
				TOP10= getTop("../Cache/Stats/players.cfg");
				TOPshown = true;
			}

			CBitStream bitstream;
			bitstream.write_string(TOP10);
			getRules().SendCommand(this.getCommandID("top"), bitstream);
			//return true;
		}
		else if(args[1] == "-reset")
		{
			Stats@ stats = getStats(player);
			stats.kills = 0;
			stats.deaths = 0;

		}
		else if(args[1] != " ")
		{
			@rankPlayer = getPlayerByUsername(args[1]);
			if (rankPlayer is null)
			{
				Stats@ stats = readStatsByName(args[1]);

				CBitStream bitstream;
				bitstream.write_u16(player.getNetworkID());
				bitstream.write_string(args[1]);

				if(stats !is null)
				{//sending offline player stats
					bitstream.write_u32(stats.kills);
					bitstream.write_u32(stats.deaths);
					getRules().SendCommand(this.getCommandID("offlinestats"), bitstream);
				}
				else
				{
					getRules().SendCommand(this.getCommandID("noplayer"), bitstream);
				}
				//return true;
			}
		}
	}
	else
	{
		@rankPlayer = player;
		u32 deaths = 0, kills = 0;

		Stats@ stats = getStats(rankPlayer);

		kills = stats.kills;
		deaths = stats.deaths;

		CBitStream bitstream;
		bitstream.write_u16(player.getNetworkID());//used command
		bitstream.write_u16(rankPlayer.getNetworkID());//player's ranks
		bitstream.write_u32(kills);
		bitstream.write_u32(deaths);

		getRules().SendCommand(this.getCommandID("stats"), bitstream);
	}
	return true;
}



