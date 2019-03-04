
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if(getLocalPlayerBlob() is null)return;
	
	f32 bob = (f32(getGameTime()) % 60)-30;
	
	if(bob < 0)bob = -bob;
	
	if(getLocalPlayerBlob().get_string("partner") == blob.get_string("player_name")){
		string filename = "Heart.png";
		GUI::DrawIcon(filename, 0, Vec2f(16,16), getDriver().getScreenPosFromWorldPos(blob.getPosition()+Vec2f(0,-16))-Vec2f(16.0f,16.0f+bob*0.5f), 1.0f);
	}
}