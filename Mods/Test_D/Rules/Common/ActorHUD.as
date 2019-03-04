#define CLIENT_ONLY

#include "RulesCommon.as"
#include "GameColours.as"
#include "SoldierCommon.as"

//////////////////////////////////////////////
//
//	Actor HUD
//
//		Shows HP, Ammo Ammounts and so on
//		for actors.
//
//		Can be turned off when required by
//		tagging rules with "hide actor hud".
//
//////////////////////////////////////////////

void onRender(CRules@ this)
{
	/////////////////////////////////
	//globally accessible switch
	// + other early-exit conditions
	/////////////////////////////////
	if (this.hasTag("hide actor hud"))
		return;

	CMap@ map = getMap();
	if (map is null)
		return;
	if (hasMenus(this))
		return;

	/////////////////////////////////
	//gather any needed info
	/////////////////////////////////

	CBlob@ playerblob = getLocalPlayerBlob();
	Soldier::Data@ sol_data = null;
	if (playerblob !is null)
		@sol_data = Soldier::getData(playerblob);

	/////////////////////////////////
	//actual rendering code
	/////////////////////////////////
	const string hud_file = "Sprites/UI/hud_parts.png";
	{
		//lower hud
		Vec2f lower_hud_frame = Vec2f(170, 17);
		Vec2f lower_hud_ul(getScreenWidth() / 2 - lower_hud_frame.x * 0.5f, getScreenHeight() - lower_hud_frame.y);
		{
			//draw background
			GUI::DrawIcon(_hud_file, 0, lower_hud_frame, lower_hud_ul, 0.5f);
		}
		{
			//draw hearts
			s32 hp = 0;
			if (playerblob !is null)
				hp = playerblob.getHealth();

			for (int i = 0; i < 3; i++)
			{
				Vec2f framesize(16, 16);
				Vec2f framepos = lower_hud_ul + Vec2f(lower_hud_frame.x * 2 - 32 * (-i + 4), 0) * 0.5f;
				GUI::DrawIcon(hud_file, (hp > i ? 11 : 12), framesize, framepos, 0.5f);
			}
		}
		{
			//draw ammo

			//TODO: per-class action
			//		icons

			u32 ammo = 0;
			u32 ammo_max = 0;
			u32 nades = 0;
			u32 nades_max = 0;

			if (sol_data !is null)
			{
				ammo = sol_data.ammo;
				ammo_max = sol_data.initialAmmo;
				nades = sol_data.grenades;
				nades_max = sol_data.initialGrenades;
			}

			GUI::SetFont("hud");
			if (ammo_max != 0)
			{
				GUI::DrawText("AMMO: " + ammo + " | " + ammo_max,
				              lower_hud_ul + Vec2f(8, 0),
				              color_white);
			}
			if (nades_max != 0)
			{
				GUI::DrawText("Nades: " + nades + " | " + nades_max,
				              lower_hud_ul + Vec2f(56, 0),
				              color_white);
			}
		}
	}
}
