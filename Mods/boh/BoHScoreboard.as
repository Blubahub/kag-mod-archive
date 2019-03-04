
// set kills and deaths

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData ){
    if (victim !is null){
		if(killer is null || killer.lastBlobName != "wizard"){
			if (killer !is null && killer !is victim && killer.getTeamNum() != victim.getTeamNum()){
				CBlob@ blob = victim.getBlob();
				if (blob !is null && blob.getName() == "wizard"){
					killer.setKills(killer.getKills() + 4);
				}
				killer.setKills(killer.getKills() + 1);
				updateScore(killer);
			}

			victim.setDeaths(victim.getDeaths() + 1);
			updateScore(victim);
		}
    }
}

void updateScore(CPlayer@ player){
	player.setScore(2 * player.getKills() - player.getDeaths());
}

void onRestart( CRules@ this ){
	int count = getPlayerCount();
	CPlayer@ player;
	for (uint i = 0; i < count; i++) {
		@player = getPlayer(i);
		player.setKills(0);
		player.setDeaths(0);
		player.setScore(0);
	}
}
