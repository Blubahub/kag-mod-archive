//archer HUD

#include "NecromancerCommon.as";
#include "nActorHUDStartPos.as";

const string iconsFilename = "SpellIcons.png";
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
		getHUD().SetCursorImage("NecromancerCursor.png", Vec2f(32,32));
		getHUD().SetCursorOffset( Vec2f(-32, -32) );
		// frame set in logic
	}
}

void DrawManaBar(CBlob@ this, Vec2f origin)
{
	NecromancerInfo@ necro;
    if (!this.get( "necromancerInfo", @necro )) {
        return;
    }
    string manaFile = "GUI/ManaBar.png";
    int segmentWidth = 24;
    GUI::DrawIcon("GUI/jends.png", 0, Vec2f(8,16), origin+Vec2f(-8,0));
    int MANA = 0;
    s32 maxMana = necro.maxMana;
    s32 mana = necro.mana;
    for (f32 step = 0.0f; step < maxMana; step += 5.0f)
    {
        GUI::DrawIcon("GUI/ManaBack.png", 0, Vec2f(12,16), origin+Vec2f(segmentWidth*MANA,0));
        f32 thisMANA = mana - step;
        if (thisMANA > 0)
        {
            Vec2f manapos = origin+Vec2f(segmentWidth*MANA-1,0);
            if (thisMANA <= 1.0f) { GUI::DrawIcon(manaFile, 4, Vec2f(16,16), manapos); }
            else if (thisMANA <= 2.5f) { GUI::DrawIcon(manaFile, 3, Vec2f(16,16), manapos); }
            else if (thisMANA <= 4.5f) { GUI::DrawIcon(manaFile, 2, Vec2f(16,16), manapos); }
            else if (thisMANA > 4.5f) { GUI::DrawIcon(manaFile, 1, Vec2f(16,16), manapos); }
            else { GUI::DrawIcon(manaFile, 0, Vec2f(16,16), manapos); }
        }
        MANA++;
    }
    GUI::DrawIcon("GUI/jends.png", 1, Vec2f(8,16), origin+Vec2f(segmentWidth*MANA,0));
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
	DrawInventoryOnHUD( blob, tl, Vec2f(0,58));

	// draw coins
	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD( blob, coins, tl, slotsSize-2 );

	DrawManaBar(blob, Vec2f(52,64));

	// class weapon icon
	NecromancerInfo@ necro;
    if (!blob.get( "necromancerInfo", @necro )) {
        return;
    }
	GUI::DrawIcon( iconsFilename, necro.primarySpellID, Vec2f(16,16), Vec2f(10,10));
	GUI::DrawIcon("GUI/jslot.png", 1, Vec2f(32,32), Vec2f(2,56));
	GUI::DrawIcon( iconsFilename, necro.secondarySpellID, Vec2f(16,16), Vec2f(10,66));
}
