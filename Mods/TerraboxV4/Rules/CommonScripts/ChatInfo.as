// Call these to show mod info in the chat window

const SColor titleColor = SColor(160, 160, 0, 0);
const SColor msgColor = SColor(255, 255, 0, 0);

void ShowRules()
{
    client_AddToChat("== Welcome to Terracraft's Sandbox v5 ==", titleColor);
	client_AddToChat(" -- BY PLAYING IN THIS SERVER YOU WILL AGREE TO THEESE RULES --", msgColor);
	client_AddToChat(" 1. Grief/Abuse/Exploiting/Glitching/Spamming", msgColor);
	client_AddToChat(" 2. Do not kill Server Staff.", msgColor);
	client_AddToChat(" IS NOT PROHIBITED.", msgColor);
	client_AddToChat(" -- MODS ARE MADE BY THIER RESPECTIVE CREATORS --.", msgColor);
	client_AddToChat(" -- Have a Nice Stay! --.", msgColor);
    client_AddToChat(" Forums -- bit.ly/2sDIGo9 and Discord link in server description.-- ", msgColor);
}