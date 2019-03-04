#include "SSKStatusCommon.as"

//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "ActorHUDStartPos.as";

void renderBackBar(Vec2f origin, f32 width, f32 scale)
{
    for (f32 step = 0.0f; step < width / scale - 64; step += 64.0f * scale)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(step * scale, 0), scale);
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(width - 128 * scale, 0), scale);
}

void renderFrontStone(Vec2f farside, f32 width, f32 scale)
{
    for (f32 step = 0.0f; step < width / scale - 16.0f * scale * 2; step += 16.0f * scale * 2)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-step * scale - 32 * scale, 0), scale);
    }

    if (width > 16)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-width, 0), scale);
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), farside + Vec2f(-width - 32 * scale, 0), scale);
    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), farside, scale);
}

void renderDamageStatus( CBlob@ blob, Vec2f origin)
{
    SSKStatusVars@ statusVars;
    if (!blob.get("statusVars", @statusVars))
    {
        return;
    }

    f32 damageStatus = statusVars.damageStatus;
    
    f32 fractionHealth = damageStatus/1000.0f;
    int hue = 255 - 255 * fractionHealth^2;

    SColor col =  SColor(255, 255, hue, hue);
    GUI::DrawText(""+Maths::Round(damageStatus)+"%", origin + Vec2f(16,24), col);
}

void onInit(CSprite@ this)
{
    this.getCurrentScript().runFlags |= Script::tick_myplayer;
    this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
    if (g_videorecording)
        return;

    CBlob@ blob = this.getBlob();
    Vec2f dim = Vec2f(402, 64);
    Vec2f ul(HUD_X - dim.x / 2.0f, HUD_Y - dim.y + 12);
    Vec2f lr(ul.x + dim.x, ul.y + dim.y);
    //GUI::DrawPane(ul, lr);
    renderBackBar(ul, dim.x, 1.0f);
    u8 bar_width_in_slots = blob.get_u8("gui_HUD_slots_width");
    f32 width = bar_width_in_slots * 40.0f;
    renderFrontStone(ul + Vec2f(dim.x + 40, 0), width, 1.0f);
    renderDamageStatus(blob, ul);
    //GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(128,32), topLeft);
}

