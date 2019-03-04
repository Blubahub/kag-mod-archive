
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if(blob.getPlayer() !is getLocalPlayer())return;
	
	int GUIScale = 2;
	
	int Y = getScreenHeight()/4;
	
	GUI::DrawIcon("Oxygen.png", 0, Vec2f(80,16), Vec2f(0,Y));
	
	int AirAmount = (((blob.get_u8("air_count")*1.0f)/180.0f)*24.0f);
	
	GUI::DrawIcon("OxygenBar.png", AirAmount, Vec2f(80,16), Vec2f(0,Y));
	
	if(blob.hasTag("space_suit")){
		AirAmount = (((blob.get_u16("air_tank")*1.0f)/1500.0f)*24.0f);
		GUI::DrawIcon("AirTankBar.png", AirAmount, Vec2f(80,16), Vec2f(0,Y));
	}
	
	Y += 16*GUIScale;
	
	int Scrap = blob.getBlobCount("mat_scrap");
	
	GUI::DrawIcon("ScrapHUD.png", 0, Vec2f(50,19), Vec2f(2*GUIScale,Y));
	
	GUI::SetFont("menu");
	Vec2f dimensions(0,0);
	string disp = "" + Scrap;
	GUI::GetTextDimensions(disp, dimensions);
	GUI::DrawText(disp, Vec2f(36*GUIScale,Y+5*GUIScale) + Vec2f(-dimensions.x/2 , 0), SColor(255, 255, 255, 255));
	
}