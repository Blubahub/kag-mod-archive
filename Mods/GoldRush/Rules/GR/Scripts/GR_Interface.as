#define CLIENT_ONLY

#include "GR_Structs.as";
#include "GR_Common.as";

int blue_gold;
int red_gold;
int gold_needed;
int ch_off; //char offset
void onRender( CRules@ this )
{
    const string gui_image_fname = "Rules/Simple/GRGUI.png";

    Vec2f GUIPos = Vec2f(0,0);
    GUI::DrawIcon(gui_image_fname, GUIPos, 1.0f);
    string b = blue_gold; //RGB lol
    string r = red_gold;
    string g = gold_needed;
    ch_off = 4;
    if (this.isWarmup())
    {
        b = "-----";
        r = "-----";
        g = "-----";
        ch_off = 3;
    }
    GUI::DrawText("" + b, GUIPos + Vec2f(60 - (b.length * ch_off), 52), 0xffFFC64B);
    GUI::DrawText("" + r, GUIPos + Vec2f(248 - (r.length * ch_off), 52), 0xffFFC64B);
    GUI::DrawText("" + g, GUIPos + Vec2f((77*2) - (g.length * ch_off), 36*2), 0xffFFC64B);
    
    
    CPlayer@ p = getLocalPlayer();
    if (p !is null && p.isMyPlayer())
    {
        string propname = "gr spawn time "+p.getUsername();    
        if (p.getBlob() is null && this.exists(propname) )
        {
            u8 spawn = this.get_u8(propname);

            if (spawn != 255)
            {
                GUI::DrawText( "Respawn in: "+spawn , Vec2f( getScreenWidth()/2 - 70, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
            }
        }
    }
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
    if(cmd == this.getCommandID("send_gold"))
    {
        blue_gold = params.read_u32();
        red_gold = params.read_u32();   
    }
    if(cmd == this.getCommandID("get_gold_needed"))
        gold_needed = params.read_s32();
}

void onRestart( CRules@ this )
{
    blue_gold = 0;
    red_gold = 0;
}