#include "Factions.as";
#include "TeamColour.as";
#include "RPGCommon.as";
#include "BuildFaction.as";
#include "BuildBlock.as";
#include "Requirements.as";

void onInit(CRules@ this)
{
    this.addCommandID("join");
    this.addCommandID("deny");
    this.addCommandID("spawnPlayer");
    this.addCommandID("killFaction");
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
    //wow
    if(player is null)
        return true;

    if(player.getCharacterName() != player.getUsername())
    {
        text_out = "<" + player.getUsername() + "> " + text_in;
    }

    CBlob@ blob = player.getBlob();

    if(blob is null)
        return true;

    string[]@ args = text_in.split(" ");

    if(args.length > 0)
    {
        if(args[0] == "!f")
        {
            Factions@ f;
            this.get("factions", @f);

            RPGCore@ core;
            this.get("core", @core);

            if(args.length > 2)
            {
                if(args[1] == "create")
                {
                    string name = "";
                    for(int i = 2; i < args.length; i++)
                    {
                        name += (args[i] + " ");
                    }
                    name = name.substr(0, name.length()-1); 

                    Faction@ fact = f.getFactionByMemberName(player.getUsername());
                    
                    if(fact is null)
                    {
                        if(player.getCoins() >= 120)
                        {   
                            BuildBlock[] blocks;
                            BuildBlock b(0, "factionbase", "", "");
                            b.buildOnGround = true;
                            b.size.Set(40, 24);
                            blocks.push_back(b);
                            CBlob@ fBase = server_BuildBlob(blob, @blocks, 0);   
                            if(fBase !is null)
                            {
                                if(f.createFaction(name, player.getUsername()))
                                {
                                    Faction@ fact2 = f.getFactionByName(name);
                                    player.server_setCoins(0);
                                    core.ChangePlayerTeam(player, fact2.team);
                                    fBase.server_setTeamNum(fact2.team);
                                    fBase.setPosition(blob.getPosition() + Vec2f(0,-8));
                                    CBlob@ fire = server_CreateBlobNoInit("fire"); 
                                    fire.server_setTeamNum(fBase.getTeamNum());
                                    fire.setPosition(fBase.getPosition() + Vec2f(-6,8));
                                    fire.Init();
                                    if(fire !is null && fire.getShape() !is null)
                                        fire.getShape().SetStatic(true);
                                    f.removeAllInvitations(player.getUsername());
                                    changeClass(blob, "builder", fact2.team);
                                    send_chat(blob, "Faction: " + name + " was successfully created", SColor(255, 255, 0, 0) ); 
                                }
                                else
                                {
                                    fBase.server_Die();
                                    send_chat(blob, "Faction: " + name + " could not be created because there are too many factions!", SColor(255, 255, 0, 0) );
                                } 
                            }
                            else
                            {
                                send_chat(blob, "Faction: " + name + " could not be created because there is not enough room for the faction base or it is too close to another Faction!", SColor(255, 255, 0, 0) );
                            }
                        }
                        else
                        {
                            send_chat(blob, "Faction: " + name + " could not be created because you don't have enough coins yet.", SColor(255, 255, 0, 0) );
                        }       
                    }
                    else
                    {
                        send_chat(blob, "Faction: you must leave your faction before you can create another one. type !f leave", SColor(255, 255, 0, 0) ); 
                    }
                }
                else if(args[1] == "invite")
                {
                	string player_name = almostGetPlayerName(blob, args[2]);
                	if(player_name == "")
                		return false;

                    Faction@ fact = f.getFactionByMemberName(player.getUsername());

                    if(fact !is null && (fact.leader == player.getUsername() || fact.moderators.find(player.getUsername()) != -1))
                    {
                        CPlayer@ target = getPlayerByUsername(player_name);
                        if(target is null)
                        {
                            return false;
                        }
                        else if(target.isBot())//this is to help me test with bots
                        {
                            Faction@ fact2 = f.getFactionByMemberName(player_name);
                            if(fact2 !is null)
                            {
                                fact2.removeMember(player_name, false);
                            }
                            fact.addMember(player_name);
                            f.removeAllInvitations(player_name);
                            CBlob@ b = target.getBlob();
                            if(b !is null)
                            {    
                                b.server_Die();
                            }
                            core.ChangePlayerTeam(target, fact.team);
                            return false;
                        }
                        CBlob@ b = target.getBlob();
                        if(b is null)
                        {
                            send_chat(blob, "Faction: " + player_name + " is not alive, he didn't receive the invite", SColor(255, 255, 0, 0) );
                        }
                        
                        fact.invite(player_name);
                        send_chat(blob, "Faction: " + player_name + " was successfully invited to your faction", SColor(255, 255, 0, 0) );
                        send_chat(b, "You have just been invited to " + fact.name + ", type !f join " + fact.name, getTeamColor(fact.team));
                    }
                }
                else if(args[1] == "join")
                {
                    string name = "";
                    for(int i = 2; i < args.length; i++)
                    {
                        name += (args[i] + " ");
                    }
                    name = name.substr(0, name.length()-1); 
                    string team_name = almostGetTeamName(this, blob, name);
                    if(team_name == "")
                        return false;
                    string player_name = player.getUsername();
                    Faction@ fact = f.getFactionByName(team_name);
                    Faction@ fact2 = f.getFactionByMemberName(player_name);
                    if(fact.isOnTheList(player_name) && fact !is fact2)
                    {
                        send_chat(blob, "Faction: you have successfully joined " + fact.name, SColor(255, 255, 0, 0) );
                        //check if is already in faction
                        if(fact2 !is null)
                        {
                            fact2.removeMember(player_name, false);
                        }
                        fact.addMember(player_name);
                        f.removeAllInvitations(player_name);
                        blob.server_Die();
                        core.ChangePlayerTeam(player, fact.team);
                    }
                    else
                    {
                        send_chat(blob, "Faction: you were not on the invite list of that faction", SColor(255, 255, 0, 0) );
                    }
                }
                else if(args[1] == "kick")
                {
                	string player_name = almostGetPlayerName(blob, args[2]);
                	if(player_name == "")
                		return false;

                    Faction@ fact = f.getFactionByMemberName(player.getUsername());

                    if(fact !is null && fact.leader == player.getUsername() && player_name != player.getUsername())
                    {
                        fact.removeMember(player_name, true);
                        send_chat(blob, "Faction: " + player_name + " was successfully kicked from your faction", SColor(255, 255, 0, 0) );
                        CPlayer@ p = getPlayerByUsername(player_name);
                        if(p !is null)
                        {
                            p.server_setCoins(0);
                            core.ChangePlayerTeam(p, 7);
                            if(p.getBlob() !is null)
                            {
                                p.getBlob().server_Die();
                            }
                        }
                    }
                }
                else if(args[1] == "newleader")
                {
                	string player_name = almostGetPlayerName(blob, args[2]);
                	if(player_name == "")
                		return false;

                    Faction@ fact = f.getFactionByMemberName(player.getUsername());

                    if(fact !is null && fact.leader == player.getUsername())
                    {
                        if(getPlayerByUsername(player_name) !is null)
                        {
                            fact.changeLeader(player_name);
                        }
                        send_chat(blob, "Faction: " + player_name + " was successfully promoted to leader of your faction", SColor(255, 255, 0, 0) );
                    }
                }
                else if(args[1] == "list")
                {
                	string name = "";
                	for(int i = 2; i < args.length; i++)
                	{
                		name += args[i] + " ";
                	}
                	name = name.substr(0, name.length()-1);

                	string team_name = almostGetTeamName(this, blob, name);
                	if(team_name == "")
                		return false;

                    Faction@ fact = f.getFactionByName(team_name);

                    if(fact is null)
                    {
                    	return false;
                    }

                    for(int i = 0; i < fact.members.length; i++)
                    {
                    	string member_name = fact.members[i];
                    	if(member_name == fact.leader)
                    	{
                    		member_name += " **";
                    	}
                        send_chat(blob, member_name, getTeamColor(fact.team));
                    }
                }
                else if(args[1] == "promote")
                {
                    string player_name = almostGetPlayerName(blob, args[2]);
                    if(player_name == "")
                        return false;

                    Faction@ fact = f.getFactionByMemberName(player.getUsername());

                    if(fact !is null && fact.leader == player.getUsername())
                    {
                        if(getPlayerByUsername(player_name) !is null)
                        {
                            fact.promote(player_name);
                        }
                        send_chat(blob, "Faction: " + player_name + " was successfully promoted to a moderator of your faction", SColor(255, 255, 0, 0) );
                        CPlayer@ p = getPlayerByUsername(player_name);
                        if(p !is null)
                        {
                            CBlob@ b = p.getBlob();
                            if(b !is null)
                            {
                                send_chat(b, "Faction: you have been promoted to moderator. Now you can invite other players using !f invite", SColor(255,255,0,0));
                            }
                        }
                    }
                }
                else if(args[1] == "demote")
                {
                    string player_name = almostGetPlayerName(blob, args[2]);
                    if(player_name == "")
                        return false;

                    Faction@ fact = f.getFactionByMemberName(player.getUsername());

                    if(fact !is null && fact.leader == player.getUsername())
                    {
                        if(getPlayerByUsername(player_name) !is null)
                        {
                            fact.demote(player_name);
                        }
                        send_chat(blob, "Faction: " + player_name + " was successfully demoted from a moderator of your faction", SColor(255, 255, 0, 0) );
                        CPlayer@ p = getPlayerByUsername(player_name);
                        if(p !is null)
                        {
                            CBlob@ b = p.getBlob();
                            if(b !is null)
                            {
                                send_chat(b, "Faction: you have been demoted from moderator. You can no longer invite other players.", SColor(255,255,0,0));
                            }
                        }
                    }
                }
            }
            else if(args.length > 1)
            {
                if(args[1] == "leave")
                {
                    Faction@ fact = f.getFactionByMemberName(player.getUsername());
                    
                    if(fact !is null)
                    {
                        fact.removeMember(player.getUsername(), false);
                        player.server_setCoins(0);
                        core.ChangePlayerTeam(player, 7);
                        if(blob !is null)
                        {  
                            send_chat(blob, "Faction: you have successfully left your faction", SColor(255, 255, 0, 0) );
                            blob.server_Die();
                        }
                    }
                }
                else if(args[1] == "list")
                {
                    for(int i = 0; i < f.factions.length; i++)
                    {
                        Faction@ fact = f.factions[i];
                        if(fact !is null && fact.members.length > 0)
                        {
                        	send_chat(blob, "( " + fact.members.length + " ) " + fact.name, getTeamColor(fact.team));
                        }
                    }
                }
            }
        }
        else if(args[0] == "!help")
        {
        	if(args.length == 1)
        	{
        		send_chat(blob, "Every faction related command needs to have '!f' first", SColor(255, 255, 0, 0));
        		send_chat(blob, "For example, you can do something like '!f leave'", SColor(255, 255, 0, 0));
        	    send_chat(blob, "All player names and faction names can be shortened when entering a command", SColor(255, 255, 0, 0));
            	send_chat(blob, "That is just one of the commands. Here are the rest of them:", SColor(255, 255, 0, 0));
        		send_chat(blob, "create, invite, join, kick, newleader, list, promote, and demote", SColor(255, 255, 0, 0));
        		send_chat(blob, "Example: '!help create' or maybe '!help kick' these will show you how to properly use the commands", SColor(255, 255, 0, 0));
        	}
        	else if(args.length == 2)
        	{
        		string t = args[1];
        		if(t == "create")
        		{
        			send_chat(blob, "Example: !f create The Cool Kids", SColor(255, 255, 0, 0));
        			send_chat(blob, "DESCRIPTION: it creates a faction with the given name and spawns a base at your position", SColor(255, 255, 0, 0));
        			send_chat(blob, "Only the first six factions will actually have their own color, the rest will have to use the neutral color.", SColor(255, 255, 0, 0));
                    send_chat(blob, "When you are factionless, you will need to wait until you have 120 coins to create your own faction", SColor(255, 255, 0, 0));
        		}
        		else if(t == "invite")
                {
                    send_chat(blob, "Example: !f invite makmoud98", SColor(255, 255, 0, 0));
                    send_chat(blob, "DESCRIPTION: it invites a player to your faction with the given name", SColor(255, 255, 0, 0));
                    send_chat(blob, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
                }
                else if(t == "join")
                {
                    send_chat(blob, "Example: !f join The Cool Kids", SColor(255, 255, 0, 0));
                    send_chat(blob, "DESCRIPTION: it allows you to join faction with the given name if you have already been invited", SColor(255, 255, 0, 0));
                }
        		else if(t == "kick")
        		{
        			send_chat(blob, "Example: !f kick makmoud98", SColor(255, 255, 0, 0));
        			send_chat(blob, "DESCRIPTION: it kicks a player from your faction with the given name", SColor(255, 255, 0, 0));
        			send_chat(blob, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
        		}
        		else if(t == "newleader")
        		{
        			send_chat(blob, "Example: !f newleader makmoud98", SColor(255, 255, 0, 0));
        			send_chat(blob, "DESCRIPTION: it assigns a player that is already in your faction the leader title with the given name", SColor(255, 255, 0, 0));
        			send_chat(blob, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
        		}
        		else if(t == "list")
        		{
        			send_chat(blob, "Example: !f list", SColor(255, 255, 0, 0));
        			send_chat(blob, "DESCRIPTION: it displays a list of all the factions", SColor(255, 255, 0, 0));
        			send_chat(blob, "Example: '!f list The Cool Kids'", SColor(255, 255, 0, 0));
        			send_chat(blob, "DESCRIPTION: it displays a list of all the players in the faction that is defined by the given name", SColor(255, 255, 0, 0));
        		}
                else if(t == "promote")
                {
                    send_chat(blob, "Example: !f promote makmoud98", SColor(255, 255, 0, 0));
                    send_chat(blob, "DESCRIPTION: it assigns a player that is already in your faction the moderator title with the given name", SColor(255, 255, 0, 0));
                    send_chat(blob, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
                }
                else if(t == "demote")
                {
                    send_chat(blob, "Example: !f demote makmoud98", SColor(255, 255, 0, 0));
                    send_chat(blob, "DESCRIPTION: it demotes a player that is already in your faction from, the moderator title with the given name", SColor(255, 255, 0, 0));
                    send_chat(blob, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
                }
        	}
        }
    }
    return true;
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
    RPGCore@ core;
    this.get("core", @core);

    if(cmd == this.getCommandID("killFaction"))
    {
        Factions@ f;
        this.get("factions", @f);
    	if(f is null)
    		return;
        s8 x = params.read_s8();
        Faction@ fact = f.getFactionByTeamNum(x);

        if(fact is null)
            return;

        for(int i = 0; i < fact.members.length; i++)
        {
            CPlayer@ p = getPlayerByUsername(fact.members[i]);
            if(p !is null)
            {
                core.ChangePlayerTeam(p, 7);
            }
        }
        f.removeFaction(x);
        CBlob@[] all;
        getBlobs(@all);
        for(int i = 0; i < all.length; i++)
        {
            CBlob@ b = all[i];
            if(b.getTeamNum() == x)
            {
                if(b.hasTag("player"))
                {
                    send_chat(b, "Faction: Your faction base has been destoryed; therefore, your faction is disbanded.", SColor(255, 255, 0, 0));
                }
                b.server_Die();
            }
        }
    }
}


void send_chat(CBlob@ blob, string x, SColor color)
{
    if(blob is null)
        return;
    CBitStream params;
    params.write_netid(blob.getNetworkID());
    params.write_u8(color.getRed());
    params.write_u8(color.getGreen());
    params.write_u8(color.getBlue());
    params.write_string(x);
    blob.SendCommand(blob.getCommandID("send_chat"), params);
}

string almostGetPlayerName(CBlob@ blob, string x)
{
	string player_name = x.toLower();
    string temp = player_name;
    string[] players;
    for(int i = 0; i < getPlayerCount(); i++)
    {
        CPlayer@ p = getPlayer(i);
        if(p !is null)
        {
            players.push_back(p.getUsername());
        }
    } 
    u8 count = 0;

    for(int i = 0; i < players.length; i++)
    {
        string a = players[i];
        if(a.toLower() == player_name.toLower())
            return a;
        if(a.toLower().find(player_name) >= 0)
        {
            temp = a;
            count++;
        }
    }

    if(count > 1)
    {
        send_chat(blob, "Faction: More than 1 match has been found when searching for " + x, SColor(255, 255, 0, 0) );
        return "";
    }
    else if(count == 0)
    {
    	send_chat(blob, "Faction: No matches have been found when searching for " + x, SColor(255, 255, 0, 0) );
        return "";
    }
    else 
    {
        player_name = temp;
    }

	return player_name;
}

//this returns the full name of the faction by only typing in part of it cuz no one wants to type XxX-Blaze it-XxX exactly
string almostGetTeamName(CRules@ this, CBlob@ blob, string x)
{
	Factions@ f;
    this.get("factions", @f);

	string team_name = x.toLower();
    string temp = team_name;
    string[] teamnames;
    for(int i = 0; i < f.factions.length; i++)
    {
        Faction@ fact = f.factions[i];
        if(fact !is null)
        {
            teamnames.push_back(fact.name);
        }
    } 
    u8 count = 0;

    for(int i = 0; i < teamnames.length; i++)
    {
        string a = teamnames[i];
        if(a.toLower() == team_name.toLower())
            return a;
        if(a.toLower().find(team_name) >= 0)
        {
            temp = a;
            count++;
        }
    }

    if(count > 1)
    {
        send_chat(blob, "Faction: More than 1 match has been found when searching for " + x, SColor(255, 255, 0, 0) );
        return "";
    }
    else if(count == 0)
    {
    	send_chat(blob, "Faction: No matches have been found when searching for " + x, SColor(255, 255, 0, 0) );
        return "";
    }
    else 
    {
        team_name = temp;
    }

	return team_name;
}

void changeClass(CBlob@ blob, string config, s8 team)
{
	CBlob@ newBlob = server_CreateBlob(config, team, blob.getPosition());
	newBlob.server_SetPlayer(blob.getPlayer());
	blob.server_SetPlayer(null);
	blob.server_Die();
}
