#include "SoldierCommon.as"
#include "GameColours.as"

void onRender(CRules@ this)
{
	if (this.get_s16("in menu") > 0)
		return;

	CCamera@ camera = getCamera();
	const u32 time = getGameTime();

	CBlob@[] players;
	getBlobsByTag("player", @players);
	int alive = 0;
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ blob = players[i];
		Soldier::Data@ data = Soldier::getData(blob);
		SColor color = getBlobColor(blob);
		const bool myplayer = blob.isMyPlayer();
		const bool bot = blob.getBrain().isActive();
		const int createdTime = blob.getTickSinceCreated();
		CPlayer@ player = blob.getPlayer();
		CPlayer@ localplayer = getLocalPlayer();
		bool sameTeam = (localplayer !is null && localplayer.getTeamNum() == blob.getTeamNum());

		bool winning = false;
		if (player !is null)
		{
			s32 score = player.getScore();
			s32 topscore = 0;
			for (s32 i = 0; i < getPlayersCount(); i++)
			{
				topscore = Maths::Max(getPlayer(i).getScore(), topscore);
			}
			winning = (score > 0 && score == topscore);
		}
		SColor winflashcol = (createdTime % 16 >= 9 ? color : SColor(0xffffffff));
		const bool skirmish = this.gamemode_name == "Skirmish";

		u8 indicIcon = blob.get_u8("class");
		if (indicIcon > 5 || (myplayer && !bot))
		{
			indicIcon = 5;
		}
		if (winning && skirmish)
		{
			indicIcon = 6;
			//color = winflashcol;
		}
		if (blob.hasTag("dead") && (!myplayer || bot))
		{
			indicIcon = 7;
		}

		if (skirmish)
		{
			// warmup

			bool warmupIndicator = false;
			if (this.isWarmup() && (data.fire || data.fire2 || data.jump || data.crouch))
			{
				Vec2f player_pos = getDriver().getScreenPosFromWorldPos(data.pos + Vec2f(0, -23));
				GUI::DrawIcon("Sprites/HoverIcons.png", indicIcon, Vec2f(16, 16),
				              player_pos - Vec2f(16, 24)*camera.targetDistance * 2.0f, camera.targetDistance * 2.0f,
				              color);
				warmupIndicator = true;
			}

			// regular
			// HACK:
			if (!warmupIndicator && getScreenFlashAlpha() == 0 && !this.isGameOver()
			        && (sameTeam || (data.camoMode == 0 && (this.isWarmup() || !blob.hasTag("crouching"))))
			   )
			{
				const int controlIndex = blob.getMyPlayerIndex();
				if (!blob.isChatBubbleVisible()) // TODO: move down/up possibly?
				{
					Vec2f player_pos = getDriver().getScreenPosFromWorldPos(data.pos
					                   + Vec2f(0, -23 + (myplayer ? Maths::Sin(0.5f * time) * 4.0f : 0.0f)));
					GUI::DrawIcon("Sprites/HoverIcons.png", indicIcon, Vec2f(16, 16),
					              player_pos - Vec2f(16, 16)*camera.targetDistance, camera.targetDistance,
					              color);
				}
			}
		}
		else
		{
			if (myplayer)
			{
				Vec2f player_pos = getDriver().getScreenPosFromWorldPos(data.pos
				                   + Vec2f(0, -23 + (myplayer ? Maths::Sin(0.5f * time) * 4.0f : 0.0f)));
				GUI::DrawIcon("Sprites/HoverIcons.png", indicIcon, Vec2f(16, 16),
				              player_pos - Vec2f(16, 16)*camera.targetDistance, camera.targetDistance,
				              color);
			}
		}

		// new circle

		const int showTime = 110;
		if (data.local && !bot && ((createdTime / 8) % 2) == 0 && createdTime < showTime)
		{
			GUI::DrawCircle(blob.getScreenPos(), Maths::Max(12, Maths::Sqrt((showTime - createdTime)) * 6), color);
		}

		// heal circle

		if (data.healTime > 0)
		{
			if (((time / 5) % 5) > 0)
			{
				GUI::DrawIcon("Sprites/heal_indicator.png", 0, Vec2f(32, 32),
				              blob.getScreenPos() - Vec2f(32, 32)*camera.targetDistance, camera.targetDistance,
				              color_white);
			}
		}

		// leader/name indicator

		if (createdTime < showTime)
		{
			GUI::SetFont("intro");
			Vec2f pos = blob.getScreenPos() + Vec2f(0, 12 + Maths::Sin(0.5f * time) * 2.5f);
			if (winning && createdTime % 46 < 23)
			{
				GUI::DrawTextCentered("LEADER", pos, winflashcol);
			}
			else if (player !is null && (!skirmish || (skirmish && !getNet().isServer())))
			{
				GUI::DrawTextCentered(player.getCharacterName(), pos, color);
			}
		}
	}
}
