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
			
			if(tokens[0] == "/tp")
			{
				player.getBlob().setVelocity(Vec2f(10, 10));
			}
			else if(tokens[0] == "/spawn")
			{
				string blob;
				for(int i = 1; i < tokens.length; i++)
				{
					blob += tokens[i];
				}
				
				CBlob@ b = server_CreateBlob(blob, -1, pos);
			}

			return false;
		}
	}
	
	return true;
}