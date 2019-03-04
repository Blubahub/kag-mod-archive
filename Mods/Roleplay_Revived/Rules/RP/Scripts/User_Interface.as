#include "CTF_Structs.as";

void onInit(CRules@ this)
{
}

void onRender(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }
	if(this.get_u8("1 2") == 0)
		GUI::DrawText("Team 1 is at WAR with team 2", Vec2f(20,40), SColor(255,200,80,80));
	else if(this.get_u8("1 2") == 1)
		GUI::DrawText("Team 1 is neutral with team 2", Vec2f(20,40), SColor(255,200,80,80));
	else if(this.get_u8("1 2") == 2)
		GUI::DrawText("Team 1 is friends with team 2", Vec2f(20,40), SColor(255,200,80,80));

	string propname = "Sandbox spawn time " + p.getUsername();
	if (p.getBlob() is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (spawn != 255)
		{
			GUI::SetFont("menu");
			GUI::DrawText(getTranslatedString("Respawning in: {SEC}").replace("{SEC}", "" + spawn), Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
		}
	}
}
