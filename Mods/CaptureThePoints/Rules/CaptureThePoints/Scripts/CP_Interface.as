#include "CP_Structs.as";


void onRender( CRules@ Rule )
{	
    CPlayer@ p = getLocalPlayer();

    if (p is null || !p.isMyPlayer()) { return; }
	
	const string gui_image_fname = "Rules/CP/CPGui.png";
	const string gui_numbers = "Rules/CP/CP_numbers.png";
	Vec2f topLeft = Vec2f(8,8);
	
	GUI::DrawIcon(gui_image_fname, 0, Vec2f(60,48), topLeft, 1.0f, 0);
	GUI::DrawIcon(gui_image_fname, 1, Vec2f(60,48), topLeft + Vec2f(120,0), 1.0f, 1);
	
	s32 BlueScore = Rule.get_s32("Team_Score"+0);
	s32 RedScrore = Rule.get_s32("Team_Score"+1);
	
	Vec2f Numbers_pos = Vec2f(25,0);
	Vec2f BlueS_pos = Vec2f(60, 53), RedS_pos = Vec2f(164, 53);
	if(BlueScore > 99){ BlueS_pos = Vec2f(84, 53);}
	if(RedScrore > 99){ RedS_pos = Vec2f(189, 53);}
	if( (BlueScore < 100) && (BlueScore > 9) ){ BlueS_pos = Vec2f(73, 53);}
	if( (RedScrore < 100) && (RedScrore > 9) ){ RedS_pos = Vec2f(177, 53);}
	
	if(BlueScore > 0)
	{
		for(u8 i=0; BlueScore != 0; i++)
		{
			GUI::DrawIcon(gui_numbers, BlueScore%10, Vec2f(16,16), BlueS_pos - (Numbers_pos*i), 1.0f);
			BlueScore/=10;
		}
	}
	else{
		GUI::DrawIcon(gui_numbers, 0, Vec2f(16,16), BlueS_pos, 1.0f);
	}
	if(RedScrore > 0)
	{
		for(u8 i=0; RedScrore != 0; i++)
		{
			GUI::DrawIcon(gui_numbers, RedScrore%10, Vec2f(16,16), RedS_pos - (Numbers_pos*i), 1.0f);
			RedScrore/=10;
		}
	}
	else{
		GUI::DrawIcon(gui_numbers, 0, Vec2f(16,16), RedS_pos, 1.0f);
	}
	
	Vec2f PointsLine = Vec2f(8, 100);
	Vec2f chain_pos = Vec2f(43 ,0);
	Vec2f point_pos = Vec2f(18 ,0);
	u8 Points_Count = Rule.get_u8("Points_Count");
	
	GUI::DrawIcon(gui_image_fname, 15, Vec2f(32,32), PointsLine, 1.0f, Rule.get_u8("Team_Point"+0));
	
	for(u8 i = 1; i < Points_Count; i++)
	{
		PointsLine += chain_pos;	
		GUI::DrawIcon(gui_image_fname, 11, Vec2f(32,32), PointsLine, 1.0f);
		
		PointsLine += point_pos;
		GUI::DrawIcon(gui_image_fname, 15, Vec2f(32,32), PointsLine, 1.0f, Rule.get_u8("Team_Point"+i));
	}

    string propname = "cp spawn time "+p.getUsername();	
    if (p.getBlob() is null && Rule.exists(propname) )
    {
        u8 spawn = Rule.get_u8(propname);

        if (spawn != 255)
        {
			GUI::DrawText( "                                        Respawn in: "+spawn+"\n(to change spawn point or class goto: menu->Change Team)" , Vec2f( getScreenWidth()/2 - 200, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
        }
    }
}
