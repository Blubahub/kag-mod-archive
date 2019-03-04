#include "ActionKeys.as"

int _timeStart = 0;
s32 _startKey;
s32 _oldlastKeyPressed = 0;
funcdef void RETURN_FUNCTION( CRules@ );

void onInit( CRules@ this )
{
	const u32 controlIndex = this.get_u32("modify controls");
	_timeStart = getGameTime();
	CControls@ controls = getControls(controlIndex);
	_startKey = controls.lastKeyPressed;
}

void onTick( CRules@ this )
{
	const u32 controlIndex = this.get_u32("modify controls");
	CControls@ mainControls = getControls();
	CControls@ controls = getControls(controlIndex);
	const u32 time = getGameTime();
	mainControls.externalControl = true; // global!

	// init cause onInit wont be called
	//printf("time " + time + " _timeStart " + _timeStart + " _startKey " + _startKey + " controls.lastKeyPressed " + controls.lastKeyPressed);
	if (_timeStart == 0){
		onInit( this );
	}

	// prevent key from menu to interfer

	if (_startKey == mainControls.lastKeyPressed)
		return;
	_startKey = -1;

	// not too soon to prevent mistakes

	if (time - _timeStart < 10)
		return;

	const string key = this.get_string("modify key");

	// cancel with escape

	if (mainControls.lastKeyPressed == KEY_ESCAPE)
	{
		Exit( this );
		return;
	}
	else if (mainControls.lastKeyPressed > 0) 
	{
		_oldlastKeyPressed = mainControls.lastKeyPressed;
	}
	else
	{
		// set key on release
		if (_oldlastKeyPressed > 0 && mainControls.lastKeyPressed == 0)
		{
			printf("SET KEY " + getActionKeyFromString(key) + " for " + key );
			controls.MapActionKey( getActionKeyFromString(key), _oldlastKeyPressed );
			Exit( this );
		}
		_oldlastKeyPressed = 0;
	}
}

void onRender( CRules@ this )
{
	Driver@ driver = getDriver();
	Vec2f screenSize( driver.getScreenWidth(), driver.getScreenHeight() );
	const u32 time = getGameTime();
	const string key = this.get_string("modify key");

	if (time % 15 < 6){
		GUI::DrawRectangle( Vec2f(0,0), screenSize, SColor(162,0,0,0) );
	}
	else{
		GUI::DrawRectangle( Vec2f(0,0), screenSize, SColor(202,0,0,0) );
		GUI::DrawTextCentered( "Press a key for... " + key + "", screenSize*0.5f, color_white );
	}
}


void Exit( CRules@ this )
{
	getControls().externalControl = false;
	_timeStart = 0;
	this.RemoveScript("modifykey");

	RETURN_FUNCTION@ ReturnToInputMenu;
	this.get("modify key callback", @ReturnToInputMenu );
	ReturnToInputMenu( this );

	printf("EXIT KEY MODIFY");
}