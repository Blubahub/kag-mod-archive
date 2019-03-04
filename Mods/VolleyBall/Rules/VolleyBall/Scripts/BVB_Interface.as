
#include "RulesCore.as";
#include "BVB_Structs.as";

void onRender(CRules@ this)
{	
	//if(!this.isIntermission())
	DrawGamePoints(this);
}

void onInit(CRules@ this)
{
	CBitStream stream;
	stream.write_u16(0xDEAD); //check bits rewritten when theres something useful
	this.set_CBitStream("bvb_serialised_team_queues", stream);
    this.Sync("bvb_serialized_team_queues", true);
}

void DrawGamePoints(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }	

	CMap@ map = getMap();
	f32 SMid = getScreenWidth()/2;

	const f32 scalex = getDriver().getResolutionScaleFactor();
	const f32 zoom = getCamera().targetDistance * scalex;

	CBitStream serialised_team_hud;
	this.get_CBitStream("bvb_serialised_team_hud", serialised_team_hud);

	if (serialised_team_hud.getBytesUsed() > 10)
	{
		serialised_team_hud.Reset();
		u16 check;

		if (serialised_team_hud.saferead_u16(check) && check == 0x5afe)
		{
			while (!serialised_team_hud.isBufferEnd())
			{
				BVB_HUD hud(serialised_team_hud);

				GUI::DrawIcon( "BVB_Gui.png", 1, Vec2f(48,16), Vec2f(SMid-48,2), 1.0f );

				int Bscore = hud.bluegoals;
				int Rscore = hud.redgoals;

				GUI::DrawIcon( "Numerical_Digits.png", Bscore, Vec2f(8,8), Vec2f(SMid-26,8), 1.0f );
				GUI::DrawIcon( "Numerical_Digits.png", Rscore, Vec2f(8,8), Vec2f(SMid+10,8), 1.0f );
			}
		}
		serialised_team_hud.Reset();
	}
}
