#include "Hitters.as";
#include "RespawnCommandCommon.as"
#include "StandardRespawnCommand.as"

void onInit( CBlob@ this )
{
	this.set_string("required class", "builder");
	this.Tag("undyingOnly");
}