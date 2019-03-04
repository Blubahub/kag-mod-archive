

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}

	// draw tile cursor

	CMap@ map = blob.getMap();
	Vec2f Aim = blob.getAimPos();
	Vec2f HitPos = blob.getAimPos();
	
	map.rayCastSolidNoBlobs(blob.getPosition(),Aim,HitPos);
	
	if(blob.hasTag("draw_cursor"))DrawCursorAt(HitPos, cursorTexture);
	
	CBlob @targ = getBlobByNetworkID(blob.get_u16("picking_target"));
	if(targ !is null)targ.RenderForHUD(RenderStyle::outline);
}

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}