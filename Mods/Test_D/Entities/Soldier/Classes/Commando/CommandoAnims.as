#include "SoldierCommon.as"
#include "GameColours.as"

void onInit(CSprite@ this)
{
	this.ReloadSprite( "actor_commando.png" ); // fixes engine bug (consts.filename = filename not set in ReloadSprite overload)
	this.ReloadSprite("actor_commando.png", 24, 24, Soldier::getTeamColorForSprite(this.getBlob()), 0 );

	{
		Animation@ anim = this.addAnimation("stand", 0, false);
		anim.AddFrame(0);
	}
	{
		Animation@ anim = this.addAnimation("run", 3, true);
		int[] frames = {2, 3, 4, 7, 8, 9};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("jump up", 3, false);
		int[] frames = {15, 16, 17};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("jump down", 3, false);
		int[] frames = {17, 18, 19};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("stab", 2, false);
		int[] frames = {20, 21, 22, 23, 24};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("drop", 2, false);
		int[] frames = {25, 26, 27, 28};
		anim.AddFrames(frames);
	}


	{
		Animation@ anim = this.addAnimation("crouch", 2, false);
		int[] frames = {10, 11, 12};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("stand up", 1, false);
		int[] frames = {12, 13, 10};
		anim.AddFrames(frames);
	}

	{
		Animation@ anim = this.addAnimation("slide start", 3, false);
		int[] frames = {13, 5, 6};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("slide", 3, true);
		int[] frames = {5, 6};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("die", 2, false);
		int[] frames = {10, 11, 12, 30};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("ground", 0, false);
		anim.AddFrame(30);
	}
	{
		Animation@ anim = this.addAnimation("fall up", 0, false);
		anim.AddFrame(22);
	}
	{
		Animation@ anim = this.addAnimation("fall down", 0, false);
		anim.AddFrame(24);
	}
	{
		Animation@ anim = this.addAnimation("crawl", 3, true);
		int[] frames = {30, 31, 31, 30, 32, 32};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("bite", 3, false);
		int[] frames = {32, 32, 31};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("agony", 5, false);
		int[] frames = {31, 31, 30, 31, 30};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("hold wall", 0, false);
		int[] frames = {14};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("climb up wall", 4, true);
		int[] frames = {35, 36, 37, 38};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("climb down wall", 4, true);
		int[] frames = {38, 37, 36, 35};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("flip", 4, false);
		int[] frames = {1};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("ladder", 0, false);
		int[] frames = {33, 34};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("charge knife", 3, true);
		int[] frames = {40, 41, 42, 43};
		anim.AddFrames(frames);
	}
}


void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Soldier::Data@ data = Soldier::getData(blob);

	if (data.dead)
		return;

	data.specialAnim = data.wallGrab ||
	                   ((data.fire || blob.isKeyJustReleased(key_action1)) &&
	                    data.shotTime >= 0) ||
	                   this.isAnimation("stab") ||
	                   (blob.isKeyJustPressed(key_action2) ||
	                    this.isAnimation("drop"));

	if (data.specialAnim)
	{
		if (data.fire && !this.isAnimation("stab"))
		{
			this.SetAnimation("charge knife");
		}
		else if (blob.isKeyJustPressed(key_action2))
		{
			this.SetAnimation("drop");
			this.getAnimation("drop").frame = 0;
		}
		else if (data.wallGrab)
		{
			if (data.up)
			{
				this.SetAnimation("climb up wall");
			}
			else if (data.down)
			{
				this.SetAnimation("climb down wall");
			}
			else
			{
				this.SetAnimation("hold wall");
			}
		}
		else if (this.isAnimationEnded())
		{
			data.specialAnim = false;
		}
	}
}

void onRender( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
		return;

    CBlob@[] bombs;
    if (getBlobsByName( "remotebomb", @bombs ))
	{
		for (u32 i = 0; i < bombs.length; i++)
		{
			CBlob@ bomb = bombs[i];
			if (blob.getDistanceTo(bomb) < blob.getRadius() + bomb.getRadius())
			{
				CControls@ controls = blob.getControls();
				Vec2f p = getDriver().getScreenPosFromWorldPos( blob.getPosition() );
				GUI::DrawTextCentered("Disarm! [" + controls.getActionKeyKeyName(AK_ACTION1) + "]", p, SColor(Colours::WHITE));
			}
		}
	}
}