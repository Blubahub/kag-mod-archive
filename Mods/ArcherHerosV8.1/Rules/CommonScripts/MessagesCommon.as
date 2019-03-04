/* MessagesCommon.as
 * author: Aphelion
 */

const string cmd_message = "rules send message";

const SColor BLACK = SColor(255, 0, 0, 0);
const SColor RED = SColor(255, 255, 0, 0);

void cmdSendMessage( string player, string message, bool red )
{
	CBitStream params;
	params.write_string(player);
	params.write_string(message);
	params.write_bool(red);
	
	getRules().SendCommand(getRules().getCommandID(cmd_message), params);
}
