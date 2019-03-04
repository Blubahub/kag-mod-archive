#define SERVER_ONLY

const string[] users = {
	"ShnitzelKiller"
};

/*

example usage:
const string[] users = {
	"Iron_Dude",
	"Stelios300",
};

*/

//BLACKLIST: RUN BACKGROUND CHECK
void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if(player !is null)
	{
		if((users.find(player.getUsername())) != (-1))
		{
			print(""+player.get_bool("blacklisted"));
			player.set_bool("blacklisted", true);
			player.Sync("blacklisted", true);
			print(""+player.get_bool("blacklisted"));
		}
	}
}