#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	this.RemoveSpriteLayer("forebush");
	CSpriteLayer@ forebush = this.addSpriteLayer("forebush", "NatureBeing.png" , 98, 89, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (forebush !is null)
	{
		Animation@ anim = forebush.addAnimation("default", 0, false);
		anim.AddFrame(1);
		forebush.SetRelativeZ(1000.0f);
	}
}


void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	
	bool show = blob.hasTag("summoned");

	if(!show){
		if(getLocalPlayerBlob() !is null){
			if(getLocalPlayerBlob().hasTag("spirit_view") || getLocalPlayerBlob().hasTag("onewithnature")){
				show = true;
				this.setRenderStyle(RenderStyle::additive);
			}
		}
	} else {
		this.setRenderStyle(RenderStyle::normal);
	}
	
	this.SetVisible(show);
	if(this.getSpriteLayer("forebush") !is null){
		this.getSpriteLayer("forebush").SetVisible(show);
	}
	if(!show)
	if(this.getSpriteLayer("bubble") !is null){
		this.getSpriteLayer("bubble").SetVisible(false);
	}
	
	this.SetAnimation("hover");

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
