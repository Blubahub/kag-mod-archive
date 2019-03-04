#include "ShopCommon.as"

Vec2f sprites_offset(-24, 0);

CSpriteLayer@ AddShopOwner(CSprite@ this, const int frameOffset, Vec2f spriteOffset = Vec2f(16, -8))
{
	return addBlockTile(this, frameOffset, spriteOffset);
}

CSpriteLayer@ addBlockTile(CSprite@ this, u8 tile, Vec2f pos)
{
	CSpriteLayer@ block = this.addSpriteLayer("block" + this.getSpriteLayerCount(), "Sprites/shops.png", 8, 8, 0, 0);
	if (block !is null)
	{
		block.SetOffset(sprites_offset + pos);
		block.SetFrameIndex(tile);
	}
	return block;
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	const u8 type = getShopType(blob);

	if (type == BAR_VIP || type == BAR)
	{
		const bool vip = type == BAR_VIP;
		for (u32 i = 1; i < (type == BAR_VIP ? 5 : 6); i++)
		{
			u32 f = (((i + 2) % 3) == 0) ? 1 : 0;
			addBlockTile(this, f, Vec2f(i * 8, 0));

			bool is_beer = (i == (vip ? 3 : 4));
			bool is_wine = (i == 1);
			if (is_beer || is_wine)
			{
				addBlockTile(this, is_beer ? 6 : 7, Vec2f(i * 8 + (is_beer ? 4 : -4), -8));
			}
		}

		//bartender and anims
		if (type == BAR_VIP)
		{
			AddShopOwner(this, 9);
		}
		else
		{
			AddShopOwner(this, 8);
		}

		// neon
		CSpriteLayer@ neon = this.addSpriteLayer("neon", "Sprites/shops.png", 32, 8, 0, 0);
		if (neon !is null)
		{
			neon.SetOffset(sprites_offset + Vec2f(16, -20));
			neon.SetRelativeZ(-20);
			{
				Animation@ anim = neon.addAnimation("default", 6, true);
				int[] frames =
				{
					6, 7, 8, 9,
					4, 5, 4, 5, 4, 5,
					6, 7, 6, 8, 6, 9, 6,
					4, 5, 4, 5
				};
				for (u32 i = 0; i < frames.length; i++)
				{
					if (vip)
						frames[i] += 12 + 6;
					else
						frames[i] += 12;
				}
				u32 vip_frame_offset = (vip ? 9 : 0);
				while (vip_frame_offset-- > 0)
				{
					frames.push_back(frames[0]); frames.removeAt(0);
				}
				anim.AddFrames(frames);
			}
		}
	}
	else if (type == COFFEE_SHOP)
	{
		this.SetFrameIndex(4);

		AddShopOwner(this, 2, Vec2f(1 * 8, 0));
		AddShopOwner(this, 0, Vec2f(2 * 8, 0));
		AddShopOwner(this, 1, Vec2f(3 * 8, 0));
		AddShopOwner(this, 2, Vec2f(4 * 8, 0));
		AddShopOwner(this, 3, Vec2f(5 * 8, 0));

		AddShopOwner(this, 16, Vec2f(3 * 8, -8));
		//coffee machine
		addBlockTile(this, 17, Vec2f(2 * 8, -8));
		//grinder
		addBlockTile(this, 24, Vec2f(4 * 8, -8));
		//table number
		addBlockTile(this, 25, Vec2f(1 * 8, -8));
		//umbrella
		addBlockTile(this, 26, Vec2f(3 * 8 + 2, -16));
		addBlockTile(this, 27, Vec2f(2 * 8 + 2, -16));
	}
	else
	{
		for (u32 i = 1; i < 6; i++)
		{
			addBlockTile(this, 0, Vec2f(i * 8, 0));
		}

		if (type == SKIN_SHOP)
		{
			AddShopOwner(this, 10);

			addBlockTile(this, 12, Vec2f(1 * 8, -8));
			addBlockTile(this, 13, Vec2f(0 * 8, -8));

			addBlockTile(this, 15, Vec2f(5 * 8 - 2, -8));
			addBlockTile(this, 14, Vec2f(3 * 8 + 4, -8));
		}
		else if (type == PET_SHOP)
		{
			AddShopOwner(this, 11);

			addBlockTile(this, 20, Vec2f(5 * 8, -8));
			addBlockTile(this, 21, Vec2f(4 * 8, -8));

			addBlockTile(this, 20, Vec2f(5 * 8, -16));
			addBlockTile(this, 21, Vec2f(4 * 8, -16));

			addBlockTile(this, 22, Vec2f(1 * 8, -16));
			addBlockTile(this, 23, Vec2f(0 * 8, -16));
			addBlockTile(this, 30, Vec2f(1 * 8, -8));
			addBlockTile(this, 31, Vec2f(0 * 8, -8));
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob@ b = this.getBlob();
	if (b is null) return;

	//bartender
	const u32 leaderboardShowtime = Leaderboard::getLeaderboardTime();
	if (leaderboardShowtime > 0 && ((getGameTime() - leaderboardShowtime) == LEADERBOARD_TIME + 1
	                                || getControls().isKeyPressed(getControls().getActionKeyKey(AK_ACTION2))
	                                || getControls().isKeyPressed(getControls().getActionKeyKey(AK_MOVE_UP))
	                                || getControls().isKeyPressed(getControls().getActionKeyKey(AK_MOVE_DOWN))
	                               )
	   )
	{
		Leaderboard::SetCurrentLeaderboard(0, "");
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	GUI::SetFont("gui");

	//drinking leaderboards

	const u32 leaderboardShowtime = Leaderboard::getLeaderboardTime();
	if (leaderboardShowtime > 0 && getGameTime() - leaderboardShowtime < LEADERBOARD_TIME)
	{
		CRules@ rules = getRules();
		Leaderboard::Data@ lb;
		rules.get(Leaderboard::getLeaderboardName(), @lb);
		if (lb is null)
			return;

		uint player_count = Maths::Min(lb.scores.length, 10);
		float per_line_offset = 1.25f;

		float camera_scaling = getCamera().targetDistance;
		float pixel_scale = camera_scaling * 2.0f;
		int score_cap = 20;

		Vec2f upperleft = Vec2f(getScreenWidth() / 2 - ((score_cap + 1) / 2) * 16.0f * pixel_scale,
		                        getScreenHeight() / 3 + (-player_count / 3) * 16.0f * pixel_scale);

		Vec2f totalsize = Vec2f(score_cap + 1, (1 + player_count) * per_line_offset) * 16.0f * pixel_scale;


		//background frame
		GUI::DrawRectangle(upperleft - Vec2f(18, 10), upperleft + totalsize + Vec2f(18, 10), Colours::BLACK);
		GUI::DrawRectangle(upperleft - Vec2f(17, 9), upperleft + totalsize + Vec2f(17, 9), Colours::PURPLE);
		GUI::DrawRectangle(upperleft - Vec2f(16, 8), upperleft + totalsize + Vec2f(16, 8), Colours::BLACK);

		float draw_scale = 0.5f;

		//title
		GUI::DrawText(lb.boardname, upperleft + Vec2f(totalsize.x / 2 - 80 * draw_scale, 0), color_white);


		//draw bottles
		for (uint i = 0; i < player_count; i++)
		{
			Leaderboard::Score score = lb.scores[i];
			Vec2f local_upperleft = upperleft + Vec2f(0, -8.0f + (i + 1) * per_line_offset * 16.0f * pixel_scale);
			GUI::DrawText(score.name, local_upperleft + Vec2f(0.0f, 0.0f), color_white);
			GUI::DrawText("" + score.score, local_upperleft + Vec2f(totalsize.x - 30.0f, 0.0f), color_white);
		}
	}

	//above is shown while we're in a menu

	if (getRules().get_s16("in menu") > 0)
		return;

	// help msg

	//TODO; consider delaying this right after you've interacted
	CBlob@ playerblob = getLocalPlayerBlob();

	if (playerblob !is null && (playerblob.getPosition() - blob.getPosition()).getLength() < 20)
	{
		Vec2f help_offset(-16.0f, 84);
		Vec2f screenpos(blob.getScreenPos().x + help_offset.x, help_offset.y);

		string text = "[" + getControls().getActionKeyKeyName(AK_ACTION1) + "] talk to " +	blob.get_string("owner name");

		Vec2f dim;
		GUI::GetTextDimensions(text, dim);

		DrawTRGuiFrame(screenpos - dim * 0.5f - Vec2f(8, 0), screenpos + dim * 0.5f + Vec2f(8, 8));
		GUI::DrawTextCentered(text, screenpos, Colours::WHITE);
	}

}

