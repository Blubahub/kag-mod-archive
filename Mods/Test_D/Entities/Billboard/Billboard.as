#include "HoverMessage.as"
#include "GameColours.as"
#include "BackendCommon.as"
#include "LobbyCommon.as"
#include "LobbyStatsCommon.as"
#include "Timers.as"
//so we can hide when rendering menus..
#include "UI.as"


//TODO: paged rendering;
//		- server
// 		- players
//		- games played
// 		- countdown (priority)

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(-800);
}

void onTick(CBlob@ this)
{

}

void onInit(CSprite@ this)
{

}
