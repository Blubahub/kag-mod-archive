void onTick(CRules@ this)
{
	if(getNet().isClient())
	{
		if((getGameTime() + 1) % getTicksASecond() == 0 && !this.exists("start info"))
		{
			this.set_bool("start info", true);
            ShowInfo();
		}
	}
}

void ShowInfo()
{
    SColor col = SColor(255, 255, 0, 0);
    client_AddToChat("== Welcome to Bananaman's Sandbox ==", col);
    client_AddToChat("* No spamming/greifing.", col);
    client_AddToChat("* No killing others without consent.", col);
    client_AddToChat("* Respect the admins.", col);
    client_AddToChat("Type !rules to show this text or !newstuff to see what's been added.", col);
}

void ShowNewStuff()
{
    SColor col = SColor(255, 255, 0, 0);
    client_AddToChat("== What's been added ==", col);
    client_AddToChat("* !dirt - Places a dirt block (useful for making floating structures).", col);
    client_AddToChat("* !morph - Used to switch classes.", col);
    client_AddToChat("* !clear - Clear inventory.", col);
    client_AddToChat("* Megadrill - Breaks blocks very fast and doesn't overheat.", col);
    client_AddToChat("* Chimer - Wiring device that plays a note when powered (can be tuned).", col);
    client_AddToChat("* Spam filter - Helps to reduce chat spam.", col);
    client_AddToChat("* Dirt block - Can now be placed from builder menu.", col);
    client_AddToChat("* Banana - Fun for all the family.", col);
}

void ShowAdminFeatures()
{
    SColor col = SColor(255, 255, 0, 0);
    client_AddToChat("== Admin Features ==", col);
    client_AddToChat("* !tp - Teleport to cursor position.", col);
    client_AddToChat("* !tp [PLAYERNAME] - Teleport to player.", col);
    client_AddToChat("* !tp [PLAYER1NAME] [PLAYER2NAME] - Teleport player to player.", col);
    client_AddToChat("* Spam filter does not apply.", col);
    client_AddToChat("* Can morph into any blob (using !morph).", col);
    client_AddToChat("* Can use disabled commands.", col);
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!rules")
	{
		if(player.isMyPlayer())
		{
			ShowInfo();
		}
	}
	else if (text_in == "!newstuff")
	{
		if(player.isMyPlayer())
		{
			ShowNewStuff();
		}
	}
	else if (text_in == "!adminfeatures")
	{
		if(player.isMyPlayer() && player.isMod())
		{
			ShowAdminFeatures();
			return false;
		}
	}

	return true;
}
