// include this in gamemode.cfg rules for menus to work
#define ALWAYS_ONRELOAD
#include "UI.as"

void onInit( CRules@ this )
{
	UI::Init( this );
}

void onReset( CRules@ this )
{
	onInit( this );
}

void onReload( CRules@ this )
{
	onReset( this );
}

void onTick( CRules@ this )
{
    CPlayer@ local = getLocalPlayer();
    if (local is null)
        return;

	UI::Tick( this );
}

void onRender( CRules@ this )
{
    UI::Render( this );
}

