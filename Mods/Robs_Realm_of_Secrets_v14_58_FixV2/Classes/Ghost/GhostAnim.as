// Shadowman animations

#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

void onInit(CSprite@ this)
{
	const string texname = "Ghost.png";
	this.ReloadSprite(texname);

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
}


void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	// animations

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2);
	const bool action1 = blob.isKeyPressed(key_action1);

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	Vec2f pos = blob.getPosition();

	RunnerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}

	string name = "clean";
	
	if(blob.get_s16("corruption") > 250){
		name = "dirty";
	}
	if(blob.get_s16("corruption") > 500){
		name = "filthy";
	}
	if(blob.get_s16("corruption") > 750 || blob.hasTag("evil")){
		name = "corrupt";
	}
	
	
	if ((left || right))
	{
		this.SetAnimation(name+"_hover");
		blob.SetFacingLeft(left);
		blob.SetFacingLeft(!right);
	} else {
		this.SetAnimation(name+"_float");
		if (blob.getAimPos().x < pos.x){
			blob.SetFacingLeft(true);
		} else {
			blob.SetFacingLeft(false);
		}
	}
	
	if(blob.get_s16("invisible") > 0)this.SetVisible(false);
	else {
		this.SetVisible(true);
		this.setRenderStyle(RenderStyle::normal);
	}
	
	if(getLocalPlayerBlob() !is null){
		if(getLocalPlayerBlob().hasTag("spirit_view")){
			if(this.isVisible() == false){
				this.SetVisible(true);
				this.setRenderStyle(RenderStyle::additive);
			}
		}
	}
}

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

// render cursors

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}
}
