#include "GameColours.as"

const int NOBODY_PLAYING_SECS = getTicksASecond() * 13;
const int NOBODY_PLAYING_EXPO_SECS = getTicksASecond() * 5;

int _nobodyPlayingCounter = 0;
int _nobodyPlayingCounterSecs = NOBODY_PLAYING_SECS;

bool _expoMode = false;

void onInit(CRules@ this)
{
	print("###### EXPO MODE ########");
	sv_max_localplayers = 4;
}

void onTick(CRules@ this)
{
	if (!this.isGameOver()){
		_nobodyPlayingCounter++;
	}

	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		CControls@ controls = player.getControls();
		if (controls.isKeyPressed(controls.getActionKeyKey(AK_ACTION1))
			|| controls.isKeyPressed(controls.getActionKeyKey(AK_ACTION2))
			|| controls.isKeyPressed(controls.getActionKeyKey(AK_MOVE_LEFT))
			|| controls.isKeyPressed(controls.getActionKeyKey(AK_MOVE_RIGHT))){
			_nobodyPlayingCounter = 0;
		}
	}

	//printf("_nobodyPlayingCounter " + _nobodyPlayingCounter + " / " + _nobodyPlayingCounterSecs);


	// reset rounds

	if (getNet().isClient() && (!_expoMode || this.isIntermission()) &&(getControls().isKeyJustPressed(KEY_F5) || _nobodyPlayingCounter >= _nobodyPlayingCounterSecs))
	{
		print("EXPO START");
		_nobodyPlayingCounter = 0;
		_nobodyPlayingCounterSecs = NOBODY_PLAYING_EXPO_SECS;
		if (!_expoMode)
		{
			CMixer@ mixer = getMixer();
			mixer.StopAll();
		}
		_expoMode = true;
		CBitStream params;
		this.SendCommand( this.getCommandID("force start"), params );
	}


	// expo end
	if (_expoMode)
	{
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			CControls@ controls = player.getControls();
			if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1)))
			{
				_nobodyPlayingCounterSecs = NOBODY_PLAYING_SECS;
				_nobodyPlayingCounter = 0;
				_expoMode = false;
				CMixer@ mixer = getMixer();
				mixer.FadeOutAll(0.0f, 5.0f);
				print("EXPO END");
				CBitStream params;
				this.SendCommand( this.getCommandID("force end"), params );
			}
		}
	}

	_expoMode ? this.Tag("expo mode") : this.Untag("expo mode");
}

void onStateChange(CRules@ this, const u8 oldState)
{
	const u8 state = this.getCurrentState();

	if (_expoMode && state == INTERMISSION)
	{
		_nobodyPlayingCounter = 0;
//		_expoMode = false;
	}

	if (_expoMode && (state == GAME_OVER || state == GAME))
	{
		_nobodyPlayingCounter = 0;
	}
}


void onRender(CRules@ this)
{
	if (this.get_s16("in menu") > 0)
		return;


	Driver@ driver = getDriver();
	Vec2f screenDim = driver.getScreenDimensions();
	Vec2f screenCenter = driver.getScreenCenterPos();

	if (_expoMode && !this.isIntermission())
	{
		if (this.isGameOver() || this.isWarmup()){
			GUI::DrawRectangle(Vec2f(0, 0), screenDim, color_black);
		}

		GUI::SetFont("menu");
		if (getGameTime() % 100 <= 50)
		{
			const string keyIcon = "$"+getControls().getActionKeyKeyName(AK_ACTION1)+"$";
			if (GUI::hasIconName(keyIcon)) {
				GUI::DrawTextCentered("  Press    to play!", screenCenter, Colours::WHITE);
				GUI::DrawIconByName(keyIcon, screenCenter + Vec2f(-20,-10), 0.5f);
			}
			else{
				GUI::DrawTextCentered("Press [" + getControls().getActionKeyKeyName(AK_ACTION1) + "] to play!", screenCenter, Colours::WHITE);
			}
		}
		else
		{
			GUI::DrawIcon("TitleScreen.png", 0, Vec2f(512, 128), screenCenter - Vec2f(512, 128)*0.5f, 0.5f);
		}
	}

	if (this.isIntermission())
	{
		Vec2f framesize = Vec2f(200, 64);
		GUI::DrawIcon("Sprites/UI/controls.png", 0, framesize, screenCenter - framesize * 0.5f, 0.5f);
	}

	// display title
	GUI::SetFont("hud");
	SColor color = color_white;//_expoMode ? (getGameTime() % 40 <= 20 ? SColor(Colours::RED) : color_white) : color_white;
	GUI::DrawTextCentered("TRENCH RUN by Transhuman Design [http://trenchrun.thd.vg]", Vec2f(screenCenter.x, screenDim.y - 7), color);
}
