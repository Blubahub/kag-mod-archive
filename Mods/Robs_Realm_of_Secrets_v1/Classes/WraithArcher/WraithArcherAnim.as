// WraithArcher animations

#include "WraithArcherCommon.as"
#include "FireParticle.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

const f32 config_offset = -4.0f;
const string shiny_layer = "shiny bit";

void onInit(CSprite@ this)
{
	LoadSprites(this);
}

void LoadSprites(CSprite@ this)
{
	string texname = "WraithArcher.png";
	this.ReloadSprite(texname, this.getConsts().frameWidth, this.getConsts().frameHeight,
	                  this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	this.RemoveSpriteLayer("frontarm");
	CSpriteLayer@ frontarm = this.addSpriteLayer("frontarm", texname , 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontarm !is null)
	{
		Animation@ animcharge = frontarm.addAnimation("charge", 0, false);
		animcharge.AddFrame(16);
		animcharge.AddFrame(24);
		animcharge.AddFrame(32);
		Animation@ animshoot = frontarm.addAnimation("fired", 0, false);
		animshoot.AddFrame(40);
		Animation@ animnoarrow = frontarm.addAnimation("no_arrow", 0, false);
		animnoarrow.AddFrame(25);
		frontarm.SetOffset(Vec2f(-1.0f, 5.0f + config_offset));
		frontarm.SetAnimation("fired");
		frontarm.SetVisible(false);
	}

	this.RemoveSpriteLayer("backarm");
	CSpriteLayer@ backarm = this.addSpriteLayer("backarm", texname , 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(17);
		backarm.SetOffset(Vec2f(-1.0f, 5.0f + config_offset));
		backarm.SetAnimation("default");
		backarm.SetVisible(false);
	}

	//quiver
	this.RemoveSpriteLayer("quiver");
	CSpriteLayer@ quiver = this.addSpriteLayer("quiver", texname , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (quiver !is null)
	{
		Animation@ anim = quiver.addAnimation("default", 0, false);
		anim.AddFrame(67);
		anim.AddFrame(66);
		quiver.SetOffset(Vec2f(-10.0f, 2.0f + config_offset));
		quiver.SetRelativeZ(-0.1f);
	}

	// add shiny
	this.RemoveSpriteLayer(shiny_layer);
	CSpriteLayer@ shiny = this.addSpriteLayer(shiny_layer, "AnimeShiny.png", 16, 16);

	if (shiny !is null)
	{
		Animation@ anim = shiny.addAnimation("default", 2, true);
		int[] frames = {0, 1, 2, 3};
		anim.AddFrames(frames);
		shiny.SetVisible(false);
		shiny.SetRelativeZ(8.0f);
	}
}

void setArmValues(CSpriteLayer@ arm, bool visible, f32 angle, f32 relativeZ, string anim, Vec2f around, Vec2f offset)
{
	if (arm !is null)
	{
		arm.SetVisible(visible);

		if (visible)
		{
			if (!arm.isAnimation(anim))
			{
				arm.SetAnimation(anim);
			}

			arm.SetOffset(offset);
			arm.ResetTransform();
			arm.SetRelativeZ(relativeZ);
			arm.RotateBy(angle, around);
		}
	}
}

// stuff for shiny - global cause is used by a couple functions in a tick
bool needs_shiny = false;
Vec2f shiny_offset;
f32 shiny_angle = 0.0f;

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		if (this.animation.name != "dead")
		{
			this.SetAnimation("dead");
			this.RemoveSpriteLayer("frontarm");
			this.RemoveSpriteLayer("backarm");
			this.RemoveSpriteLayer(shiny_layer);
		}

		doQuiverUpdate(this, false, true);

		Vec2f vel = blob.getVelocity();

		if (vel.y < -1.0f)
		{
			this.SetFrameIndex(0);
		}
		else if (vel.y > 1.0f)
		{
			this.SetFrameIndex(1);
		}
		else
		{
			this.SetFrameIndex(2);
		}

		return;
	}

	WraithArcherInfo@ WraithArcher;
	if (!blob.get("WraithArcherInfo", @WraithArcher))
	{
		return;
	}

	// animations
	const bool firing = IsFiring(blob);
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	bool legolas = WraithArcher.charge_state == WraithArcherParams::legolas_ready || WraithArcher.charge_state == WraithArcherParams::legolas_charging;
	needs_shiny = false;
	bool crouch = false;

	const u8 knocked = getKnocked(blob);
	Vec2f pos = blob.getPosition();
	Vec2f aimpos = blob.getAimPos();
	// get the angle of aiming with mouse
	Vec2f vec = aimpos - pos;
	f32 angle = vec.Angle();

	string name = "clean";
	
	if(blob.get_s16("corruption") > 21){
		name = "dirty";
	}
	if(blob.get_s16("corruption") > 100){
		name = "filthy";
	}
	if(blob.get_s16("corruption") > 250){
		name = "corrupt";
	}
	
	string modpath = "../Mods/Robs_Realm_of_Secrets/Classes/WraithArcher/";
	
	if("WraithKnight_"+name+".png" != this.getFilename()){
		this.ReloadSprite(modpath+"WraithArcher_"+name);
		if(this.getSpriteLayer("frontarm") !is null)
		this.getSpriteLayer("frontarm").ReloadSprite(modpath+"WraithArcher_"+name,32,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if(this.getSpriteLayer("backarm") !is null)
		this.getSpriteLayer("backarm").ReloadSprite(modpath+"WraithArcher_"+name,32,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if(this.getSpriteLayer("quiver") !is null)
		this.getSpriteLayer("quiver").ReloadSprite(modpath+"WraithArcher_"+name,16,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if(this.getSpriteLayer("hook") !is null)
		this.getSpriteLayer("hook").ReloadSprite(modpath+"WraithArcher_"+name,16,8,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if(this.getSpriteLayer("rope") !is null)
		this.getSpriteLayer("rope").ReloadSprite(modpath+"WraithArcher_"+name,32,8,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	}
	
	if (knocked > 0)
	{
		if (inair)
		{
			this.SetAnimation("knocked_air");
		}
		else
		{
			this.SetAnimation("knocked");
		}
	}
	else if (blob.hasTag("seated"))
	{
		this.SetAnimation("default");
	}
	else if (firing || legolas)
	{
		if (inair)
		{
			this.SetAnimation("shoot_jump");
		}
		else if ((left || right) ||
		         (blob.isOnLadder() && (up || down)))
		{
			this.SetAnimation("shoot_run");
		}
		else
		{
			this.SetAnimation("shoot");
		}
	}
	else if (inair)
	{
		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}
		Vec2f vel = blob.getVelocity();
		f32 vy = vel.y;
		if (vy < -0.0f && moveVars.walljumped)
		{
			this.SetAnimation("run");
		}
		else
		{
			this.SetAnimation("fall");
			this.animation.timer = 0;

			if (vy < -1.5)
			{
				this.animation.frame = 0;
			}
			else if (vy > 1.5)
			{
				this.animation.frame = 2;
			}
			else
			{
				this.animation.frame = 1;
			}
		}
	}
	else if ((left || right) ||
	         (blob.isOnLadder() && (up || down)))
	{
		this.SetAnimation("run");
	}
	else
	{
		if (down && this.isAnimationEnded())
			crouch = true;

		int direction;

		if ((angle > 330 && angle < 361) || (angle > -1 && angle < 30) ||
		        (angle > 150 && angle < 210))
		{
			direction = 0;
		}
		else if (aimpos.y < pos.y)
		{
			direction = -1;
		}
		else
		{
			direction = 1;
		}

		defaultIdleAnim(this, blob, direction);
	}

	//arm anims
	Vec2f armOffset = Vec2f(-1.0f, 4.0f + config_offset);
	const u8 arrowType = getArrowType(blob);

	if (firing || legolas)
	{
		f32 armangle = -angle;

		if (this.isFacingLeft())
		{
			armangle = 180.0f - angle;
		}

		while (armangle > 180.0f)
		{
			armangle -= 360.0f;
		}

		while (armangle < -180.0f)
		{
			armangle += 360.0f;
		}

		DrawBow(this, blob, WraithArcher, armangle, arrowType, armOffset);
	}
	else
	{
		setArmValues(this.getSpriteLayer("frontarm"), false, 0.0f, 0.1f, "fired", Vec2f(0, 0), armOffset);
		setArmValues(this.getSpriteLayer("backarm"), false, 0.0f, -0.1f, "default", Vec2f(0, 0), armOffset);
	}

	//set the shiny dot on the arrow

	CSpriteLayer@ shiny = this.getSpriteLayer(shiny_layer);
	if (shiny !is null)
	{
		shiny.SetVisible(needs_shiny);
		if (needs_shiny)
		{
			shiny.RotateBy(10, Vec2f());

			shiny_offset.RotateBy(this.isFacingLeft() ?  shiny_angle : -shiny_angle);
			shiny.SetOffset(shiny_offset);
		}
	}

	DrawBowEffects(this, blob, WraithArcher, arrowType);

	//set the head anim
	if (knocked > 0 || crouch)
	{
		blob.Tag("dead head");
	}
	else if (blob.isKeyPressed(key_action1))
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}


}

void DrawBow(CSprite@ this, CBlob@ blob, WraithArcherInfo@ WraithArcher, f32 armangle, const u8 arrowType, Vec2f armOffset)
{
	f32 sign = (this.isFacingLeft() ? 1.0f : -1.0f);
	CSpriteLayer@ frontarm = this.getSpriteLayer("frontarm");

	if (!WraithArcher.has_arrow || WraithArcher.charge_state == WraithArcherParams::no_arrows || WraithArcher.charge_state == WraithArcherParams::legolas_charging)
	{
		string animname = "no_arrow";

		if (WraithArcher.charge_time == WraithArcherParams::ready_time)
		{
			animname = "fired";
		}

		u16 frontframe = 0;
		f32 temp = Maths::Min(WraithArcher.charge_time, WraithArcherParams::ready_time);
		f32 ready_tween = temp / WraithArcherParams::ready_time;
		armangle = armangle * ready_tween;
		armOffset = Vec2f(-1.0f, 4.0f + config_offset + 2.0f * (1.0f - ready_tween));
		setArmValues(frontarm, true, armangle, 0.1f, animname, Vec2f(-4.0f * sign, 0.0f), armOffset);
		frontarm.animation.frame = frontframe;
	}
	else if (WraithArcher.charge_state == WraithArcherParams::readying)
	{
		u16 frontframe = 0;
		f32 temp = WraithArcher.charge_time;
		f32 ready_tween = temp / WraithArcherParams::ready_time;
		armangle = armangle * ready_tween;
		armOffset = Vec2f(-1.0f, 4.0f + config_offset + 2.0f * (1.0f - ready_tween));
		setArmValues(frontarm, true, armangle, 0.1f, "charge", Vec2f(-4.0f * sign, 0.0f), armOffset);
		frontarm.animation.frame = frontframe;
		f32 offsetChange = -5 + ready_tween * 5;
	}
	else if (WraithArcher.charge_state != WraithArcherParams::fired || WraithArcher.charge_state == WraithArcherParams::legolas_ready)
	{
		u16 frontframe = Maths::Min((WraithArcher.charge_time / (WraithArcherParams::shoot_period_1 + 1)), 2);
		setArmValues(frontarm, true, armangle, 0.1f, "charge", Vec2f(-4.0f * sign, 0.0f), armOffset);
		frontarm.animation.frame = frontframe;

		const f32 frameOffset = 1.5f * float(frontframe);

		if (WraithArcher.charge_state == WraithArcherParams::legolas_ready)
		{
			needs_shiny = true;
			shiny_offset = Vec2f(-12.0f, 0.0f);   //TODO:
			shiny_angle = armangle;
		}
	}
	else
	{
		setArmValues(frontarm, true, armangle, 0.1f, "fired", Vec2f(-4.0f * sign, 0.0f), armOffset);
	}

	frontarm.SetRelativeZ(1.5f);
	setArmValues(this.getSpriteLayer("backarm"), true, armangle, -0.1f, "default", Vec2f(-4.0f * sign, 0.0f), armOffset);

	// fire arrow particles

	if (arrowType == ArrowType::fire && getGameTime() % 6 == 0)
	{
		Vec2f offset = Vec2f(12.0f, 0.0f);

		if (this.isFacingLeft())
		{
			offset.x = -offset.x;
		}

		offset.RotateBy(armangle);
		makeFireParticle(frontarm.getWorldTranslation() + offset, 4);
	}
}

void DrawBowEffects(CSprite@ this, CBlob@ blob, WraithArcherInfo@ WraithArcher, const u8 arrowType)
{
	// set fire light

	if (arrowType == ArrowType::fire)
	{
		if (IsFiring(blob))
		{
			blob.SetLight(true);
			blob.SetLightRadius(blob.getRadius() * 2.0f);
		}
		else
		{
			blob.SetLight(false);
		}
	}

	//quiver
	bool has_arrows = blob.get_bool("has_arrow");
	doQuiverUpdate(this, has_arrows, true);
}

bool IsFiring(CBlob@ blob)
{
	return blob.isKeyPressed(key_action1);
}

void doQuiverUpdate(CSprite@ this, bool has_arrows, bool quiver)
{
	CSpriteLayer@ quiverLayer = this.getSpriteLayer("quiver");

	if (quiverLayer !is null)
	{
		if (quiver)
		{
			quiverLayer.SetVisible(true);
			f32 quiverangle = -45.0f;

			if (this.isFacingLeft())
			{
				quiverangle *= -1.0f;
			}

			PixelOffset @po = getDriver().getPixelOffset(this.getFilename(), this.getFrame());

			bool down = (this.isAnimation("crouch") || this.isAnimation("dead"));
			bool easy = false;
			Vec2f off;
			if (po !is null)
			{
				easy = true;
				off.Set(this.getFrameWidth() / 2, -this.getFrameHeight() / 2);
				off += this.getOffset();
				off += Vec2f(-po.x, po.y);


				f32 y = (down ? 3.0f : 7.0f);
				f32 x = (down ? 5.0f : 4.0f);
				off += Vec2f(x, y + config_offset);
			}

			if (easy)
			{
				quiverLayer.SetOffset(off);
			}

			quiverLayer.ResetTransform();
			quiverLayer.RotateBy(quiverangle, Vec2f(0.0f, 0.0f));

			if (has_arrows)
			{
				quiverLayer.animation.frame = 1;
			}
			else
			{
				quiverLayer.animation.frame = 0;
			}
		}
		else
		{
			quiverLayer.SetVisible(false);
		}
	}
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0f;
	const u8 team = blob.getTeamNum();
	CParticle@ Body     = makeGibParticle("Entities/Characters/WraithArcher/WraithArcherGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm      = makeGibParticle("Entities/Characters/WraithArcher/WraithArcherGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Entities/Characters/WraithArcher/WraithArcherGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Entities/Characters/WraithArcher/WraithArcherGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}
