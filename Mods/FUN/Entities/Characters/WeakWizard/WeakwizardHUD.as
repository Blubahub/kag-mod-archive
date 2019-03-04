//wizard HUD

#include "ActorHUDStartPos.as";
#include "WeakwizardCommon.as";

const string iconsFilename = "Entities/Characters/Wizard/OrbIcons.png";
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
	else
	{
		// set cursor 
		getHUD().SetCursorImage("WeakWizardCursor.png", Vec2f(32,32));
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
	double cooldownTeleportSecs = (diff / 30) * (-1);
	int cooldownTeleportFullSecs = diff % 30;
	double cooldownTeleportSecsHUD;
	if (cooldownTeleportFullSecs == 0 && cooldownTeleportSecs >= 0) cooldownTeleportSecsHUD = cooldownTeleportSecs;
	
	if (diff > 0)
	{
		GUI::DrawIcon( "LargeSmoke.png", 4, Vec2f(32,32), tl+Vec2f(6 + (slotsSize-1)*32, 0), 0.5f);
	}
	else
	{
		GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), tl+Vec2f(6 + (slotsSize-1)*32, -2), 0.5f);
		GUI::DrawText("" + cooldownTeleportSecs + " secs", tl+Vec2f((slotsSize-1)*32, 25), SColor(255, 255, 216, 0));
	}
	//orb icons
	u8 count = blob.get_u8("magic fire count");
	int orbsCount = (count - ORB_LIMIT) * (-1);
	
	u32 lastFireTime = blob.get_u32("last magic fire");
	int diffOrb = gametime - (lastFireTime + ORB_BURST_COOLDOWN);
	double cooldownOrbSecs = (diffOrb / 30) * (-1);
	int cooldownOrbFullSecs = diffOrb % 30;
	double cooldownOrbSecsHUD;
	if (cooldownOrbFullSecs == 0 && cooldownOrbSecs >= 0) cooldownOrbSecsHUD = cooldownOrbSecs;
	
	const u8 type = getOrbType( blob );
	
	f32 r = ORB_LIMIT/5*8;
	Vec2f delta(-r*Maths::Sin(6.283f/ORB_LIMIT), -r*Maths::Cos(6.283f/ORB_LIMIT));
	
	u8 orb_frame = type;

	if(count == ORB_LIMIT)
	{
		GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), tl+Vec2f(5 + (slotsSize-3)*32, -2), 0.5f);
		GUI::DrawText("" + cooldownOrbSecs + " secs", tl+delta+Vec2f(5 + (slotsSize-3)*32, 25), SColor(255, 255, 216, 0));
	}
	else
	{
		if (type == OrbType::normal) 
		{
			orb_frame = OrbType::normal;
			GUI::DrawIcon( "Orbs.png", 0, Vec2f(9,9), tl+delta+Vec2f(21 + (slotsSize-3)*32, 7), 1.0f, 1);
		}
		else if (type == OrbType::water)
		{
			orb_frame = 3;
			GUI::DrawIcon( "Orbs.png", 12, Vec2f(9,9), tl+delta+Vec2f(21 + (slotsSize-3)*32, 7), 1.0f, 1);
		} 
		GUI::DrawText("" + orbsCount + " orbs", tl+delta+Vec2f(5 + (slotsSize-3)*32, 25), SColor(255, 255, 216, 0));
	}
	
	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD( blob, coins, tl, slotsSize+1 );
	
	DrawInventoryOnHUD( blob, tl );
	
	

	GUI::DrawIcon( iconsFilename, orb_frame, Vec2f(16,16), tl+Vec2f(8 + (slotsSize+2)*32,0), 1.0f);
	
	
	
}
