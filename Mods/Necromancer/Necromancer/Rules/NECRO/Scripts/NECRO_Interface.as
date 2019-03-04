#include "NECRO_Structs.as";

void onInit( CRules@ this )
{
    CBitStream stream;
    stream.write_u16(0xDEAD); //check bits rewritten when theres something useful
    this.set_CBitStream("necro_serialised_team_hud", stream);
}

void onRender(CRules@ this)
{
    CPlayer@ p = getLocalPlayer();
    if (p is null || !p.isMyPlayer()) { return; }

    s16 survivorsTickets=this.get_s16("ticketsTeam0");
    if (survivorsTickets == 0)
    {
        GUI::DrawText( "No survivors remaining.", Vec2f(getScreenWidth()-200,10), SColor(0xffd5543f) );
    }
    else
    {
        GUI::DrawText( "Survivors remaining: "+survivorsTickets, Vec2f(getScreenWidth()-200,10), color_white );
    }

    if (this.get_bool("displayTicketsTeam1"))
    {
        s16 necromancerTickets=this.get_s16("ticketsTeam1");
        if (necromancerTickets>0)
            GUI::DrawText( "Necromancers remaining: "+necromancerTickets, Vec2f(getScreenWidth()-200,30), color_white );
    }

    string propname = "ctf spawn time "+p.getUsername();  
    if (p.getBlob() is null && this.exists(propname) )
    {
        u8 spawn = this.get_u8(propname);

        if (spawn != 255)
        {
            string spawn_message = "Respawn in: "+spawn;
            if(spawn >= 250)
            {
                spawn_message = "Respawn in: (approximately never)";
            }

            GUI::DrawText( spawn_message , Vec2f( getScreenWidth()/2 - 70, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
        }
    }
}