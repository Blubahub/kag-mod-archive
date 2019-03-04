#define CLIENT_ONLY

#include "SSKRunnerCommon.as"

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_onground;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater;
	this.getCurrentScript().runFlags |= Script::tick_moving;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (/*blob.isOnGround() && */(blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right)))
	{
		SSKRunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}

		int soundInterval = 8;
		if (moveVars.walkFactor < 1.0f)
			soundInterval = 14;

		if (moveVars.dashing)
			soundInterval = 6;

		if ((blob.getNetworkID() + getGameTime()) % soundInterval == 0)
		{
			f32 volume = Maths::Min(0.1f + Maths::Abs(blob.getVelocity().x) * 0.1f, 1.0f);
			TileType tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;

			if (blob.getMap().isTileGroundStuff(tile))
			{
				this.PlayRandomSound("/EarthStep", volume);
			}
			else
			{
				this.PlayRandomSound("/StoneStep", volume);
			}

			if (moveVars.dashing)
				ParticleAnimated("SmallSteam.png", blob.getPosition() + Vec2f(0.0f, 7.0f), Vec2f(0, 0), XORRandom(360), 1.0f, 2, 0.0f, true);
		}
	}
}