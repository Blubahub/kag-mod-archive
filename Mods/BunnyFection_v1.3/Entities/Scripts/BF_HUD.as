//archer HUD

#include "/Entities/Common/GUI/ActorHUDStartPos.as";

const string iconsFilename = "Entities/Characters/Builder/BuilderIcons.png";
const int slotsSize = 6;

void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors( CBlob@ this )
{
	CHUD@ HUD = getHUD();
	// set cursor
	if (HUD.hasButtons())
		HUD.SetDefaultCursor();
	else if ( this.getName() == "bf_bunny" )
	{
		HUD.SetCursorImage("BF_CursorBunny.png",Vec2f(12,12));
		HUD.SetCursorOffset(Vec2f(-12, -12));
		
		CBlob@ carried = this.getCarriedBlob();
		if (carried !is null && ( carried.hasTag("block") || carried.hasTag("turret") ) )
			HUD.SetCursorFrame(1);
		else
			HUD.SetCursorFrame(0);
	}
	else
	{
		HUD.SetCursorImage("BF_CursorMutant.png",Vec2f(12,12));
		HUD.SetCursorOffset( Vec2f(-12, -12) );
	}
}

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

    CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();

	ManageCursors( blob );
											
	// draw inventory

    Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
    DrawInventoryOnHUD( blob, tl );

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD( blob, coins, tl, slotsSize-2 );

	// draw class icon 

    GUI::DrawIcon(iconsFilename, 3, Vec2f(16,32), tl+Vec2f(8 + (slotsSize-1)*32,-13), 1.0f);
}
