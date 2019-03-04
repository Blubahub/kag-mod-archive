#include "SSKStatusCommon.as"
#include "TeamColour.as";

// draws a health status indicator on all players

 #define CLIENT_ONLY

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

    CBlob@ blob = this.getBlob();
	SSKStatusVars@ statusVars;
	if (!blob.get("statusVars", @statusVars))
	{
		return;
	}
	
	Vec2f pos2d = blob.getScreenPos();
	Vec2f dim = Vec2f(24,8);
	const f32 y = blob.getHeight()*2.4f;

	f32 damageStatus = statusVars.damageStatus;
	
	f32 fractionHealth = damageStatus/1000.0f;
	int hue = 255 - 255 * fractionHealth^2;

	SColor col =  SColor(255, 255, hue, hue);
	GUI::DrawText(""+Maths::Round(damageStatus)+"%", Vec2f(pos2d.x - dim.x+10, pos2d.y + y-75), col);

	if ( getLocalPlayerBlob() !is blob )
	{
		//show username
		CPlayer@ thisPlayer = blob.getPlayer();
		if ( thisPlayer !is null )
		{
			const f32 y = blob.getHeight() * 2.0f;
			string playerName = thisPlayer.getCharacterName();
			Vec2f textSize;
			GUI::GetTextDimensions("" + playerName, textSize);

			f32 screenWidth = getScreenWidth();
			f32 screenHeight = getScreenHeight();

			Vec2f nameScreenPos = Vec2f(pos2d.x - textSize.x/2.0f, pos2d.y + y);
			// print("nameScreenPosx :" + nameScreenPos.x + " nameScreenPosY: " + nameScreenPos.y);

			// render arrow if player is out of screen bounds
			if ( nameScreenPos.x < 0 || nameScreenPos.x > screenWidth
				|| nameScreenPos.y < 0 || nameScreenPos.y > screenHeight )
			{
				f32 horizontalNamePadding = textSize.x/2.0f + 32.0f;
				f32 verticalNamePadding = textSize.y/2.0f + 32.0f;

				nameScreenPos.x = Maths::Clamp(nameScreenPos.x, horizontalNamePadding, screenWidth - horizontalNamePadding);
				nameScreenPos.y = Maths::Clamp(nameScreenPos.y, verticalNamePadding, screenHeight - verticalNamePadding);

			}

			GUI::DrawRectangle(nameScreenPos + Vec2f(-2.0f, 2.0f), nameScreenPos + Vec2f(textSize.x, textSize.y) + Vec2f(8.0f, 2.0f), SColor(100, 0, 0, 0)); 
			GUI::DrawText(playerName, nameScreenPos, getTeamColor( blob.getTeamNum() )); 
		}
	}
}
