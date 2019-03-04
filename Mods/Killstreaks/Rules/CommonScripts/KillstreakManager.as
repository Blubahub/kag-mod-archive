#define SERVER_ONLY

// Stores all player's usernames and their killstreaks (persisting between rounds). Killstreak resets on death.
dictionary playername_to_killstreak;

// Used to detect if a particular player got an ace this round
string team0_ace_player;
string team1_ace_player;
int team0_ace_player_kills;
int team1_ace_player_kills;
int team0_num_players;
int team1_num_players;

int getKillstreak(CPlayer@ player) {
    int kills;
    if (playername_to_killstreak.get(player.getUsername(), kills)) {
        return kills;
    }
    else {
        return 0;
    }
}

void setKillstreak(CPlayer@ player, int kills) {
    playername_to_killstreak.set(player.getUsername(), kills);
}

void addKillToStreak(CPlayer@ player)
{
    log("Adding kill to streak for " + player.getUsername());
    int current_killstreak = getKillstreak(player);
    int new_killstreak = current_killstreak + 1;

    log("Player " + player.getUsername() + " new killstreak " + new_killstreak);
    
    setKillstreak(player, new_killstreak);

    if (new_killstreak >= 3) {
        displayKillstreakMessage(player, "is on a " + new_killstreak + "-kill streak.");
    }

    if (new_killstreak == 5) {
        displayKillstreakMessage(player, "is dominating!");
    }
    else if (new_killstreak == 8) {
        displayKillstreakMessage(player, "is legendary!");
    }
    else if (new_killstreak >= 10 && new_killstreak % 5 == 0) {
        displayKillstreakMessage(player, "is GODLIKE!!!");
    }
}

string getFullName(CPlayer@ player) {
    return player.getClantag() + " " + player.getCharacterName(); 
}

void displayKillstreakMessage(CPlayer@ player, string msg) {
    log("Displaying killstreak message '" + msg + "' for " + player.getUsername());
    string name_with_msg = getFullName(player) + " " + msg;
    getNet().server_SendMsg(name_with_msg);
}

void log(string msg) {
    printf("[Killstreaks Mod] " + msg);
}

// HOOKS
void onNewPlayerJoin(CRules@ this, CPlayer@ player) {
    log("Player joined: " + player.getUsername());
    setKillstreak(player, 0);
}

void onPlayerLeave(CRules@ rules, CPlayer@ player) {
    log("Player left: " + player.getUsername());
    playername_to_killstreak.delete(player.getUsername());

    if (rules.getCurrentState() == 2) { // if we're playing
        if (player.getTeamNum() == 0) {
            team0_num_players--;
        }
        else {
            team1_num_players--;
        }
    }
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData) {
    log("Player " + victim.getUsername() + " died!");
    if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
    {
        log("They were killed by " + killer.getUsername());
        addKillToStreak(killer);

        if (killer.getTeamNum() == 0) {
            if (team0_ace_player == "") {
                team0_ace_player = killer.getUsername();
                log(killer.getUsername() + " is the ace player for team 0.");
            }

            if (team0_ace_player == killer.getUsername()) {
                team0_ace_player_kills += 1;

                // Check if player has killed entire enemy team
                if (team0_ace_player_kills == team1_num_players && team1_num_players > 1) {
                    log(killer.getUsername() + " aced team1!");
                    displayKillstreakMessage(killer, "aced the enemy team!");
                }
            }
        }
        else {
            if (team1_ace_player == "") {
                team1_ace_player = killer.getUsername();
                log(killer.getUsername() + " is the ace player for team 1.");
            }

            if (team1_ace_player == killer.getUsername()) {
                team1_ace_player_kills += 1;

                // Check if player has killed entire enemy team
                if (team1_ace_player_kills == team0_num_players && team0_num_players > 1) {
                    displayKillstreakMessage(killer, "aced the enemy team!");
                    log(killer.getUsername() + " aced team0!");
                }
            }
        }

        // Check if killer shut down victim
        int victim_streak = getKillstreak(victim);
        if (victim_streak >= 3) {
            int bounty = victim_streak * 10;
            killer.server_setCoins(killer.getCoins() + bounty);
            displayKillstreakMessage(killer, "shut down " + getFullName(victim) + "'s " + victim_streak + "-kill streak! " + bounty + " coin bounty awarded.");
        }
    }

    // Reset victim's kill streak
    setKillstreak(victim, 0);
}

void onInit(CRules@ this) {
    log("onInit called.");
}

void onReload(CRules@ this) {
    log("onReload called.");
}

void onRulesRestart(CMap@ this, CRules@ rules) {
    log("onRulesRestart called.");
}

void onStateChange(CRules@ rules, const u8 oldState) {
    log("onStateChange called. old state: " + oldState + " new state: " + rules.getCurrentState());

    if (rules.getCurrentState() == 2) {
        // Game is playing. Count the number of players in each team, so an ace can be detected.
        s32 num_players = getPlayerCount();

        team0_ace_player = "";
        team1_ace_player = "";
        team0_ace_player_kills = 0;
        team1_ace_player_kills = 0;
        team0_num_players = 0;
        team1_num_players = 0;
        for (int i=0; i < num_players; i++) {
            CPlayer@ player = getPlayer(i);
            log("Counting player " + player.getUsername() + " team " + player.getTeamNum());
            if(player.getTeamNum() == 0) {
                team0_num_players++;
            }
            else {
                team1_num_players++;
            }
        }
    }
}

void onRestart(CRules@ this) {
    log("onRestart called.");
}
