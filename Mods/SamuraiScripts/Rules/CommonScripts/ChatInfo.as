// Call these to show mod info in the chat window

const SColor titleColor = SColor(160, 160, 0, 0);
const SColor msgColor = SColor(255, 255, 0, 0);

void ShowRules()
{
    client_AddToChat("== Welcome to Terracrafts Samurai's Sandbox ==", titleColor);
    client_AddToChat("* No spamming/greifing.", msgColor);
    client_AddToChat("* No killing others without consent(reason).", msgColor);
    client_AddToChat("* Respect the admins and thiers word is FINAL.", msgColor);
	client_AddToChat("* Have a nice Stay.", msgColor);
	client_AddToChat("* NO 18+ JOKES.", msgColor);
    client_AddToChat("Type !rules to show this text or !newstuff to see what's been added.", msgColor);
}

void ShowNewStuff()
{
    client_AddToChat("== What's been added ==", titleColor);
    client_AddToChat("* !dirt - Places a dirt block (useful for making floating structures).", msgColor);
    client_AddToChat("* !morph - Used to switch classes.", msgColor);
    client_AddToChat("* !clear - Clear inventory.", msgColor);
    client_AddToChat("* Megadrill - Breaks blocks very fast and doesn't overheat.", msgColor);
    client_AddToChat("* Chimer - Wiring device that plays a note when powered (can be tuned).", msgColor);
    client_AddToChat("* Spam filter - Helps to reduce chat spam.", msgColor);
    client_AddToChat("* Dirt block - Can now be placed from builder menu.", msgColor);
    client_AddToChat("* Banana - Fun for all the family.", msgColor);
    client_AddToChat("* Builder - Bigger inventory.", msgColor);
    client_AddToChat("* Gramophones - Play music (!musicdisc for records. Thanks to TFlippy for modding).", msgColor);
    client_AddToChat("* Flag - Dummy flag for castles and stuff.", msgColor);
}

void ShowAdminFeatures()
{
    client_AddToChat("== Admin Features ==", titleColor);
    client_AddToChat("* !tp - Teleport to cursor position.", msgColor);
    client_AddToChat("* !tp [PLAYERNAME] - Teleport to player.", msgColor);
    client_AddToChat("* !tp [PLAYER1NAME] [PLAYER2NAME] - Teleport player to player.", msgColor);
    client_AddToChat("* !kill - Kill blobs at aim position.", msgColor);
    client_AddToChat("* Can use disabled commands.", msgColor);
}

void ShowSuperAdminFeatures()
{
    client_AddToChat("== Super Admin Features ==", titleColor);
    client_AddToChat("* Spam filter does not apply.", msgColor);
    client_AddToChat("* Can morph into any blob (using !morph).", msgColor);
}
