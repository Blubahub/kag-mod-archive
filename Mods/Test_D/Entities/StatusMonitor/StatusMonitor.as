#include "GameColours.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "LobbyStatsCommon.as"
#include "Timers.as"
//so we can hide when rendering menus..
#include "UI.as"

void onInit(CRules@ this)
{
	if (!GUI::isFontLoaded("computer screen"))
	{
		GUI::LoadFont("computer screen", "GUI/Fonts/computer/F25_Bank_Printer_Bold.ttf", 8, false);
	}
}

void onTick(CRules@ this)
{
	if (!getNet().isServer())
		return;

	Lobby::Server[]@ servers = Lobby::getServers();

	if (servers !is null && servers.length > 0)
	{
		LobbyStats@ stats = getStats();

		//collect lines here
		string[] lines;

		//server count
		{
			//count number initialised
			u32 amount = servers.length;
			u32 connectable = 0;
			for (uint i = 0; i < servers.length; i++)
			{
				if (servers[i].connectable = true)
				{
					connectable++;
				}
			}

			lines.push_back(formatInt(s32((connectable / f32(amount != 0 ? amount : 1)) * 100), "", 3) + '%' + " Stablity");
		}

		//time between game
		{
			string line = "";

			u32 seconds = stats.secondsBetweenGames();
			if (seconds == 0 || seconds > 600)
				line = ">5m";
			else if (seconds < 60)
				line = formatInt(seconds, "", 2) + "s";
			else
				line = " " + (seconds / 60) + "m";

			line += " Wait";

			lines.push_back(line);
		}

		//player count
		u32 players_now = Maths::Max(stats.playersNow(), getRules().get_u32("total_players"));
		{
			lines.push_back("Players Now:   " + formatInt(players_now, "", 3));
		}

		//daily stats
		{
			u32 players = stats.playersToday();
			lines.push_back("Players Today: " + formatInt(players, "", 3));
		}

		{
			u32 games = stats.gamesToday;
			lines.push_back("Games Today: " + formatInt(games, "", 3));
		}

		//players ingame count
		u32 players_ingame = 0;
		u32 games_in_progress = 0;
		{
			for (uint i = 0; i < servers.length; i++)
			{
				Lobby::Server@ s = servers[i];
				if (s.connectable = true && s.status.length >= 3)
				{
					if (s.status[1] == "busy")
					{
						games_in_progress++;
						players_ingame += parseInt(s.status[2]);
					}
				}
			}

			lines.push_back("Games in Progress: " + formatInt(games_in_progress, "", 1));
			lines.push_back("Players In-Game:  " + formatInt(players_ingame, "", 2));
		}


		this.set_string("status_lines", join(lines, "||"));
		this.Sync("status_lines", true);

		//tag for rendering
		this.Tag("_init_lines");
		this.Sync("_init_lines", true);


		//print each 5 min for analytics' sake
		if ((getGameTime() % 30 == 0) && Time() % (5 * 60) == 0)
		{
			print("stats: " + "\n\t" +
			      "players now " + players_now + "\n\t" +
			      "players ingame " + players_ingame + "\n\t" +
			      "players today " + stats.playersToday() + "\n\t" +
			      "games now " + games_in_progress + "\n\t" +
			      "classes " + stats.classCount(0) + " " + stats.classCount(1) + " " + stats.classCount(2) + " " + stats.classCount(3) + " " + stats.classCount(4) + "\n\t" +
			      "teams " + stats.teamCount(0) + " " + stats.teamCount(1) + "\n\t" +
			      "games today " + stats.gamesToday + "\n\t" +
			      "games total " + stats.gamesTotal() + "\n\t" +
			      "seconds between games " + stats.secondsBetweenGames() + "\n\t" +
			      lines[0] //server stability
			     );
		}

	}
}

void onRender(CRules@ this)
{
	if (UI::hasAnyContent() || getRules().hasTag("showing_tips") || getRules().get_s16("in menu") != 0)
		return;

	GUI::SetFont("gui");

	f32 height = 17;

	Vec2f status_ul(10, getScreenHeight() - height);

	if (!this.hasTag("_init_lines") || !this.exists("status_lines"))
	{
		Vec2f status_frame = Vec2f(130, height);
		DrawTRGuiFrame(status_ul, status_ul + status_frame);

		string elipsis = ".";
		for (u32 i = 0; i < Time() % 3; i++)
		{
			elipsis += ".";
		}

		GUI::DrawText("Fetching Status" + elipsis, status_ul + Vec2f(8, -2), Colours::GREY);
		return;
	}

	string[] lines = this.get_string("status_lines").split("||");

	if (lines.length < 7)
		return;

	bool games_happening = lines[5].substr(lines[5].length - 2, 2) != " 0";
	bool games_played = lines[4].substr(lines[4].length - 2, 2) != " 0";

	Vec2f location = status_ul;
	Vec2f text_offset = Vec2f(4, -2);

	s32 i = (Time() / 5);

	//more than zero games going
	if (games_happening)
	{
		//players ingame
		Vec2f status_frame = Vec2f(134, height);
		DrawTRGuiFrame(location, location + status_frame);
		GUI::DrawText(lines[5], location + text_offset, Colours::WHITE);
		location.x += status_frame.x + 10;
		//games currently happening
		status_frame = Vec2f(134, height);
		DrawTRGuiFrame(location, location + status_frame);
		GUI::DrawText(lines[6], location + text_offset, Colours::WHITE);
		location.x += status_frame.x + 10;
	}
	//otherwise, more than 0 games played
	else if (games_played)
	{
		//player counts
		Vec2f status_frame = Vec2f(124, height);
		DrawTRGuiFrame(location, location + status_frame);
		GUI::DrawText(lines[3], location + text_offset, Colours::WHITE);
		location.x += status_frame.x + 10;
		//game count
		status_frame = Vec2f(114, height);
		DrawTRGuiFrame(location, location + status_frame);
		GUI::DrawText(lines[4], location + text_offset, Colours::WHITE);
		location.x += status_frame.x + 10;
	}
	//(otherwise nothing)

	{
		//wait time
		Vec2f status_frame = Vec2f(64, height);
		DrawTRGuiFrame(location, location + status_frame);
		GUI::DrawText(lines[1], location + text_offset, Colours::WHITE);
		location.x += status_frame.x + 10;
	}

	//line above
	location = status_ul - Vec2f(0, height + 8 + Maths::Sin(getGameTime() / 10.0f) * 1.2f);

	if (getPlayerCount() == 1)
	{
		//wait for players
		if (games_happening)
		{
			Vec2f status_frame = Vec2f(228, height);
			DrawTRGuiFrame(location, location + status_frame);
			GUI::DrawText("Please wait for the game to finish!", location + text_offset, Colours::WHITE);
			location.x += status_frame.x + 10;
		}
		else
		{
			Vec2f status_frame = Vec2f(108, height);
			DrawTRGuiFrame(location, location + status_frame);
			GUI::DrawText("Play with Bots!", location + text_offset, Colours::WHITE);
			location.x += status_frame.x + 10;
		}
	}

}
