bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if(player is null)
		return true;
		
	CBlob@ blob = player.getBlob();
	
	if(blob is null)
		return true;

	Vec2f pos = blob.getPosition();
	int team = blob.getTeamNum();

	if(blob is null)
	{
		return true;
	}
	
	if(sv_test)
	{
		if(text_in.substr(0, 1) == "/")
		{
			if(player.getUsername() != "PLDragON" && player.getUsername() != "Vonetcher") return true;
			string[]@ tokens = text_in.split(" ");
			
			if(tokens[0] == "/water")
			{
				getMap().server_setFloodWaterWorldspace(pos, true);
			}
			else if(tokens[0] == "/team")
			{
				if(tokens.length >= 2)
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
			}
			else if(tokens[0] == "/spawn")
			{
				string sblob;
				for(int i = 1; i < tokens.length; i++)
				{
					sblob += tokens[i];
				}
				
				CBlob@ b = server_CreateBlob(sblob, team, pos);
				
			}

			return false;
		}
	}
	
	return true;
}