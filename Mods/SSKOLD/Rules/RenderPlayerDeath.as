#include "SSKStatusCommon.as"
#include "TeamColour.as";

// shows indicators above clanmates and players of interest

#define CLIENT_ONLY

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	CPlayer@ localPlayer = getLocalPlayer();
	if (localPlayer is null)
		return;

	Vec2f cameraPos = getCamera().getPosition();

	SetScreenFlash( 200, 250, 250, 250 );

	bool strongSmash = false;
	CBlob@ victimBlob = victim.getBlob();
	if (victimBlob !is null)
	{
		SSKStatusVars@ victimStatusVars;
		if (victimBlob.get("statusVars", @victimStatusVars))
		{
			if (victimStatusVars.isTumbling && victimStatusVars.tumbleVec.getLength() >= 12.0f)
			{
				strongSmash = true;
			}
		}

		/*
		int numParticles = 20;
		int randomWidth = 600;
		int randomHeight = 600;
		for (int i = 0; i < numParticles; i++)
		{
			CParticle@ p = ParticleAnimated("energybeam1.png", victimBlob.getPosition() + Vec2f(XORRandom(randomWidth) - randomWidth/2.0f, XORRandom(randomHeight - randomHeight/2.0f)), Vec2f(0, 0), 0.0f, 1.0f, 4, 0.0f, true);
			if ( p !is null )
			{
				p.diesoncollide = false;
				p.collides = false;
			}
		}
		*/
		CMap@ map = getMap();
		f32 padding = 16.0f;
		const u16 mapWidth = map.tilemapwidth * map.tilesize;
		const u16 mapHeight = map.tilemapheight * map.tilesize;

		Vec2f victimPos = victimBlob.getPosition();
		Vec2f effectPos = victimPos;
		effectPos.x = Maths::Clamp(effectPos.x, padding, mapWidth - padding);
		effectPos.y = Maths::Clamp(effectPos.y, padding, mapHeight - padding);

		Vec2f screenDimensions = getDriver().getScreenDimensions(); 
		Vec2f effectScreenPos = getDriver().getScreenPosFromWorldPos(effectPos);
		effectScreenPos.x = Maths::Clamp(effectScreenPos.x, 0, screenDimensions.x);
		effectScreenPos.y = Maths::Clamp(effectScreenPos.y, 0, screenDimensions.y);

		effectPos = getDriver().getWorldPosFromScreenPos(effectScreenPos);

		CParticle@ p = ParticleAnimated("energyblast1.png", effectPos, Vec2f(0, 0), 0.0f, 1.0f, 4, 0.0f, true);
		{
			p.Z = 1000.0f;
		}
	}

	if (strongSmash)
	{
		Sound::Play("smashed1.ogg");
		ShakeScreen( 80, 30, cameraPos );
	}
	else
	{
		Sound::Play("smashed2.ogg");
		ShakeScreen( 20, 20, cameraPos );
	}
}
