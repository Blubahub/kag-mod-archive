#include "GameColours.as"
#include "SoldierCommon.as"
#include "ClassesCommon.as"
#include "MapCommon.as"

void onTick( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	Soldier::Data@ data = Soldier::getData( blob );

	bool moving = !data.onWall || data.vellen > 0.01f;
	bool runleft = data.left && !data.right && moving;
	bool runright = data.right && !data.left && moving;
	bool run = runleft || runright;

	if(blob.isMyPlayer())
		this.force_onrender = true;

	TileType backtile = blob.getMap().getTile( data.pos ).type;

	//anims

	if (!data.stunned && !data.dead)
	{
		this.ResetTransform();
	}

	if (data.dead || data.stunned)
	{
		if((this.isAnimation("bite") || this.isAnimation("agony")))
		{
			this.ResetTransform();
			if (this.isAnimationEnded())
			{
				this.SetAnimation("ground");
			}
		}
		else if(data.onGround)
		{
			if ((data.left || data.right) && !data.stunned)
			{
				this.SetAnimation("crawl");
			}
			else
			{
				this.SetAnimation("ground");
			}
			this.ResetTransform();
		}
		else if(data.airTime > 12 || data.stunned || data.onLadder)
		{
			Vec2f offset(0,6);
			if(!this.isAnimation("flip"))
			{
				//first setup stuff, maybe sound here?
				this.ResetTransform();
				this.TranslateBy(offset);
			}
			this.SetAnimation("flip");

			if(!data.onLadder)
			{
				f32 angle = Maths::Min(15.0f, 1.0f + (Maths::Abs(data.vel.x) + Maths::Abs(data.vel.y)) * 3.0f);
				this.RotateBy( data.facingLeft ? -angle : angle, offset * 2 );
			}

			//prevent endless spinning on wall when climbing
			if(data.onWall && data.dead && data.up)
			{
				this.ResetTransform();
				this.TranslateBy(offset);
			}
		}
	}
	else if (data.specialAnim)
	{
		// * done in class component *
	}
	else if (data.onLadder && !data.onGround/* && (backtile == TWMap::tile_ladder || backtile == TWMap::tile_ladder_dark)*/)
	{
		this.SetAnimation("ladder");
		this.animation.frame = (Maths::Abs(data.vel.y) < 0.1f || data.gametime % 10 < 5) ? 0 : 1;
	}
	else if (data.ledgeClimb)
	{
		this.SetAnimation("jump up");
	}
	else if (!data.onGround && !data.onLadder)
	{
		if (data.vel.y < 0.0f)
		{
			this.SetAnimation("jump up");
		}
		else
		{
			this.SetAnimation("jump down");
		}
	}
	else if (data.sliding)
	{
		if (!data.oldSliding)
		{
			this.SetAnimation("slide start");
		}
		else if (this.isAnimationEnded())
		{
			this.SetAnimation("slide");
		}
	}
	else if (data.crouching)
	{
		this.SetAnimation("crouch");
	}
	else if (run)
	{
		this.SetAnimation("run");
	}
	else
	{
		bool standupAnim = this.isAnimation("stand up");
		if (standupAnim || this.isAnimation("crouch"))
		{
			if (standupAnim && this.isAnimationEnded())
				this.SetAnimation("stand");
			else
				this.SetAnimation("stand up");
		}
		else
		{
			// default
			this.SetAnimation("stand");
		}
	}

	if (!data.specialAnim)
	{
		this.SetZ( data.pos.y / 1000.0f );
	}
}

void onRender( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	CBlob@ localBlob = getLocalPlayerBlob();
	CCamera@ camera = getCamera();
	CRules@ rules = getRules();

	if (localBlob is null || camera is null || rules.get_s16("in menu") > 0)
		return;

	//////////////////////////////////////
	// rendered for all team blobs
	//////////////////////////////////////

	Soldier::Data@ data = Soldier::getData( blob );
	CPlayer@ player = blob.getPlayer();
	const u32 time = getGameTime();

	if(data is null || player is null)
		return;

	//////////////////////////////////////
	// rendered just for us
	//////////////////////////////////////

	if (g_debug == 0 && !blob.isMyPlayer())
		return;

	if (data.crosshair)
	{
		Vec2f offset( data.crosshairOffset.x, data.crosshairOffset.y );
		if (data.crosshairTime < data.crosshairMinTime){
			offset /= Maths::Sqrt(float(data.crosshairMinTime - data.crosshairTime));
		}
		Vec2f shootpos = data.pos +
						 offset +
						 Soldier::getFireOffset(blob, data);

		Vec2f p = getDriver().getScreenPosFromWorldPos( shootpos );
		int frame = (data.crosshairTime > data.crosshairMinTime &&
			data.crosshairOffset.getLength() < data.defaultCrosshairDistance+2.0f && time % 12 < 6)
					? 1 : 0;

		GUI::DrawIcon( "Sprites/crosshair.png", frame, Vec2f(16,16), p - Vec2f(16,16)*camera.targetDistance, camera.targetDistance, getPlayerColor( player ) );
	}

	if(blob.isAttached())
	{
		if(data.stunTime == 0 && blob.isAttachedToPoint("ROCKET"))
		{
			CControls@ controls = blob.getControls();
			Vec2f p = getDriver().getScreenPosFromWorldPos( blob.getPosition() );
			GUI::DrawTextCentered("Jump off [" + controls.getActionKeyKeyName(AK_JUMP) + "]!", p, SColor(Colours::WHITE));
		}
	}
}

void DrawPlayerLabel( Vec2f pos, const string &in label )
{
	GUI::SetFont("hud");
    Vec2f dim;
    GUI::GetTextDimensions( label, dim );
	Vec2f name_ul = pos + Vec2f(0,8) - dim/4.0f;
	Vec2f name_lr = name_ul + dim/2.0f;
	name_ul = getDriver().getScreenPosFromWorldPos(name_ul);
	name_lr = getDriver().getScreenPosFromWorldPos(name_lr);
	name_ul.x += 16.0f;
	name_lr.x -= 16.0f;
	GUI::DrawRectangle( name_ul, name_lr, color_black );
	GUI::DrawText( label, name_ul + dim/4.0f + Vec2f(-16.0f, 0.0f), color_white );
}
