//builder HUD

#include "HumanoidCommon.as";
#include "EquipCommon.as";

#include "GenericHUD.as";

void ManageCursors(CBlob@ this)
{
	getHUD().SetDefaultCursor();
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	if(getLocalPlayer() !is player)return;

	ManageCursors(blob);
	
	GUI::SetFont("menu");

	Vec2f HUD = CreateBaseHUD(this, blob, player);
	
	HUD = CreateBodyHUD(this, blob, player, HUD);
	
	HUD = CreateArmourHUD(this, blob, player, HUD);
	
	HUD = CreateBloodHUD(this, blob, player, HUD);
	
	HUD = CreateSoulHUD(this, blob, player, HUD);
	
	EndBaseHUD(this, blob, player);
	
	CreateBarsHUD(this, blob, player);
}
