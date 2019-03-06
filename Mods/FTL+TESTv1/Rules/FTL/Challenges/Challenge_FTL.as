#include "FTLCommon.as"

bool myPlayerGotToTheEnd = false;
int checkpointCount = 0;
string endGameText = "You made it!";
const float END_DIST = 49.0f;

void Reset(CRules@ this)
{
	myPlayerGotToTheEnd = false;
	checkpointCount = 0;
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onInit(CMap@ this)
{
	CRules@ rules = getRules();
	SetIntroduction(rules, "Parkour");

	if (getNet().isServer())
	{
		rules.set_bool("repeat if dead", true);

		Vec2f endPoint;
		if (!this.getMarker("checkpoint", endPoint))
		{
			warn("End game checkpoint not found on map");
		}
		rules.set_Vec2f("endpoint", endPoint);
		rules.Sync("endpoint", true);
	}

	AddRulesScript(rules);

}

void onTick(CMap@ this)
{
	CRules@ rules = getRules();

	// local player check end

	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob !is null)
	{
		Vec2f endPoint = rules.get_Vec2f("endpoint");
		if ((!myPlayerGotToTheEnd && (localBlob.getPosition() - endPoint).getLength() < END_DIST) && localBlob.getTeamNum() == 0)
		{
			myPlayerGotToTheEnd = true;
			//Sound::Play("/VehicleCapture");
			
			// Game over!
			rules.SetTeamWon(0);
			rules.SetCurrentState(GAME_OVER);
			rules.SetGlobalMessage("The Captives win!");
		}
	}

	// server check

	if (getNet().isServer())
	{
		
		// server check

		Vec2f endPoint = rules.get_Vec2f("endpoint");
		CBlob@[] blobsNearEnd;
		if (this.getBlobsInRadius(endPoint, END_DIST, @blobsNearEnd))
		{
			for (uint i = 0; i < blobsNearEnd.length; i++)
			{
				CBlob @b = blobsNearEnd[i];
				if (b.getPlayer() !is null && !b.hasTag("checkpoint"))
				{
					b.Tag("checkpoint");
					checkpointCount++;

					CRules@ rules = getRules();
				}
			}
		}
	}
}

// render

void onRender(CRules@ this)
{
	//if (!myPlayerGotToTheEnd)
	{
		Vec2f endPoint = this.get_Vec2f("endpoint");
		//printf("endPoint " + endPoint.x + " " + endPoint.y + " " + myPlayerGotToTheEnd);
		Vec2f pos2d = getDriver().getScreenPosFromWorldPos(endPoint);
		pos2d.x -= 28.0f;
		pos2d.y -= 32.0f + 16.0f * Maths::Sin(getGameTime() / 4.5f);
		GUI::DrawIconByName("$DEFEND_THIS$",  pos2d);
	}
}
