//archer HUD

#include "/Entities/Common/GUI/ActorHUDStartPos_HD.as";

const string iconsFilename = "../Mods/KagHD(WiP)/Entities/Characters/Builder/BuilderIcons.png";
const int slotsSize = 6;

void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors( CBlob@ this )
{
	// set cursor
	if (getHUD().hasButtons()) {
		getHUD().SetDefaultCursor();
	}
	else {
		if (this.isAttached() && this.isAttachedToPoint("GUNNER")) {
			getHUD().SetCursorImage("../Mods/KagHD/Entities/Characters/Archer/ArcherCursor.png", Vec2f(32,32));
			getHUD().SetCursorOffset( Vec2f(-32, -32) );
		}
		else {
			getHUD().SetCursorImage("../Mods/KagHD/Entities/Characters/Builder/BuilderCursor.png");
		}

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
    DrawInventoryOnHUD( blob, tl);

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD( blob, coins, tl, slotsSize-2 );

	// draw class icon 

    GUI::DrawIcon(iconsFilename, 3, Vec2f(32,64), tl+Vec2f(16 + (slotsSize-1)*32,-16), 0.5f);
}

