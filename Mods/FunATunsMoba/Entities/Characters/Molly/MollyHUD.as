//archer HUD

#include "/Entities/Common/GUI/ActorHUDStartPos.as";

const string iconsFilename = "Entities/Characters/Builder/BuilderIcons.png";
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
		if (this.isAttached() && this.isAttachedToPoint("GUNNER"))
		{
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-32, -32));
		}
		else
		{
			getHUD().SetCursorImage("Entities/Characters/Builder/BuilderCursor.png");
		}

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

	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD(blob, tl);
	
	if(blob.get_u32("SawCD") < 1)
		{
			GUI::DrawIcon( "StatusEffects.png", 8, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-3)*32, -40), 0.5f);
		}
		else
		{
			GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-3)*32, -40), 0.5f);
		}
	
		if(blob.get_u32("ChickenCD") < 1)
		{
			GUI::DrawIcon( "StatusEffects.png", 9, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-4)*32, -40), 0.5f);
		}	
		else
		{
			GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-4)*32, -40), 0.5f);
		}
		
		if(blob.get_u32("select") == 0)
		{
			GUI::DrawIcon( "MenuItems.png", 5, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-3)*32, -65), 0.5f);
		}	
		else if (blob.get_u32("select") == 1)
		{
			GUI::DrawIcon( "MenuItems.png", 5, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-4)*32, -65), 0.5f);
		}

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw class icon

	GUI::DrawIcon(iconsFilename, 3, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 32, -13), 1.0f);
}
