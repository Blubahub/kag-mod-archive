#include "SkipScreenCommon.as"
#include "Timers.as"

const int SKIP_TIMES = 5;

void onInit(CRules@ this)
{
	this.addCommandID("skipscreen");
	this.addCommandID("skip timer");
}

void onTick(CRules@ this)
{
	if (this.isMatchRunning()){
		return;
	}

	SkipScreen::Data@ data = SkipScreen::getData(this);
	if (data is null)
		return;

	{
		for (int p_it = 0; p_it < getLocalPlayersCount(); p_it++)
		{
			CPlayer@ player = getLocalPlayer(p_it);
			if (player is null)
				continue;
	    	CControls@ controls = player.getControls();
	    	if (controls !is null)
	    	{
	    		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1)) || controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION2)))
	    		{
					CBitStream params;
					params.write_netid(player.getNetworkID());
					this.SendCommand(this.getCommandID("skipscreen"), params);
	    		}
	    	}
		}	    
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer() && cmd == this.getCommandID("skipscreen"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player is null)
			return;
		Sound::Play("buttonclick");
		SkipScreen::Data@ data = SkipScreen::getData(this);
		if (data is null)
			return;

		if (isOnSkipScreen(this, data) && Game::getTimer("skipping") is null)
		{
			u8 count = player.get_u8("skip screen count");
			player.set_u8("skip screen count", ++count);
			printf("skip " + player.getCharacterName() + " " + count );
			if (isSkipped(this))
			{
				print("SKIP");
				CBitStream params;
				this.SendCommand(this.getCommandID("skip timer"), params);
			}
		}
	}
	else if (cmd == this.getCommandID("skip timer"))
	{
		Game::CreateTimer("skipping", 1, @Skip, true);		
	}
}

void Skip(Game::Timer@ this)
{
	FireActiveSkippableTimers(this.rules, SkipScreen::getData(this.rules));
	ResetSkips( this.rules );
}


bool isOnSkipScreen(CRules@ this, SkipScreen::Data @data)
{
	Game::Timer@[]@ timers;
	this.get("timers", @timers);
	if (timers !is null)
	{
		for (uint i = 0; i < timers.length; i++)
		{
			Game::Timer@ timer = timers[i];
			for (uint ii = 0; ii < data.skippable.length; ii++)
			{			
				if (timer.endTime > 0 && timer.name == data.skippable[ii])
				{
					return true;
				}
			}
		}
	}
	return false;
}

void FireActiveSkippableTimers(CRules@ this, SkipScreen::Data @data)
{
	Game::Timer@[]@ timers;
	this.get("timers", @timers);
	if (timers !is null)
	{
		for (uint i = 0; i < timers.length; i++)
		{
			Game::Timer@ timer = timers[i];
			for (uint ii = 0; ii < data.skippable.length; ii++)
			{			
				if (timer.endTime > 0 && timer.name == data.skippable[ii])
				{
					// fire
					timer.endFunc(timer);
					timer.endTime = 0;
				}
			}
		}
	}	
}

void onStateChange(CRules@ this, const u8 oldState)
{
	ResetSkips( this );
}

void ResetSkips(CRules@ this)
{
	for (int p_it = 0; p_it < getPlayersCount(); p_it++)
	{
		CPlayer@ player = getPlayer(p_it);
		player.set_u8("skip screen count", 0);
	}	
}

bool isSkipped(CRules@ this)
{
	int count = 0;
	for (int p_it = 0; p_it < getPlayersCount(); p_it++)
	{
		CPlayer@ player = getPlayer(p_it);
		if (player.isBot()){
			continue;
		}
		print("player " + p_it + " = " + player.get_u8("skip screen count") );
		if (player.get_u8("skip screen count") < SKIP_TIMES){
			return false;
		}
	}
	return true;
}

void onRender( CRules@ this )
{
	if (Game::getTimer("skipping") is null)
		return;

	GUI::SetFont("menu");
	GUI::DrawRectangle( Vec2f_zero, getDriver().getScreenDimensions(), color_black );
	GUI::DrawTextCentered("Skipping...", getDriver().getScreenCenterPos(), color_white );
}