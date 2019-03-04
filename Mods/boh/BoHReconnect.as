
void onTick( CRules@ this ){
	if((getGameTime() % 6) != 0) return;
	CPlayer@ player = getLocalPlayer();
	if(player !is null){
		string[] p;
		this.get("players", p);
		if(p.find(player.getUsername()) == -1){
			this.Sync("players", false);
			this.get("players", p);
			if(p.find(player.getUsername()) == -1){
				getNet().DisconnectClient();
				string[] ip = getNet().joined_ip.split(":");
				getNet().Connect( ip[0], parseInt(ip[1]) );
			}
		}
	}
}
