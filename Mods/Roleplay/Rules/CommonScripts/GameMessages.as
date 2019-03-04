/* GameMessages.as
 * author: Aphelion
 */

const string cmd_sendmessage = "rules send message";

const SColor MESSAGE_RED = SColor(255, 255, 0, 0);
const SColor MESSAGE_BLACK = SColor(255, 0, 0, 0);

void onInit( CRules@ this )
{
    this.addCommandID(cmd_sendmessage);
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
	if (cmd == this.getCommandID(cmd_sendmessage))
	{
	    string user, msg;
		bool red;
		
		if (!params.saferead_string(user) || !params.saferead_string(msg) || !params.saferead_bool(red))
		    return;
		
		CPlayer@ localPlayer = getLocalPlayer();
		if      (localPlayer !is null && localPlayer.getUsername() == user && getNet().isClient())
		{
		    printf("call");
	        client_AddToChat(msg, red ? MESSAGE_RED : MESSAGE_BLACK);
		}
	}
}

void cmdSendMessage( string player, string message, bool red )
{
	CBitStream params;
	params.write_string(player);
	params.write_string(message);
	params.write_bool(red);
	
	getRules().SendCommand(getRules().getCommandID(cmd_sendmessage), params);
}

void sendMessage( CPlayer@ player, SColor color, string message )
{
    if (getNet().isClient() && player !is null && getLocalPlayer() is player)
	{
	    client_AddToChat(message, color);
	}
}

void sendMessage( CPlayer@ player, string message )
{
    if (getNet().isClient() && player !is null && getLocalPlayer() is player)
	{
	    client_AddToChat(message, MESSAGE_BLACK);
	}
}

void sendMessage( string message )
{
    if (getNet().isClient())
	{
	    client_AddToChat(message, MESSAGE_BLACK);
	}
}
