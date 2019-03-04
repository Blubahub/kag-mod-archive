#include "ClassesCommon.as"
#include "Timers.as"
#include "GamemodeCommon.as"
#include "CampaignCommon.as"
#include "SkipScreenCommon.as"

int _cameraTime = 0;
int _cameraTimeEnd = 0;
f32 _cameraSpeed = 0.1f;

void onInit(CRules@ this)
{
	ClearClasses(this);
	AddClass(this, Soldier::ASSAULT);
	AddClass(this, Soldier::SNIPER);
	AddClass(this, Soldier::MEDIC);
	AddClass(this, Soldier::ENGINEER);
	AddClass(this, Soldier::COMMANDO);

	this.set_bool("fog of war", false);
	this.set_bool("respawning", false);
	this.set_bool("infinite ammo", false);
	this.set_bool("infinite grenades", false);

	this.set_string("gamemode", "Campaign");

	Campaign::InitCampaign(this);

	string[] timers =
	{
		"teams",
		"briefing",
		"intermission"
	};
	SkipScreen::AddSkippable(this, timers);
}

void onTick(CRules@ this)
{
	Campaign::Data@ data = Campaign::getCampaign(this);
	Campaign::Sync(this, data);

	CameraControl(this);
}

void onStateChange(CRules@ this, const u8 oldState)
{
	const u8 state = this.getCurrentState();

	if (state == INTERMISSION)
	{
	}
	else if (state == GAME)
	{
		this.set_string("scrolling text", "");
		Game::CreateTimer("timeout", this.get_u32("timeout_secs"), @TimeOut, true);

		// re-enable keys
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			CBlob@ blob = player.getBlob();
			if (blob !is null)
			{
				blob.DisableKeys(0);
			}
		}
	}
	else if (state == WARMUP)
	{
		this.set_string("scrolling text", "");
		_cameraTime = 0;
		_cameraTimeEnd = this.get_u32("briefing_secs") * getTicksASecond();
	}
	else if (state == INTERMISSION)
	{
		Game::CreateTimer("teams", this.get_u32("teams_secs"), @EndTeams, false);
	}
	else if (state == GAME_OVER)
	{
		_cameraTime = 0;
		_cameraTimeEnd = this.get_u32("gameover_secs") * getTicksASecond();

		// disable fire

		//if (!getNet().isServer())
		{
			for (uint i = 0; i < getPlayersCount(); i++)
			{
				CPlayer@ player = getPlayer(i);
				CBlob@ blob = player.getBlob();
				if (blob !is null)
				{
					blob.DisableKeys(key_action1 | key_action2);
				}
			}
		}
	}
}

void TimeOut(Game::Timer@ this)
{
	if (getNet().isServer())
	{
		printf("GAME_OVER");
		this.rules.SetCurrentState(GAME_OVER);
		this.rules.SetTeamWon(-1);
		Campaign::SetWinMsg(this.rules, "TIME OUT");
	}
}

void EndTeams(Game::Timer@ this)
{
}

//why isn't this in the standard lib??
float _Lerp(float a, float b, float t)
{
	return a * (1.0f - t) + b * t;
}

void CameraControl(CRules@ this)
{
	const u8 state = this.getCurrentState();
	CCamera@ camera = getCamera();
	CMap@ map = getMap();
	if (camera is null)
		return;

	CPlayer@ player = getLocalPlayer();
	if (player is null)
	{
		return;
	}

	// set camera to team edge
	const int screenWidth = getDriver().getScreenWidth();
	const f32 edgeMod = 0.25f / camera.targetDistance;
	const f32 edge = screenWidth * edgeMod + map.tilesize;
	const f32 y = map.tilemapheight * map.tilesize * 0.5f;
	const f32 edge1 = screenWidth * edgeMod + map.tilesize;
	const f32 edge2 = map.tilemapwidth * map.tilesize - screenWidth * edgeMod - map.tilesize;
	const u8 team = player.getTeamNum();

	Vec2f campos = camera.getPosition();
	Vec2f target, velocity;

	if (state == INTERMISSION || player is null)
	{
		this.Tag("camera control");
		camera.setPosition(Vec2f(map.tilemapwidth * map.tilesize * 0.5f, map.tilemapheight * map.tilesize * 0.5f));
	}
	else if (state == WARMUP)
	{
		this.Tag("camera control");

		const f32 startScroll = _cameraTimeEnd * 0.275f;
		if (_cameraTime < startScroll)
		{
			if (team == 0)
			{
				camera.setPosition(Vec2f(edge1, campos.y));
			}
			else if (team == 1)
			{
				camera.setPosition(Vec2f(edge2, campos.y));
			}
		}
		else if (_cameraTimeEnd > 0)
		{
			f32 factor = float(_cameraTime - startScroll) / float(_cameraTimeEnd - startScroll - startScroll);
			factor = Maths::Clamp01(factor);
			factor = Maths::SmoothStep(factor);
			if (team == 0)
			{
				camera.setPosition(Vec2f(_Lerp(edge1, edge2, factor), campos.y));
			}
			else if (team == 1)
			{
				camera.setPosition(Vec2f(_Lerp(edge2, edge1, factor), campos.y));
			}
		}

		_cameraTime++;
	}
	else if (state == GAME_OVER)
	{
		const int teamwon = this.getTeamWon();
		if (this.hasTag("got over edge") && (teamwon == 0 || teamwon == 1))	{
			target = Vec2f(teamwon == 0 ? edge2 : edge1, y);
		}
		else if (teamwon == 0 || teamwon == 1)	{
			target = this.get_Vec2f("last kill pos");
		}
		else {
			target = camera.getPosition();
		}
		this.Tag("camera control");
		_cameraSpeed = 0.1f;
		target.y = y;
		velocity = (target - campos) * _cameraSpeed;
		camera.setPosition(campos + velocity);		
		_cameraTime++;
	}
	else if (state == GAME)
	{
		this.Untag("camera control");
	}
}

