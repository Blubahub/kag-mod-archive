//wizard HUD

#include "ActorHUDStartPos.as";
#include "WizardCommon.as";

const string iconsFilename = "Entities/Characters/Archer/ArcherIcons.png";
const int slotsSize = 2;

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
	else
	{
		// set cursor 
		getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32,32));
		getHUD().SetCursorOffset( Vec2f(-32, -32) );
		getHUD().SetCursorFrame(0);
	}
}

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	const u32 gametime = getGameTime();

	ManageCursors( blob );

	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);

	//teleport icon
	u32 lastTeleport = blob.get_u32("last teleport");
	int diff = gametime - (lastTeleport + TELEPORT_FREQUENCY);
	if (diff > 0)
		GUI::DrawIcon( "LargeSmoke.png", 4, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-1)*32, 4), 0.5f);
	else
		GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-1)*32, 2), 0.5f);
	
	//orb icons
	u8 count = blob.get_u8("magic fire count");
	f32 r = ORB_LIMIT/5*8;
	
	if(count == ORB_LIMIT)
		GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), tl+Vec2f(8 + (slotsSize-2)*32, 2), 0.5f);
	else
	for(uint i = 0; i < ORB_LIMIT - count; i++){
		Vec2f delta(-r*Maths::Sin(6.283f*i/ORB_LIMIT), -r*Maths::Cos(6.283f*i/ORB_LIMIT));
		GUI::DrawIcon( "MagicOrb.png", 0, Vec2f(8,8), tl+delta+Vec2f(16 + (slotsSize-2)*32, 10), 1.0f, i);
	}
	
	
}
