
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if(blob.getPlayer() !is getLocalPlayer())return;
	
	int GUIScale = 2;
	
	int Y = 25*GUIScale;
	
	
	GUI::DrawIcon("HealthBar.png", 0, Vec2f(252,19), Vec2f(4*GUIScale,4*GUIScale));
	
	int Health = (((blob.getHealth())/blob.getInitialHealth())*25.0f);
	
	GUI::DrawIcon("HealthBars.png", Health, Vec2f(252,19), Vec2f(4*GUIScale,4*GUIScale));
	
	
	
	int Scrap = blob.getBlobCount("mat_scrap");
	
	GUI::DrawIcon("ScrapHUD.png", 0, Vec2f(50,19), Vec2f(258*GUIScale,4*GUIScale));
	
	GUI::SetFont("menu");
	Vec2f dimensions(0,0);
	string disp = "" + Scrap;
	GUI::GetTextDimensions(disp, dimensions);
	GUI::DrawText(disp, Vec2f((258+34)*GUIScale,9*GUIScale) + Vec2f(-dimensions.x/2 , 0), SColor(255, 255, 255, 255));
	
	
	
	GUI::DrawIcon("Oxygen.png", 0, Vec2f(80,16), Vec2f(1*GUIScale,Y));
	
	int AirAmount = (((blob.get_u8("air_count")*1.0f)/180.0f)*24.0f);
	
	GUI::DrawIcon("OxygenBar.png", AirAmount, Vec2f(80,16), Vec2f(1*GUIScale,Y));
	
	if(blob.hasTag("space_suit")){
		AirAmount = (((blob.get_u16("air_tank")*1.0f)/1500.0f)*24.0f);
		GUI::DrawIcon("AirTankBar.png", AirAmount, Vec2f(80,16), Vec2f(1*GUIScale,Y));
	}
	
	Y += 16*GUIScale;
	
	
	
	
	
	
	
}