#include "GameColours.as"

const int CONSECUTIVE_KILL_TIMER = 90;
const int LOTS = 999999;

string _awards_spritesheet = "Sprites/UI/hud_scores.png";

shared class Stats
{
	int airTime;
	int airTimeDead;
	int hitWhenDeadCount;
	int chatCharactersCount;
	f32 damageRecieved;
	f32 damageSent;
	f32 mileage;
	int aliveTime;
	int deadTime;
	int shortestAliveTime;
	int longestAliveTime;
	int airShotCount;
	int screenWraps;
	int fireKeyTime;
	int jumpKeyTime;
	int crouchKeyTime;
	int reviveCount;
	int suicideCount;
	int mostConsecutiveKills;
	int sumTimeSinceLastKill;
	int killsInRound;
	int squashed;
	int hitByRocket;
	f32 nadeKillDistance;

	// int deadScreenWraps;

	// vars

	Vec2f lastMeasurePos;
	int lastKillTime;
	int consecutiveKills;
	int timeSinceLastKill;

	Stats()
	{
		FullReset();
	}

	void ResetOnRound()
	{
		aliveTime = 0;
		deadTime = 0;
		timeSinceLastKill = getGameTime();
		killsInRound = 0;
	}

	void FullReset()
	{
		ResetOnRound();
		airTime = 0;
		airTimeDead = 0;
		chatCharactersCount = 0;
		damageRecieved = 0.0f;
		damageSent = 0.0f;
		mileage = 0.0f;
		airShotCount = 0;
		screenWraps = 0;
		fireKeyTime = 0;
		jumpKeyTime = 0;
		crouchKeyTime = 0;
		reviveCount = 0;
		suicideCount = 0;
		mostConsecutiveKills = 0;
		sumTimeSinceLastKill = 0;
		squashed = 0;
		hitByRocket = 0;
		nadeKillDistance = LOTS;
		shortestAliveTime = LOTS;
	}
};

shared class Award
{
	string who_name;
	string what;
	CPlayer@ who() { return getPlayerByUsername(who_name); }
};

// helper functions

Stats@ getStats( CPlayer@ this )
{
	if (this is null){
		return null;
	}
	Stats@ stats;
	this.get("stats", @stats);
	return stats;
}

Vec2f _awardsPos;
const f32 _awardScrollSpeed = 2.0f;

string getPlayerName(CPlayer@ player)
{
	if (player is null)
		return "NIL";
	return "P"+(player.getTeamNum()+1); // skirmish HACK:
}

string getStringSecs(int i)
{
	return "(" + int(Maths::Round(f32(i) / f32(getTicksASecond()))) + "s)";
}

int getIconFromPlayerName(const string &in name)
{
	if (name == "P1")
		return 0;
	if (name == "P2")
		return 1;
	if (name == "P3")
		return 2;
	if (name == "P4")
		return 3;
	return 4;
}

void BuildAwards( CRules@ this )
{
	if (!getNet().isServer())
		return;
	Driver@ driver = getDriver();
	_awardsPos.y = driver.getScreenHeight()-100;

	printf("Building awards...");
	Award@[] awards;
	this.set("awards", @awards);

	// most air time

	/*int airTimeMax;
	CPlayer@ playerMostAirTime;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.airTime > airTimeMax){
				airTimeMax = stats.airTime;
				@playerMostAirTime = player;
			}
		}
	}
	if (playerMostAirTime !is null)
	{
		Award award;
		award.who_name = playerMostAirTime.getUsername();
		award.what = "Most air time";
		awards.push_back(award);
	}

	// most dead air time

	int airDeadTimeMax;
	CPlayer@ playerMostDeadAirTime;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.airTimeDead > airDeadTimeMax){
				airDeadTimeMax = stats.airTimeDead;
				@playerMostDeadAirTime = player;
			}
		}
	}
	if (playerMostDeadAirTime !is null && airDeadTimeMax)
	{
		Award award;
		award.who_name = playerMostDeadAirTime.getUsername();
		award.what = "Most dead air time";
		awards.push_back(award);
	}	*/

	// most hit when dead

	int hitWhenDead;
	CPlayer@ playerMostHitWhenDead;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.hitWhenDeadCount > hitWhenDead){
				hitWhenDead = stats.hitWhenDeadCount;
				@playerMostHitWhenDead = player;
			}
		}
	}
	if (playerMostHitWhenDead !is null && hitWhenDead > 5)
	{
		Award award;
		award.who_name = playerMostHitWhenDead.getUsername();
		award.what = "Most gibbed";
		awards.push_back(award);
	}

	// most mileage

	f32 mileage;
	CPlayer@ playerMostMileage;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.mileage > mileage){
				mileage = stats.mileage;
				@playerMostMileage = player;
			}
		}
	}
	if (playerMostMileage !is null && mileage > 500)
	{
		Award award;
		award.who_name = playerMostMileage.getUsername();
		award.what = "Most distance travelled (" + ( Maths::Round(mileage/8) ) + "m)";
		awards.push_back(award);
	}

	// most alive time

	/*int aliveTime;
	CPlayer@ playerMostAliveTime;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.aliveTime > aliveTime){
				aliveTime = stats.aliveTime;
				@playerMostAliveTime = player;
			}
		}
	}
	if (playerMostAliveTime !is null)
	{
		Award award;
		award.who = getPlayerName(playerMostAliveTime);
		award.what = "Most time alive " + getStringSecs(aliveTime);
		awards.push_back(award);
	}*/

	// most dead time

	int deadTime;
	CPlayer@ playerMostDeadTime;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.deadTime > deadTime){
				deadTime = stats.deadTime;
				@playerMostDeadTime = player;
			}
		}
	}
	if (playerMostDeadTime !is null)
	{
		Award award;
		award.who_name = playerMostDeadTime.getUsername();
		award.what = "Most time spent dead " + getStringSecs(deadTime);
		awards.push_back(award);
	}

	// shortestAliveTime

	int shortestAliveTime = LOTS;
	CPlayer@ playerShortestAliveTime;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.shortestAliveTime < shortestAliveTime){
				shortestAliveTime = stats.shortestAliveTime;
				@playerShortestAliveTime = player;
			}
		}
	}
	if (playerShortestAliveTime !is null)
	{
		Award award;
		award.who_name = playerShortestAliveTime.getUsername();
		award.what = "Shortest time alive " + getStringSecs(shortestAliveTime);
		awards.push_back(award);
	}

	// longestAliveTime

	/*int longestAliveTime = 0;
	CPlayer@ playerLongestAliveTime;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.longestAliveTime > longestAliveTime){
				longestAliveTime = stats.longestAliveTime;
				@playerLongestAliveTime = player;
			}
		}
	}
	if (playerLongestAliveTime !is null)
	{
		Award award;
		award.who = getPlayerName(playerLongestAliveTime);
		award.what = "Longest time alive " + getStringSecs(longestAliveTime);
		awards.push_back(award);
	}*/

	// airShotCount

	int airShotCount = 0;
	CPlayer@ playerMostAirShotCount;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.airShotCount > airShotCount){
				airShotCount = stats.airShotCount;
				@playerMostAirShotCount = player;
			}
		}
	}
	if (playerMostAirShotCount !is null && airShotCount > 1)
	{
		Award award;
		award.who_name = playerMostAirShotCount.getUsername();
		award.what = "Most mid-air shots ("+airShotCount+")";
		awards.push_back(award);
	}

	// screenWraps

	int screenWraps = 0;
	CPlayer@ playerMostscreenWraps;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.screenWraps > screenWraps){
				screenWraps = stats.screenWraps;
				@playerMostscreenWraps = player;
			}
		}
	}
	if (playerMostscreenWraps !is null && screenWraps > 1)
	{
		Award award;
		award.who_name = playerMostscreenWraps.getUsername();
		award.what = "Most looped across screen ("+screenWraps+")";
		awards.push_back(award);
	}

	// suicideCount

	int suicideCount = 0;
	CPlayer@ playerMostSuicideCount;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.suicideCount > suicideCount){
				suicideCount = stats.suicideCount;
				@playerMostSuicideCount = player;
			}
		}
	}
	if (playerMostSuicideCount !is null && suicideCount > 1)
	{
		Award award;
		award.who_name = playerMostSuicideCount.getUsername();
		award.what = "Most suicides (" + suicideCount + ")";
		awards.push_back(award);
	}

	// reviveCount

	int reviveCount = 0;
	CPlayer@ playerMostReviveCount;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.reviveCount > reviveCount){
				reviveCount = stats.reviveCount;
				@playerMostReviveCount = player;
			}
		}
	}
	if (playerMostReviveCount !is null && reviveCount > 1)
	{
		Award award;
		award.who_name = playerMostReviveCount.getUsername();
		award.what = "Most revived (" + reviveCount + ")";
		awards.push_back(award);
	}

	// mostConsecutiveKills

	int mostConsecutiveKills = 0;
	CPlayer@ playerMostMostConsecutiveKills;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.mostConsecutiveKills > mostConsecutiveKills){
				mostConsecutiveKills = stats.mostConsecutiveKills;
				@playerMostMostConsecutiveKills = player;
			}
		}
	}
	if (playerMostMostConsecutiveKills !is null && mostConsecutiveKills > 1)
	{
		Award award;
		award.who_name = playerMostMostConsecutiveKills.getUsername();
		award.what = "Most consecutive kills (" + mostConsecutiveKills + ")";
		awards.push_back(award);
	}

	// killsInRound

	int killsInRound = 0;
	CPlayer@ playerMostKillsInRound;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.killsInRound > killsInRound){
				killsInRound = stats.killsInRound;
				@playerMostKillsInRound = player;
			}
		}
	}
	if (playerMostKillsInRound !is null && killsInRound > 1)
	{
		Award award;
		award.who_name = playerMostKillsInRound.getUsername();
		award.what = "Most kills in round (" + killsInRound + ")";
		awards.push_back(award);
	}

	// squashed

	int squashed = 0;
	CPlayer@ playerMostSquashed;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.squashed > squashed){
				squashed = stats.squashed;
				@playerMostSquashed = player;
			}
		}
	}
	if (playerMostSquashed !is null)
	{
		Award award;
		award.who_name = playerMostSquashed.getUsername();
		award.what = "Most squashed by crate (" + squashed + ")";
		awards.push_back(award);
	}

	// hitByRocket

	int hitByRocket = 0;
	CPlayer@ playerMostHitByRocket;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.hitByRocket > hitByRocket){
				hitByRocket = stats.hitByRocket;
				@playerMostHitByRocket = player;
			}
		}
	}
	if (playerMostHitByRocket !is null)
	{
		Award award;
		award.who_name = playerMostHitByRocket.getUsername();
		award.what = "Most flied on rocket (" + hitByRocket + ")";
		awards.push_back(award);
	}

	// nadeKillDistance

	f32 nadeKillDistance = LOTS;
	CPlayer@ playerMostBadeKillDistance;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			if (stats.nadeKillDistance < nadeKillDistance){
				nadeKillDistance = stats.nadeKillDistance;
				@playerMostBadeKillDistance = player;
			}
		}
	}
	if (playerMostBadeKillDistance !is null && nadeKillDistance < 50.0f)
	{
		Award award;
		award.who_name = playerMostBadeKillDistance.getUsername();
		award.what = "Best grenade aim";
		awards.push_back(award);
	}

	SyncAwards( this );
}

Award@[]@ getAwards( CRules@ this )
{
	Award@[]@ awards;
	this.get("awards", @awards);
	return awards;
}

void PlayerStatsFullReset()
{
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			stats.FullReset();
		}
		else {
			Stats stats;
			player.set("stats", @stats);
		}
	}
}

void PlayerStatsResetOnRound()
{
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		Stats@ stats = getStats(player);
		if (stats !is null){
			stats.ResetOnRound();
		}
	}
}


bool RenderPlayerAwards( CRules@ this )
{
	if (this.get_s16("in menu") > 0)
		return false;

	Award@[]@ awards = getAwards(this);
	//printf("awards.length " + awards.length);
	if (awards is null || awards.length == 0){
		return false;
	}

	const u32 time = getGameTime();
	float per_line_offset = 2.5f;
	float camera_scaling = getCamera().targetDistance;
	float pixel_scale = camera_scaling * 2.0f;
	float draw_scale = 0.5f;
	Driver@ driver = getDriver();

	// draw awards

	{
		uint player_count = awards.length;
		float per_line_offset = 1.25f;

		float camera_scaling = getCamera().targetDistance;
		float pixel_scale = camera_scaling * 2.0f;
		int score_cap = 20;

		Vec2f upperleft = Vec2f(getScreenWidth() / 2 - ((score_cap + 1) / 2) * 16.0f * pixel_scale,
		                        getScreenHeight() / 3 + (-player_count / 3) * 16.0f * pixel_scale);

		Vec2f totalsize = Vec2f(score_cap + 1, (1 + player_count) * per_line_offset) * 16.0f * pixel_scale;


		//background frame
		GUI::DrawRectangle(upperleft - Vec2f(18, 10), upperleft + totalsize + Vec2f(18, 10), Colours::BLACK);
		GUI::DrawRectangle(upperleft - Vec2f(17, 9), upperleft + totalsize + Vec2f(17, 9), Colours::PURPLE);
		GUI::DrawRectangle(upperleft - Vec2f(16, 8), upperleft + totalsize + Vec2f(16, 8), Colours::BLACK);

		float draw_scale = 0.5f;

		//title
		GUI::SetFont("gui");
		GUI::DrawText("Awards", upperleft + Vec2f(totalsize.x / 2 - 80 * draw_scale, 0), color_white);

	/*	needs to check per local player
		f32 p_bounce_amount = (Maths::Sin(1.0f * (time + 13)) * 5) * draw_scale;
		CControls@ controls = p.getControls();
		// blink if action button pressed
		const bool actionPressed = (controls !is null ? (controls.ActionKeyPressed(AK_ACTION1) || controls.ActionKeyPressed(AK_ACTION2)) : false);	*/

		//GUI::SetFont("hud");
		for (uint i = awards.length-1; i > 0; i--)
		{
			Award@ award = awards[i];

			Vec2f local_upperleft = upperleft + Vec2f(0, (i + 1) * per_line_offset * 16.0f * pixel_scale);
			Vec2f textposWhat = Vec2f( 4*driver.getScreenWidth()/5, local_upperleft.y );

			//player counter icon
			GUI::DrawIcon(_awards_spritesheet, getIconFromPlayerName(getPlayerName(award.who())),
			              Vec2f(16, 16), Vec2f( upperleft.x, textposWhat.y /*+ ((award.who().isLocal() && actionPressed) ? -p_bounce_amount : 0)*/), draw_scale);

			GUI::DrawText(award.what, Vec2f(upperleft.x + 20, textposWhat.y - 4), Colours::WHITE);
		}
	}

	return true;
}


void SyncAwards( CRules@ this )
{
	if (!getNet().isServer())
		return;
	Award@[]@ awards = getAwards(this);
	if (awards is null || awards.length == 0){
		return;
	}

	//putting this in one place because it was being handled stupidly before
	u32 awards_len = awards.length - 1;

	CBitStream params;
	params.write_u16(awards_len);
	for (uint i = awards_len; i > 0; i--)
	{
		Award@ award = awards[i];

		if (award.who() !is null)
		{
			params.write_netid(award.who().getNetworkID());
			params.write_string(award.what);
			printf("sync " + award.what);
		}
		else
		{
			params.write_netid(0);
			params.write_string("");
		}

	}

	this.SendCommand(this.getCommandID("award"), params);
}
