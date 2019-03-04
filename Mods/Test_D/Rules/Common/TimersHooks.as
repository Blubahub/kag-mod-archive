// include this in gamemode.cfg rules for timers to work
#define ALWAYS_ONRELOAD
#include "Timers.as"
#include "GameColours.as"

void onInit( CRules@ this )
{
}

void onTick( CRules@ this )
{
	Game::Timer@[]@ timers;
	this.get("timers", @timers);
	if (timers !is null)
	{
		for (uint i=0; i < timers.length; i++)
		{
			Game::TimerUpdate(timers[i]);
			if (timers[i].endTime == 0)
			{
				timers.removeAt(i);
				i = 0;
			}
		}
	}
}

void onRender( CRules@ this )
{
	Game::Timer@[]@ timers;
	this.get("timers", @timers);
	if (timers !is null)
	{
		const u32 gametime = getGameTime();

		for (uint i=0; i < timers.length; i++)
		{
			Game::Timer@ timer = timers[i];
			if (!timer.showTimer)
				continue;

			s32 ticksToEnd = s32(timer.endTime - gametime);
		    if (ticksToEnd >= 0)
		    {
				const s32 timeToEnd = Maths::Ceil(f32(ticksToEnd)/f32(getTicksASecond()));
		        const s32 secondsToEnd = timeToEnd % 60;
		        const s32 minutesToEnd = timeToEnd / 60;
		        SColor color = (ticksToEnd % 8 > 3 || ticksToEnd > 5*getTicksASecond()) ? Colours::WHITE : Colours::RED;

		        f32 w = getScreenWidth();

		        GUI::DrawRectangle(Vec2f(w/2-25, 1), Vec2f(w/2 + 25, 15), 0xff40905f);
		        GUI::DrawIcon("Sprites/UI/time_icon.png", 0, Vec2f(16,16), Vec2f(w/2-32, 0), 0.5f);
		        GUI::SetFont("gui");
		        GUI::DrawTextCentered(""+((minutesToEnd<10)?"0"+minutesToEnd:""+minutesToEnd)+":"+((secondsToEnd<10)?"0"+secondsToEnd:""+secondsToEnd),
		        		Vec2f(w/2, 4), color);

		        break;
		    }
		}
	}
}
