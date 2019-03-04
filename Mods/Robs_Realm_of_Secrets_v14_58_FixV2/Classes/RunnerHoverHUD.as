const s8 default_aircount = 60;

void onInit(CSprite@ this)
{
	//this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (getHUD().hasButtons())
	{
		return;
	}
	
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;

	Vec2f p = blob.getPosition() + Vec2f(0.0f, -blob.getHeight() * 3.0f);
	p.x -= 8;
	Vec2f pos = getDriver().getScreenPosFromWorldPos(p+Vec2f(0,24));
	pos.y += -2 + Maths::FastSin(getGameTime() / 4.5f) * 3.0f;
	Vec2f dim(16, 16);
	
	if(this.isVisible())
	if(getLocalPlayerBlob() !is null){
		if(getLocalPlayerBlob() is blob){
			// draw self indicator
			GUI::DrawIcon("GUI/PartyIndicator.png", 2, dim, pos, getCamera().targetDistance);
		} else {
			if(getLocalPlayerBlob().getTeamNum() == blob.getTeamNum()){
				GUI::DrawIcon("FriendOrFoe.png", 0, dim, pos, getCamera().targetDistance);
			} else {
				if(mouseOnBlob)GUI::DrawIcon("FriendOrFoe.png", 1, dim, pos, getCamera().targetDistance);
			}
		}
	}

	if(getLocalPlayerBlob() is blob)
	if(this.getBlob().get_s16("water_bubble") <= 0 && this.getBlob().hasTag("drawbubbles")){
		//draw air bubbles
		u32 extra = 30;
		u32 offset = 45;
		u32 maxaircount = default_aircount + offset;
		s8 aircount = blob.get_s8("air_count") + offset + extra;
		if (aircount < default_aircount + offset + extra)
		{
			if (aircount > 0)
			{
				// draw drown indicator
				p = blob.getPosition() + Vec2f(0.0f, -blob.getHeight() * 1.5f);
				p.x -= 8;
				pos = getDriver().getScreenPosFromWorldPos(p);
				dim.Set(8, 8);

				s32 bubblecount = (maxaircount + 29) / 30;
				for (s32 bubble = 0; bubble < bubblecount; bubble++)
				{
					s32 frac = aircount - (bubble * 30);

					u32 frame = (frac > 30) ? 0 : (frac > 22) ? 1 : (frac > 14) ? 2 : 3;
					if (frac > 8)
					{
						GUI::DrawIcon("Sprites/Water/AirBubble.png", frame, dim,
									  pos + Vec2f(-((bubblecount - 1) / 2.0f - bubble - 0.5f) * dim.x, 0) * 2.0f * getCamera().targetDistance,
									  getCamera().targetDistance);
					}
				}
			}
		}
	}
}