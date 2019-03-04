#define CLIENT_ONLY

#include "DrawScores.as"
#include "Menus.as"
#include "Timers.as"
#include "GamemodeCommon.as"
#include "SoldierCommon.as"
#include "GameColours.as"
#include "UI.as"

const string _hud_file = "Sprites/UI/hud_parts.png";

void onRender(CRules@ this)
{
	if (this.hasTag("hide actor hud") || this.get_s16("in menu") > 0 || UI::hasAnyContent())
		return;

	CMap@ map = getMap();
	CPlayer@ player = getLocalPlayer();
	if (map is null || player is null)
		return;

	const u8 state = this.getCurrentState();

	/////////////////////////////////
	//actual rendering code
	/////////////////////////////////

	if (!isFreeBuild())
	{
		//coins HUD
		Vec2f coinshud_frame = Vec2f(80, 17);
		Vec2f coinshud_ul(getScreenWidth() / 2 + 140 - coinshud_frame.x * 0.5f, getScreenHeight() - coinshud_frame.y);

		DrawTRGuiFrame(coinshud_ul, coinshud_ul + coinshud_frame);
		{
			//draw coins
			GUI::SetFont("gui");
			GUI::DrawText("Coins: " + formatInt(player.getCoins(), "", 4), coinshud_ul + Vec2f(4, -2), Colours::WHITE);
		}
	}

	// player indicator

	CCamera@ camera = getCamera();
	const u32 time = getGameTime();

	CBlob@ blob = player.getBlob();
	if (blob is null)
	{
		return;
	}
	Soldier::Data@ data = Soldier::getData(blob);

	const bool myplayer = blob.isMyPlayer();
	const int controlIndex = blob.getMyPlayerIndex();
	if (!blob.isChatBubbleVisible())
	{
		Vec2f player_pos = getDriver().getScreenPosFromWorldPos(data.pos
		                   + Vec2f(0, -28 + (myplayer ? Maths::Sin(0.5f * time) * 2.5f : 0.0f)));
		const u8 our_class = 5;
		GUI::DrawIcon("Sprites/HoverIcons.png", our_class, Vec2f(16, 16),
		              player_pos - Vec2f(16, 16)*camera.targetDistance, camera.targetDistance,
		              color_white);
	}

	// player names

	GUI::SetFont("intro");
	CBlob@[] all;
	getBlobsByTag("player", @all);
	for (u32 i = 0 ; i < all.length; i++)
	{
		CBlob@ b = all[i];
		if (b.getPlayer() !is null)
		{
			Vec2f pos = Vec2f(b.getScreenPos().x, 227 + 12 + (i % 6) * 11);
			GUI::DrawTextCentered(b.getPlayer().getCharacterName(), pos, Colours::WHITE);
		}
	}
}
