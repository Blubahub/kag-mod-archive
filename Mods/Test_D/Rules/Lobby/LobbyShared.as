#include "ClassesCommon.as"
#include "Timers.as"
#include "GamemodeCommon.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "BackendHelper.as"
#include "InterServerPlayerSync.as"
#include "LobbyStatsCommon.as"

void onInit(CRules@ this)
{
	ClearClasses(this);
	AddClass(this, Soldier::CIVILIAN);

	this.set_bool("fog of war", false);
	this.set_bool("respawning", false);
	this.set_bool("infinite ammo", false);
	this.set_bool("infinite grenades", false);

	this.set_string("gamemode", "Lobby");

	this.Tag("use_backend");
}
