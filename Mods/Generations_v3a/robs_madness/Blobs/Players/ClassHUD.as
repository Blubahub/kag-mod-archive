
#include "ClassActorHUDStartPos.as";
#include "EnergyCommon.as";

const int slotsSize = 6;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors(CBlob@ this)
{
	if (getHUD().hasButtons())
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		if (this.isAttached() && this.isAttachedToPoint("GUNNER"))
		{
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-32, -32));
		}
		else
		{
			bool sword = false;
			bool target = true;
			
			if(this.getName() == "ghoul" || this.getName() == "paladin" || this.getName() == "zombie" || this.getName() == "skeleton"){
				sword = true;
				target = false;
			}
			
			if(sword)getHUD().SetCursorImage("Entities/Characters/Knight/KnightCursor.png", Vec2f(32, 32));
			if(target){
				getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
				getHUD().SetCursorOffset(Vec2f(-32, -32));
			}
		}
	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);

	//Base classes handle this stuff already in thier own HUD
	if(blob.getName() != "archer" && blob.getName() != "knight" && blob.getName() != "builder" && blob.getName() != "runemaster"){
	
		ManageCursors(blob);

		// draw inventory
		DrawInventoryOnHUD(blob, tl);

		// draw coins
		const int coins = player !is null ? player.getCoins() : 0;
		DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);
	
	}

	if(blob.getName() == "zombie" || blob.getName() == "skeleton")return;
	
	
	// draw class icon

	int pressOne = 0;
	int pressTwo = 0;
	
	if(blob.isKeyPressed(key_action1))pressOne = 2;
	if(blob.isKeyPressed(key_action2))pressTwo = 2;
	
	GUI::DrawIcon("ClassHUD.png", pressOne, Vec2f(36, 72), tl + Vec2f(300,-56), 1.0f);
	GUI::DrawIcon("ClassHUD.png", pressTwo+1, Vec2f(36, 72), tl + Vec2f(300,-56) + Vec2f(72+8,0), 1.0f);
	
	GUI::DrawIcon("ClassHUD.png", 4, Vec2f(36, 72), tl + Vec2f(300,-56) + Vec2f(72+8,0)*2, 1.0f);
	
	Vec2f IconPos = tl + Vec2f(300,-56) + Vec2f(12,36);
	
	GUI::DrawIcon(blob.getName()+"HUD.png", 0, Vec2f(24, 24), IconPos, 1.0f);
	
	GUI::DrawIcon(blob.getName()+"HUD.png", 1, Vec2f(24, 24), IconPos + Vec2f(72+8,0), 1.0f);
	
	GUI::DrawIcon(blob.getName()+"HUD.png", 2, Vec2f(24, 24), IconPos + Vec2f(72+8,0)*2, 1.0f);
	
	if(blob.hasTag("DisableOne") || getGameTime() < blob.get_u16("CooldownOne"))GUI::DrawRectangle(IconPos, IconPos+Vec2f(48,48), SColor(196, 0, 0, 0));
	if(blob.hasTag("DisableTwo") || getGameTime() < blob.get_u16("CooldownTwo"))GUI::DrawRectangle(IconPos + Vec2f(72+8,0), IconPos+Vec2f(48,48) + Vec2f(72+8,0), SColor(196, 0, 0, 0));
	if(blob.hasTag("DisablePassive") || getGameTime() < blob.get_u16("CooldownPassive"))GUI::DrawRectangle(IconPos + Vec2f(72+8,0)*2, IconPos+Vec2f(48,48) + Vec2f(72+8,0)*2, SColor(196, 0, 0, 0));
	
	GUI::SetFont("menu");
	
	if(getGameTime() < blob.get_u16("CooldownOne"))GUI::DrawTextCentered(""+((blob.get_u16("CooldownOne")-getGameTime())/10), IconPos+Vec2f(8,40), SColor(255, 255, 255, 255));
	if(getGameTime() < blob.get_u16("CooldownTwo"))GUI::DrawTextCentered(""+((blob.get_u16("CooldownTwo")-getGameTime())/10), IconPos+Vec2f(8,40) + Vec2f(72+8,0), SColor(255, 255, 255, 255));
	if(getGameTime() < blob.get_u16("CooldownPassive"))GUI::DrawTextCentered(""+((blob.get_u16("CooldownPassive")-getGameTime())/10), IconPos+Vec2f(8,40) + Vec2f(72+8,0)*2, SColor(255, 255, 255, 255));

	Vec2f EnergyBar = IconPos + Vec2f(-20*2,22*2);
	
	for (int i = 0; i < blob.get_u8("MaxEnergy"); i += 1){
		int frame = (i == 0) ? 4 : 2;
		if(i == blob.get_u8("MaxEnergy")-1)frame = 0;
		Vec2f offset = EnergyBar-Vec2f(0,i*4*2);
		if(frame == 0)offset += Vec2f(0,-4*2);
		GUI::DrawIcon("EnergyBar.png", frame, Vec2f(12, 8), offset, 1.0f);
		if(getEnergy(blob) > i)GUI::DrawIcon("EnergyBar.png", frame+1, Vec2f(12, 8), offset, 1.0f);
	}
	
	
}


