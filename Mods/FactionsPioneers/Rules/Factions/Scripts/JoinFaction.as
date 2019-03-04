#include "Factions.as";
#include "TeamColour.as";
#include "RPGCommon.as";
#include "BuildFaction.as";
#include "BuildBlock.as";
#include "Requirements.as";
#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

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
        Factions@ f;
        this.get("factions", @f);

        RPGCore@ core;
        this.get("core", @core);

        if(args.length > 1 && args[0] == "!create")
        {
            string name = "";
            for(int i = 1; i < args.length; i++)
            {
                name += (args[i] + " ");
            }
            name = name.substr(0, name.length()-1);

            Faction@ fact = f.getFactionByMemberName(player.getUsername());

            if(fact is null)
            {
                if(player.getCoins() >= 120)
                {
                    u8 createfaction = f.canCreateFaction(name, player.getUsername());

                    if(createfaction == 0)
                    {
                        BuildBlock[] blocks;
                        BuildBlock b(0, "factionbase", "", "");
                        b.buildOnGround = true;
                        b.size.Set(40, 24);
                        blocks.push_back(b);
                        CBlob@ fBase = server_BuildBlob(blob, @blocks, 0);
                        if(fBase !is null)
                        {
                            f.createFaction(name, player.getUsername());
                            Faction@ fact2 = f.getFactionByName(name);
                            player.server_setCoins(0);
                            core.ChangePlayerTeam(player, fact2.team);
                            fBase.server_setTeamNum(fact2.team);
                            fBase.setPosition(blob.getPosition() + Vec2f(0,-8));
                            f.removeAllInvitations(player.getUsername());
                            changeClass(blob, "builder", fact2.team);
                            send_chat(this, player, "Faction: " + name + " was successfully created", SColor(255, 255, 0, 0) );
                        }
                        else
                        {
                            send_chat(this, player, "Faction: " + name + " could not be created because there is not enough room for the faction base, you are in a restricted area, or you are too close to another base.", SColor(255, 255, 0, 0) );
                        }
                    }
                    else if(createfaction == 1)
                    {
                        send_chat(this, player, "Faction: " + name + " could not be created because there are too many factions!", SColor(255, 255, 0, 0) );
                    }
                    else if(createfaction == 2)
                    {
                        send_chat(this, player, "Faction: " + name + " could not be created because this name has been taken!", SColor(255, 255, 0, 0) );
                    }
                }
                else
                {
                    send_chat(this, player, "Faction: " + name + " could not be created because you don't have enough coins yet.", SColor(255, 255, 0, 0) );
                }
            }
            else
            {
                send_chat(this, player, "Faction: you must leave your faction before you can create another one. type !leave", SColor(255, 255, 0, 0) );
            }
        }
        else if(args.length > 1 && args[0] == "!invite")
        {
            string player_name = almostGetPlayerName(this, player, args[1]);
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
                fact.invite(player_name);
                send_chat(this, player, "Faction: " + player_name + " was successfully invited to your faction", SColor(255, 255, 0, 0) );
                send_chat(this, target, "You have just been invited to " + fact.name + ", type !join " + fact.name, getTeamColor(fact.team));
                this.set_string(target.getUsername() + ":last_invited", fact.name);
            }
        }
        else if(args[0] == "!join")
        {
            string name = "";
            for(int i = 1; i < args.length; i++)
            {
                name += (args[i] + " ");
            }
            name = name.substr(0, name.length()-1);
            string team_name = almostGetTeamName(this, player, name);

            if(args.length == 1)
                team_name = this.get_string(player.getUsername() + ":last_invited");

            if(team_name == "")
                return false;
            string player_name = player.getUsername();
            Faction@ fact = f.getFactionByName(team_name);
            Faction@ fact2 = f.getFactionByMemberName(player_name);
            if(fact !is null)
            {
                if(fact.isOnTheList(player_name) && fact !is fact2)
                {
                    send_chat(this, player, "Faction: you have successfully joined " + fact.name, SColor(255, 255, 0, 0) );
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
                    send_chat(this, player, "Faction: you were not on the invite list of that faction", SColor(255, 255, 0, 0) );
                }
            }
            else
            {
                send_chat(this, player, "Faction: the faction you are trying to join no longer exists", SColor(255, 255, 0, 0) );
            }
        }
        else if(args.length > 1 && args[0] == "!kick")
        {
            string player_name = almostGetPlayerName(this, player, args[1]);
            if(player_name == "")
                return false;

            Faction@ fact = f.getFactionByMemberName(player.getUsername());
            Faction@ fact2 = f.getFactionByMemberName(player_name);

            if(fact !is null && fact2 !is null && fact2.leader == player.getUsername() && player_name != player.getUsername())
            {
                fact.removeMember(player_name, true);
                send_chat(this, player, "Faction: " + player_name + " was successfully kicked from your faction", SColor(255, 255, 0, 0) );
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
        else if(args.length > 1 && args[0] == "!newleader")
        {
            string player_name = almostGetPlayerName(this, player, args[1]);
            if(player_name == "")
                return false;

            Faction@ fact = f.getFactionByMemberName(player.getUsername());

            if(fact !is null && fact.leader == player.getUsername())
            {
                CPlayer@ target = getPlayerByUsername(player_name);
                if(target !is null)
                {
                    fact.changeLeader(player_name);
                    send_chat(this, target, "Faction: you were promoted to leader of your faction", SColor(255, 255, 0, 0) );

                }
                send_chat(this, player, "Faction: " + player_name + " was successfully promoted to leader of your faction", SColor(255, 255, 0, 0) );
            }
        }
        else if(args.length > 1 && args[0] == "!list")
        {
            string name = "";
            for(int i = 1; i < args.length; i++)
            {
                name += args[i] + " ";
            }
            name = name.substr(0, name.length()-1);

            string team_name = almostGetTeamName(this, player, name);
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
                send_chat(this, player, member_name, getTeamColor(fact.team));
            }
        }
        else if(args.length > 1 && args[0] == "!promote")
        {
            string player_name = almostGetPlayerName(this, player, args[1]);
            if(player_name == "")
                return false;

            Faction@ fact = f.getFactionByMemberName(player.getUsername());

            if(fact !is null && fact.leader == player.getUsername())
            {
                CPlayer@ target = getPlayerByUsername(player_name);
                if(target !is null)
                {
                    fact.promote(player_name);
                    send_chat(this, target, "Faction: you have been promoted to moderator. Now you can invite other players using !f invite", SColor(255,255,0,0));
                }
                send_chat(this, player, "Faction: " + player_name + " was successfully promoted to a moderator of your faction", SColor(255, 255, 0, 0) );
            }
        }
        else if(args.length > 1 && args[0] == "!demote")
        {
            string player_name = almostGetPlayerName(this, player, args[1]);
            if(player_name == "")
                return false;

            Faction@ fact = f.getFactionByMemberName(player.getUsername());

            if(fact !is null && fact.leader == player.getUsername())
            {
                CPlayer@ target = getPlayerByUsername(player_name);
                if(target !is null)
                {
                    fact.demote(player_name);
                    send_chat(this, target, "Faction: you have been demoted from moderator. You can no longer invite other players.", SColor(255,255,0,0));
                }
                send_chat(this, player, "Faction: " + player_name + " was successfully demoted from a moderator of your faction", SColor(255, 255, 0, 0) );
            }
        }
        else if(args[0] == "!leave")
        {
            Faction@ fact = f.getFactionByMemberName(player.getUsername());

            if(fact !is null)
            {
                fact.removeMember(player.getUsername(), false);
                player.server_setCoins(0);
                core.ChangePlayerTeam(player, 7);
                send_chat(this, player, "Faction: you have successfully left your faction", SColor(255, 255, 0, 0) );
                if(blob !is null)
                {
                    blob.server_Die();
                }
            }
        }
        else if(args.length == 1 && args[0] == "!list")
        {
            for(int i = 0; i < f.factions.length; i++)
            {
                Faction@ fact = f.factions[i];
                if(fact !is null && fact.members.length > 0)
                {
                    send_chat(this, player, "( " + fact.members.length + " ) " + fact.name, getTeamColor(fact.team));
                }
            }
        }
        else if(args[0] == "!help")
        {
            if(args.length == 1)
            {
                send_chat(this, player, "All player names and faction names can be shortened when entering a command", SColor(255, 255, 0, 0));
                send_chat(this, player, "For example, you can do something like '!invite mak' instead of '!invite makmoud98'", SColor(255, 255, 0, 0));
                send_chat(this, player, "That is just one of the commands. Here is the full list:", SColor(255, 255, 0, 0));
                send_chat(this, player, "create, invite, join, leave, kick, newleader, list, promote, and demote", SColor(255, 255, 0, 0));
                send_chat(this, player, "Example: '!help create' or maybe '!help kick' these will show you how to properly use the commands", SColor(255, 255, 0, 0));
            }
            else if(args.length == 2)
            {
                string t = args[1];
                if(t == "create")
                {
                    send_chat(this, player, "Example: !create The Cool Kids", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it creates a faction with the given name and spawns a base at your position", SColor(255, 255, 0, 0));
                    send_chat(this, player, "Only the first six factions will actually have their own color, the rest will have to use the neutral color.", SColor(255, 255, 0, 0));
                    send_chat(this, player, "When you are factionless, you will need to wait until you have 120 coins to create your own faction", SColor(255, 255, 0, 0));
                }
                else if(t == "invite")
                {
                    send_chat(this, player, "Example: !invite makmoud98", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it invites a player to your faction with the given name", SColor(255, 255, 0, 0));
                    send_chat(this, player, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
                }
                else if(t == "join")
                {
                    send_chat(this, player, "Example: !join The Cool Kids", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it allows you to join faction with the given name if you have already been invited", SColor(255, 255, 0, 0));
                }
                else if(t == "kick")
                {
                    send_chat(this, player, "Example: !kick makmoud98", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it kicks a player from your faction with the given name", SColor(255, 255, 0, 0));
                    send_chat(this, player, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
                }
                else if(t == "newleader")
                {
                    send_chat(this, player, "Example: !newleader makmoud98", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it assigns a player that is already in your faction the leader title with the given name", SColor(255, 255, 0, 0));
                    send_chat(this, player, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
                }
                else if(t == "list")
                {
                    send_chat(this, player, "Example: !list", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it displays a list of all the factions", SColor(255, 255, 0, 0));
                    send_chat(this, player, "Example: '!list The Cool Kids'", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it displays a list of all the players in the faction that is defined by the given name", SColor(255, 255, 0, 0));
                }
                else if(t == "promote")
                {
                    send_chat(this, player, "Example: !promote makmoud98", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it assigns a player that is already in your faction the moderator title with the given name", SColor(255, 255, 0, 0));
                    send_chat(this, player, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
                }
                else if(t == "demote")
                {
                    send_chat(this, player, "Example: !demote makmoud98", SColor(255, 255, 0, 0));
                    send_chat(this, player, "DESCRIPTION: it demotes a player that is already in your faction from, the moderator title with the given name", SColor(255, 255, 0, 0));
                    send_chat(this, player, "You need to be the leader of your faction to use this.", SColor(255, 255, 0, 0));
                }
            }
        }
        else
        {
            if (text_in == "!killme")
            {
                blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 4.0f, 0);
            }
            else if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
            {
                CPlayer@ bot = AddBot("Henry");
                return true;
            }
            else if (text_in == "!debug" && player.isMod())
            {
                // print all blobs
                CBlob@[] all;
                getBlobs(@all);

                for (u32 i = 0; i < all.length; i++)
                {
                    CBlob@ blob = all[i];
                    print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
                }
            }

            //spawning things

            //these all require sv_test - no spawning without it
            //some also require the player to have mod status
            if (sv_test || player.getUsername() == "Koi_")
            {
                Vec2f pos = blob.getPosition();
                int team = blob.getTeamNum();

                if (text_in == "!tree")
                {
                    server_MakeSeed(pos, "tree_pine", 600, 1, 16);
                }
                else if (text_in == "!btree")
                {
                    server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
                }
                else if (text_in == "!stones")
                {
                    CBlob@ b = server_CreateBlob("Entities/Materials/MaterialStone.cfg", team, pos);

                    if (b !is null)
                    {
                        b.server_SetQuantity(320);
                    }
                }
                else if (text_in == "!arrows")
                {
                    for (int i = 0; i < 3; i++)
                    {
                        CBlob@ b = server_CreateBlob("Entities/Materials/MaterialArrows.cfg", team, pos);

                        if (b !is null)
                        {
                            b.server_SetQuantity(30);
                        }
                    }
                }
                else if (text_in == "!bombs")
                {
                    //  for (int i = 0; i < 3; i++)
                    CBlob@ b = server_CreateBlob("Entities/Materials/MaterialBombs.cfg", team, pos);

                    if (b !is null)
                    {
                        b.server_SetQuantity(30);
                    }
                }
                else if (text_in == "!spawnwater" && player.isMod())
                {
                    getMap().server_setFloodWaterWorldspace(pos, true);
                }
                else if (text_in == "!seed")
                {
                    // crash prevention?
                }
                else if (text_in == "!crate")
                {
                    client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0));
                    server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
                }
                else if (text_in == "!coins")
                {
                    player.server_setCoins(player.getCoins() + 100);
                }
                else if (text_in.substr(0, 1) == "!")
                {
                    // check if we have tokens
                    string[]@ tokens = text_in.split(" ");

                    if (tokens.length > 1)
                    {
                        if (tokens[0] == "!crate")
                        {
                            int frame = tokens[1] == "catapult" ? 1 : 0;
                            string description = tokens.length > 2 ? tokens[2] : tokens[1];
                            server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
                        }
                        else if (tokens[0] == "!team")
                        {
                            int team = parseInt(tokens[1]);
                            blob.server_setTeamNum(team);
                        }
                        else if (tokens[0] == "!scroll")
                        {
                            string s = tokens[1];
                            for (uint i = 2; i < tokens.length; i++)
                                s += " " + tokens[i];
                            server_MakePredefinedScroll(pos, s);
                        }

                        return true;
                    }

                    // try to spawn an actor with this name !actor
                    string name = text_in.substr(1, text_in.size());

                    if (server_CreateBlob(name, team, pos) is null)
                    {
                        client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
                    }
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

        for(int i = 0; i < getPlayerCount(); i++)
        {
            CPlayer@ target = getPlayer(i);
            if(target is null)
                continue;
            if(target.getTeamNum() == x)
            {
                send_chat(this, target, "Faction: Your faction base has been destroyed; therefore, your faction is disbanded.", SColor(255, 255, 0, 0));
            }
        }

        CBlob@[] all;
        getBlobs(@all);
        for(int i = 0; i < all.length; i++)
        {
            CBlob@ b = all[i];
            if(b.getTeamNum() == x)
            {
                b.server_Die();
            }
        }
    }
}


void send_chat(CRules@ this, CPlayer@ player, string x, SColor color)
{
    CBitStream params;
    params.write_netid(player.getNetworkID());
    params.write_u8(color.getRed());
    params.write_u8(color.getGreen());
    params.write_u8(color.getBlue());
    params.write_string(x);
    this.SendCommand(this.getCommandID("send_chat"), params);
}

string almostGetPlayerName(CRules@ this, CPlayer@ player, string x)
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
        send_chat(this, player, "Faction: More than 1 match has been found when searching for " + x, SColor(255, 255, 0, 0) );
        return "";
    }
    else if(count == 0)
    {
        send_chat(this, player, "Faction: No matches have been found when searching for " + x, SColor(255, 255, 0, 0) );
        return "";
    }
    else
    {
        player_name = temp;
    }

    return player_name;
}

//this returns the full name of the faction by only typing in part of it cuz no one wants to type XxX-Blaze it-XxX exactly
string almostGetTeamName(CRules@ this, CPlayer@ player, string x)
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
        send_chat(this, player, "Faction: More than 1 match has been found when searching for " + x, SColor(255, 255, 0, 0) );
        return "";
    }
    else if(count == 0)
    {
        send_chat(this, player, "Faction: No matches have been found when searching for " + x, SColor(255, 255, 0, 0) );
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
