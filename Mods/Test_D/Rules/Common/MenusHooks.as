// include this in gamemode.cfg rules for menus to work
#include "Menus.as"

void onInit( CRules@ this )
{	
	this.addCommandID(Menus::CMD_STRING);
	Reset( this );
}

void onReset( CRules@ this )
{
    Reset( this );
}

void onReload( CRules@ this )
{
    Reset( this );
}

void Reset( CRules@ this )
{
	Menus::Clear();
	for (int p_it=0; p_it < getLocalPlayersCount(); p_it++){
		CPlayer@ player = getLocalPlayer(p_it);
		if (player is null)
			continue;
		Menus::Init( this, player );
	}	
}

void onTick( CRules@ this )
{
    CPlayer@ local = getLocalPlayer();
    if (local is null)
        return;

    Menus::Control( this );
}

void onRender( CRules@ this )
{
    Menus::Render( this );
}