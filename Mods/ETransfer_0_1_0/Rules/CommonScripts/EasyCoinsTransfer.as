#define CLIENT_ONLY

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player) {
	if (text_in.substr(0, 1) == "E")
	{
		string[]@ tokens = text_in.split(" ");
		
		if(tokens[0] == "ETransfer" && tokens.length < 3) {
			int SCoins = player.getCoins();
			CPlayer@ receiver = getPlayerByUsername(tokens[1]);
			int SendCoins = parseInt(tokens[2]);
			if(SCoins >= SendCoins) {
				receiver.server_setCoins(receiver.getCoins() + SendCoins);
				player.server_setCoins(SCoins - SendCoins);
				client_AddToChat("ETransfer :: Successfully Transfered !");
				return false;
			}
			else {
				client_AddToChat("ETransfer :: Not Enought Coins !");
			}
		}
		/*if(tokens[0] == "EBank") {
			SCoins = player.getCoins();
			SendCoins = (int) tokens[1];
		}*/
		return true;
	}
	return true;
}