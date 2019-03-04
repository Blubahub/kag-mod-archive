#include "RulesCommon.as"
#include "GameColours.as"

const string _hud_file = "Sprites/UI/hud_parts.png";

int _ypos = 0;
f32 _team1dist;
f32 _team2dist;

void onTick(CRules@ this)
{
	if (this.isWarmup())
	{
		_ypos = getScreenHeight() / 2 - 16;
	}
	else
	{
		if (_ypos > 0)
		{
			_ypos -= (30.0f / Maths::Sqrt(_ypos));
		}
		else
		{
			_ypos = 0;
		}
	}

	if (this.isMatchRunning())
	{
		CalcDistancesToEdge(_team1dist, _team2dist);
	}
}

void CalcDistancesToEdge(float &out dist1, float &out dist2)
{
	CMap@ map = getMap();
	CBlob@[] players;
	dist1 = 999999.9f;
	dist2 = dist1;
	if (getBlobsByName("soldier", @players))
	{
		for (uint step = 0; step < players.length; ++step)
		{
			CBlob@ blob = players[step];
			const u8 team = blob.getTeamNum();
			const bool dead = blob.hasTag("dead");
			if (dead) { continue; }

			if (team == 0)
			{
				f32 dist = (map.tilemapwidth * map.tilesize - map.tilesize) - blob.getPosition().x;
				if (dist < dist1)
				{
					dist1 = dist;
				}
			}
			else if (team == 1)
			{
				f32 dist = blob.getPosition().x;
				if (dist < dist2)
				{
					dist2 = dist;
				}
			}
		}
	}

	if (dist1 < 0.0f)
		dist1 = 0.0f;
	if (dist2 < 0.0f)
		dist2 = 0.0f;
}

//sneaky globals
Vec2f left_hud_ul = Vec2f();
Vec2f right_hud_ul = Vec2f();
const Vec2f hud_arrow = Vec2f(32, 32);
const float closedistance = 50.0f;
const float renderdistance = 150.0f;

void RenderDistance(float distance, bool right, bool ourteam)
{
	const bool close = distance < closedistance;
	GUI::SetFont(close ? "menu" : "gui");
	Vec2f pos = right ? (left_hud_ul + Vec2f(1.0f, 0.0f)) : (right_hud_ul + Vec2f(close ? -36.0f : 8.0f, 0.0f));

	if (distance > renderdistance)
	{
		u32 blink = ((getGameTime() / 15) % 2);
		if (ourteam)
		{
			u8 frame = !right ? 9 : 8;
			u32 colour = blink == 0 ? (!right ? Colours::TEAM1 : Colours::TEAM2) : Colours::WHITE;
			GUI::DrawIcon(_hud_file, frame, hud_arrow, pos + Vec2f(hud_arrow.x * 0.5f, 0.0f), 0.5f, SColor(colour));
		}

		return;
	}

	if (distance < 25.0f)
	{
		pos.y += (25.0f - distance) * 5.0f;
	}
	GUI::DrawText((!right ? "> " : "") + formatFloat(distance, "", 3, 1) + "m" + (right ? " <" : ""), pos, right ? Colours::TEAM2 : Colours::TEAM1);
}

void onRender(CRules@ this)
{

	/////////////////////////////////
	//don't render if not in-game
	/////////////////////////////////

	if (this.isIntermission() || this.isGameOver() || getLocalPlayer() is null)
		return;

	CMap@ map = getMap();
	if (map is null)
		return;
	if (hasMenus(this))
		return;
	if (getLocalPlayer().getTeamNum() > 1)
		return;

	/////////////////////////////////
	//gather any needed info
	/////////////////////////////////

	CBlob@ playerblob = getLocalPlayerBlob();
	const u32 time = getGameTime();
	bool enemy_is_right = getLocalPlayer().getTeamNum() == 0;

	/////////////////////////////////
	//actual rendering code
	/////////////////////////////////
	{
		left_hud_ul.Set(0, _ypos);
		right_hud_ul.Set(getScreenWidth() - (hud_arrow.x * 2), _ypos);

		if (this.isWarmup())
		{
			left_hud_ul.x = (25 - getGameTime() % 25) * 4;
			right_hud_ul.x = getScreenWidth() - (hud_arrow.x * 2) - left_hud_ul.x;
		}

		// distance
		if (this.isMatchRunning())
		{
			RenderDistance(_team1dist / 8.0f, false, enemy_is_right);
			RenderDistance(_team2dist / 8.0f, true, !enemy_is_right);
		}

		//blinking start arrows
		if (this.isWarmup())
		{
			u32 blink = ((time / 15) % 2);
			if (enemy_is_right)
			{
				GUI::DrawIcon(_hud_file, 9, hud_arrow, right_hud_ul + Vec2f(hud_arrow.x * 0.5f, 16.0f), 0.5f, SColor(blink == 0 ? Colours::TEAM1 : Colours::WHITE));
			}
			else
			{
				GUI::DrawIcon(_hud_file, 8, hud_arrow, left_hud_ul + Vec2f(hud_arrow.x * 0.5f, 16.0f), 0.5f, SColor(blink == 0 ? Colours::TEAM2 : Colours::WHITE));
			}
		}
	}
}
