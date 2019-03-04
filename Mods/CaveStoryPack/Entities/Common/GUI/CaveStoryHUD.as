//common HUD
//why'd transhuman seperate the huds in the first place?

#include "ArcherCommon.as";
#include "CaveStoryGUI.as";

const int slotsSize = 6;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors(CBlob@ this)
{
	// set cursor
	if (getHUD().hasButtons())
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		// set cursor
		getHUD().SetCursorImage("Entities/Common/GUI/CommonCursor.png", Vec2f(32, 32));
		getHUD().SetCursorOffset(Vec2f(-32, -32));
		// frame set in logic
	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();

	ManageCursors(blob);

	// draw inventory
	Vec2f tl(40, 20);
	DrawInventoryOnHUD(blob, tl);

	const u8 type = getArrowType(blob);
	u8 iconFrame = 0;

	string iconsFilename = "Entities/Characters/Archer/ArcherIcons.png";
	string name = blob.getName();

	/*
	if (name == "archer")
	{
		iconsFilename = "Entities/Characters/Archer/ArcherIcons.png";
		if (type != ArrowType::normal)
		{
			iconFrame = type;
		}

	}
	else if (name == "builder")
	{
		iconsFilename = "Entities/Characters/Builder/BuilderIcons.png";
		iconFrame = 3;
	}
	else if (name == "knight")
	{
		iconsFilename = "Entities/Characters/Knight/KnightIcons.png";
		iconFrame = 1;
	}

	// class weapon icon
	GUI::DrawIcon(iconsFilename, iconFrame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 32, -16), 1.0f);
	*/

	// draw coins
	const int coins = player !is null ? player.getCoins() : 0;
	//DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);
	CaveStoryGUI::DrawNumber(coins, tl + Vec2f(64 + 190, 66));
}
