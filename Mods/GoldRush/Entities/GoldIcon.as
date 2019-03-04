#include "GR_Common.as";

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob.getBlobCount("mat_gold") > gold_to_show_icon())
    {
        Vec2f pos2d = blob.getScreenPos();
        GUI::DrawIcon("Entities/Materials/MaterialIcons.png", 2 , Vec2f(16,16), pos2d, 2.0f, 0 );
    }   
}