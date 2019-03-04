const u8 default_aircount = 180; //6s, remember to update runnerdrowning.as

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (getHUD().hasButtons())
	{
		return;
	}

	//draw air bubbles
	s32 extra = 1;
	s32 offset = -30;
	s32 maxaircount = default_aircount + offset;
	s32 aircount = blob.get_u8("air_count") + offset + extra;
	
	Vec2f p = blob.getPosition() + Vec2f(0.0f, -blob.getHeight() * 1.5f);
	p.x -= 8;
	Vec2f pos = getDriver().getScreenPosFromWorldPos(p);
	
	int frame = 0;
	
	if(Maths::FMod(aircount, 8) > 3)frame = 1;
	
	if(blob.get_u8("air_count") < default_aircount-10)GUI::DrawIcon("OxyWarning.png", frame , Vec2f(27,12),pos,getCamera().targetDistance);
}
