// TDM Ruins logic

#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "RespawnCommandCommon.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;

	this.getSprite().SetZ(-50.0f);   // push to background
}