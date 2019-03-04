#include "GameColours.as"
#include "UI.as"
#include "TRChatCommon.as"
#include "SoldierCommon.as"
#include "PlayerStatsCommon.as"

//set up the chat console properly
void onInit(CRules@ this)
{
	cl_chatbubbles = false;

	Driver@ driver = getDriver();
	if (driver is null) return;

	f32 width = driver.getScreenWidth();
	f32 height = driver.getScreenHeight();

	f32 chat_width = 350;
	f32 chat_halfwidth = chat_width * 0.5f;
	f32 chat_height = 200;

	Vec2f bottom_center(width * 0.5f, height * 0.5f + chat_height * 0.5f);

	SetChatLayout(bottom_center + Vec2f(-chat_halfwidth, -chat_height), bottom_center + Vec2f(chat_halfwidth, 0));
}

string getFullName(CPlayer@ player)
{
	string clantag = player.getClantag();
	return (clantag.size() > 0 ? clantag + " " : "") + player.getCharacterName();
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	SendChat(this, player.getNetworkID(), text_in);

	// stats
	Stats@ stats = getStats(player);
	if (stats !is null)
	{
		stats.chatCharactersCount += text_in.size();
	}

	return true;
}

//keep the chat hidden the rest of the time

void onEnterChat(CRules@ this)
{
	SetChatVisible(true);
}

void onExitChat(CRules@ this)
{
	SetChatVisible(false);
}
