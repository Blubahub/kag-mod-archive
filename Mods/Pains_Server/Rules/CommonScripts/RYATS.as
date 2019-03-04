namespace RYATS
{
// ---------------------------------CONFIGURATION VARS----------------------------------------
const string NOTIFICATION_SOUND = "party_join.ogg";

const bool NOTIFY_ON_NICKNAME = true;
const bool NOTIFY_ON_USERNAME = true;
const bool CASE_SENSITIVE = false;

const bool ENABLE_MUTING = true; //you'd be a monster to disable this
const string MUTING_COMMAND = "!mute";

bool showStartupMessage = true; // will tell every joining player how to mute the chat
// ------------------------------------------------------------------------------------------

bool muted = false;

void onTick()
{
	if (showStartupMessage)
	{
		client_AddToChat("[RYATS] This server is using RYATS chat notifications");
		client_AddToChat("[RYATS] Type !mute to disable/re-enable them");
		showStartupMessage = false;
	}
}

void onClientProcessChat( const string& in text_in, CPlayer@ fromPlayer )
{
	CPlayer@ myPlayer = getLocalPlayer();
	if (myPlayer is null)
		return;

	if (ENABLE_MUTING && text_in == MUTING_COMMAND && fromPlayer is myPlayer)
	{
		muted = !muted;

		client_AddToChat(muted?"[RYATS] Chat notifications disabled": "[RYATS] Chat notifications enabled");
	}

	// don't notify if you posted the message or if you muted the chat
	if (muted || fromPlayer is myPlayer)
		return;

	string message = text_in;
	string nickname = myPlayer.getCharacterName();
	string username = myPlayer.getUsername();

	if (!CASE_SENSITIVE)
	{
		//make it all lowercase so it's case insensitive
		message = message.toLower();
		nickname = nickname.toLower();
		username = username.toLower();
	}

	bool nicknameInMessage = message.find(nickname) != -1;
	bool usernameInMessage = message.find(username) != -1;

	if ((nicknameInMessage && NOTIFY_ON_NICKNAME) || (usernameInMessage && NOTIFY_ON_USERNAME))
    {
    	Sound::Play(NOTIFICATION_SOUND);
    }

    return;
}
}