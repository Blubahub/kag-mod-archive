#include "PotionsCommon.as";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	int gameTime = getGameTime();
	u16 invisDur = (blob.get_u16("invisDuration") - gameTime) / 30 + 1;
	bool isInvis = invisDur >= 0 && invisDur <= (invisDuration / 30);

	u16 lightDur = (blob.get_u16("lightDuration") - gameTime) / 30 + 1;
	bool isLight = lightDur >= 0 && invisDur <= (lightDuration / 30);
	

	string invisTime = invisDur + " secs  (invisibility)";
	string lightTime = lightDur + " secs  (lightness)";

	string time;

	if (isInvis && isLight)
	{
		time = invisTime + "\n" + lightTime;
		draw(time);
	}
	else if (isInvis)
	{
		time = invisTime;
		draw(time);
	}
	else if (isLight)
	{
		time = lightTime;
		draw(time);
	}
	else 
	{
		ScriptData@ script = this.getCurrentScript();
        if ( script !is null )
        {
            script.runFlags |= Script::remove_after_this;
        }
	}
}

void draw(string text)
{
	GUI::DrawText( text ,
		Vec2f(10, 200), Vec2f(200, 200), 0xff000000, true, true, true );
}