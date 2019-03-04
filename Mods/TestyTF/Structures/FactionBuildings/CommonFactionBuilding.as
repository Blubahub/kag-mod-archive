#include "Survival_Structs.as";

const string raid_tag = "under raid";

void onInit(CBlob@ this)
{
	this.Tag("faction_base");
	
	this.addCommandID("faction_captured");
	this.addCommandID("faction_destroyed");
	this.addCommandID("button_join");
}

void onTick(CBlob@ this)
{
	SetMinimap(this);   //needed for under raid check
}

void SetMinimap(CBlob@ this)
{
	if (this.hasTag(raid_tag))
	{
		this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16, 16));
	}
	else
	{
		this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
		
		if (this.hasTag("minimap_large")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(16, 8));
		else if (this.hasTag("minimap_small")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(8, 8));
	}

	this.SetMinimapRenderAlways(true);
}
/*void onAddToInventory(CBlob@ this,CBlob@ blob)
{
	if(blob.getName()=="mat_oil"){
		int quantity=	getRules().get_u32("team"+this.getTeamNum()+"_oilAmount");
		getRules().set_u32("team"+this.getTeamNum()+"_oilAmount",quantity+blob.getQuantity());
		blob.server_Die();
	}
}*/

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (blob !is null && !solid)
	// {
		// CPlayer@ p = blob.getPlayer();
		// if(p is null)return;
		
		// if (!blob.hasTag("player") ||  blob.hasTag("ignore_flags")) return;	//early out for non-player collision
		
		// int team = this.getTeamNum();

		// // print("Expire: " + p.get_u32("teamkick_time") + "; Time: " + getGameTime());
		
		// if (this.getTeamNum() > 7)
		// {
			// return;
		// }
		// else if ((p.exists("teamkick_time") ? p.get_u32("teamkick_time") < getGameTime() : true) && blob.getTeamNum() > 7 && p.getTeamNum() > 7)
		// {	
			// this.getSprite().PlaySound("party_join.ogg");
		
			// if (getNet().isServer())
			// {	
				// p.server_setTeamNum(team);
				// CBlob@ newPlayer = server_CreateBlob("builder", team, blob.getPosition());
				// newPlayer.server_SetPlayer(p);
				
				// blob.server_Die();
			// }
			// return;
		// }
	// }
// }

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	CBlob@[] forts;
	getBlobsByTag("faction_base", @forts);

	int newTeam = this.getTeamNum();
	int totalFortCount = forts.length;
	int oldTeamForts = 0;
	int newTeamForts = 0;
	
	CRules@ rules = getRules();
	
	SetNearbyBlobsToTeam(this, oldTeam, newTeam);
	
	for(uint i = 0; i < totalFortCount; i++)
	{
		int fortTeamNum = forts[i].getTeamNum();
	
		if (fortTeamNum == newTeam)
		{
			newTeamForts++;
		}
		else if (fortTeamNum == oldTeam)
		{
			oldTeamForts++;
		}
	}
	
	if(oldTeamForts <= 0)
	{
		if (getNet().isServer())
		{
			CBitStream bt;
			bt.write_s32(newTeam);
			bt.write_s32(oldTeam);
			bt.write_bool(oldTeamForts == 0);

			this.SendCommand(this.getCommandID("faction_captured"), bt);
						
			// for(u8 i = 0; i < getPlayerCount(); i++)
			// {
				// CPlayer@ p = getPlayer(i);
				// if(p !is null && p.getTeamNum() == oldTeam)
				// {
					// p.server_setTeamNum(XORRandom(100)+100);
					// CBlob@ b = p.getBlob();
					// if(b !is null)
					// {
						// b.server_Die();
					// }
				// }
			// }
		}
	}
}

void SetNearbyBlobsToTeam(CBlob@ this, const int oldTeam, const int newTeam)
{
	CBlob@[] teamBlobs;
	this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @teamBlobs);

	for (uint i = 0; i < teamBlobs.length; i++)
	{
		CBlob@ b = teamBlobs[i];
		if(b.getName() != this.getName() && b.hasTag("change team on fort capture") && (b.getTeamNum() == oldTeam || b.getTeamNum() > 7))
		{
			b.server_setTeamNum(newTeam);
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.hasTag("upgrading")) return;

	CBlob@[] forts;
	getBlobsByTag("faction_base", @forts);

	CRules@ rules = getRules();
	int teamForts = 0; // Current fort is being faction_destroyed
	u8 team = this.getTeamNum();
	
	for(uint i = 0; i < forts.length; i++)
	{
		if (forts[i].getTeamNum() == team) teamForts++;
	}
	
	if (teamForts <= 0)
	{
		if (getNet().isServer())
		{
			CBitStream bt;
			bt.write_s32(team);
		
			this.SendCommand(this.getCommandID("faction_destroyed"), bt);
			
			// for(u8 i = 0; i < getPlayerCount(); i++)
			// {
				// CPlayer@ p = getPlayer(i);
				// if(p !is null && p.getTeamNum() == team)
				// {
					// p.server_setTeamNum(XORRandom(100)+100);
					// CBlob@ b = p.getBlob();
					// if(b !is null)
					// {
						// b.server_Die();
					// }
				// }
			// }
		}
	}
	else
	{
		// print("is gud");
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller) && caller.getTeamNum() >= 100 && this.getTeamNum() < 100)
	{
		TeamData@ team_data;
		GetTeamData(this.getTeamNum(), @team_data);
		
		if (team_data !is null)
		{
			bool deserter = caller.getPlayer() !is null && caller.getPlayer().get_u32("teamkick_time") > getGameTime();
			bool upkeep_gud = team_data.upkeep + UPKEEP_COST_PLAYER < team_data.upkeep_cap;
		
			string msg = "";
			if (deserter || !upkeep_gud) msg = "\n\nCannot join!\n" + (deserter ? "You are a deserter.\n" : "") + (!upkeep_gud ? "Faction's upkeep is too high.\n" : "");
			
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("button_join"), "Join the Faction" + msg, params);
			button.SetEnabled(!deserter && upkeep_gud);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{		
	if (getNet().isServer() || getNet().isClient())
	{
		if (cmd == this.getCommandID("button_join"))
		{
			u16 id;
			if (!params.saferead_u16(id)) return;

			CBlob@ blob = getBlobByNetworkID(id);
			
			u8 myTeam = this.getTeamNum();
		
			if (myTeam < 100 && blob !is null && this.isOverlapping(blob) && blob.hasTag("player") && !blob.hasTag("ignore_flags"))
			{
				CPlayer@ p = blob.getPlayer();
				if (p !is null)
				{
					TeamData@ team_data;
					GetTeamData(myTeam, @team_data);
				
					if (p.getTeamNum() >= 100 && team_data !is null)
					{
						bool deserter = p.get_u32("teamkick_time") > getGameTime();
						bool upkeep_gud = team_data.upkeep + UPKEEP_COST_PLAYER <= team_data.upkeep_cap;
						
						if (!deserter && upkeep_gud)
						{
							this.getSprite().PlaySound("party_join.ogg");
							
							if (getNet().isServer())
							{	
								p.server_setTeamNum(myTeam);
								CBlob@ newPlayer = server_CreateBlob("builder", myTeam, blob.getPosition());
								newPlayer.server_SetPlayer(p);
								
								blob.server_Die();
							}
						}
					}
				}
			}
		}
	}

	if (getNet().isClient())
	{
		if (cmd == this.getCommandID("faction_captured"))
		{
			CRules@ rules = getRules();
		
			int newTeam = params.read_s32();
			int oldTeam = params.read_s32();
			bool defeat = params.read_bool();
			
			if (!(oldTeam < getRules().getTeamsNum())) return;
			
			string oldTeamName = rules.getTeam(oldTeam).getName();
			string newTeamName = rules.getTeam(newTeam).getName();
			
			if (defeat)
			{
				client_AddToChat(oldTeamName + " has been defeated by the " + newTeamName + "!", SColor(0xff444444));
				
				CPlayer@ ply = getLocalPlayer();
				int myTeam = ply.getTeamNum();
				
				if (oldTeam == myTeam)
				{
					Sound::Play("FanfareLose.ogg");
				}
				else
				{
					Sound::Play("flag_score.ogg");
				}
			}
			else
			{
				client_AddToChat(oldTeamName + "'s Fortress been faction_captured by the " + newTeamName + "!", SColor(0xff444444));
			}
		}
		if (cmd == this.getCommandID("faction_destroyed"))
		{
			CRules@ rules = getRules();
		
			int team = params.read_s32();
			if (!(team < rules.getTeamsNum())) return;
			
			string teamName = rules.getTeam(team).getName();
		
			client_AddToChat(teamName + " has been defeated!", SColor(0xff444444));
			
			CPlayer@ ply = getLocalPlayer();
			int myTeam = ply.getTeamNum();
			
			if (team == myTeam)
			{
				Sound::Play("FanfareLose.ogg");
			}
			else
			{
				Sound::Play("flag_score.ogg");
			}
		}
	}
}
