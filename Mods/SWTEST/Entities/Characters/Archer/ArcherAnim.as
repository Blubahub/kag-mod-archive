// Archer animations

#include "ArcherCommon.as"
#include "FireParticle.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "Hitters.as";
#include "ExtraSparks.as";

const f32 config_offset = -4.0f;

void onInit(CSprite@ this)
{
	LoadSprites(this);
	this.SetEmitSound("SaberHum.ogg");
	this.SetEmitSoundPaused(false);
}

void LoadSprites(CSprite@ this)
{
	string texname =  "Entities/Characters/Archer/ArcherMale.png";
	string armname =  "Entities/Characters/Archer/Arms.png";
	this.ReloadSprite(texname, this.getConsts().frameWidth, this.getConsts().frameHeight,
	                  this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	this.RemoveSpriteLayer("frontarm");
	CSpriteLayer@ frontarm = this.addSpriteLayer("frontarm", texname, 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontarm !is null)
	{
		Animation@ anim = frontarm.addAnimation("default", 0, false);
		anim.AddFrame(1);
		Animation@ animlow = frontarm.addAnimation("lowanim", 0, false);
		animlow.AddFrame(1);
		frontarm.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		frontarm.SetAnimation("fired");
		frontarm.SetVisible(false);
	}

	this.RemoveSpriteLayer("saber");
	CSpriteLayer@ saber = this.addSpriteLayer("saber", "Saber.png", 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (saber !is null)
	{
		Animation@ anim = saber.addAnimation("default", 0, false);
		anim.AddFrame(1);
		saber.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		saber.SetVisible(false);
		saber.SetRelativeZ(0.3);
	}

	this.RemoveSpriteLayer("backarm");
	CSpriteLayer@ backarm = this.addSpriteLayer("backarm", texname, 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(1);
		Animation@ shortanim = backarm.addAnimation("short", 0, false);
		shortanim.AddFrame(1);
		Animation@ tinyanim = backarm.addAnimation("tiny", 0, false);
		tinyanim.AddFrame(1);
		Animation@ lowanim = backarm.addAnimation("low", 0, false);
		lowanim.AddFrame(1);
		Animation@ loweranim = backarm.addAnimation("lower", 0, false);
		loweranim.AddFrame(1);
		Animation@ shortestanim = backarm.addAnimation("shortest", 0, false);
		shortestanim.AddFrame(1);
		backarm.SetOffset(Vec2f(-20.0f, 10.0f + config_offset));
		backarm.SetAnimation("default");
		backarm.SetVisible(false);
	}



}

void setArmValues(CBlob@ blob, CSpriteLayer@ arm, bool visible, f32 angle, f32 relativeZ, string anim, Vec2f around, Vec2f offset)
{
	CSpriteLayer@ saber = blob.getSprite().getSpriteLayer("saber");
	int facing = blob.isFacingLeft() ? 1 : -1;
	bool face = blob.isFacingLeft();

	if (saber !is null)
	{

		Vec2f aimpos = blob.getAimPos();
		saber.SetVisible(visible);
		Vec2f pos = blob.getPosition();
		Vec2f diff = aimpos - pos;
		diff.Normalize();
		Vec2f offset2 = diff*9;//*facing;

		if(!blob.isFacingLeft())
		{
			offset2.x = offset2.x * -1;
		}		
		if(blob.isFacingLeft() && angle > 70)
		{
			angle = angle -((angle-70)*2);
		}

		if(!blob.isFacingLeft() && angle < -70)
		{
			angle = angle -((angle+70)*2);
		}
		saber.SetOffset(offset2);
		saber.ResetTransform();
		saber.TranslateBy(Vec2f(1.0f, 2.0f));

		f32 angles = angle-(angle*facing)*(-facing);
		print(""+angle);
		saber.RotateBy(angles, around);


		f32 lastangle = blob.get_f32("lastangle");
		bool lastface = blob.get_bool("lastface");
		bool changed = (lastface != face);
		if(lastangle > angles + 50 || lastangle < angles- 50 )
		{
			CSprite@ sprite = blob.getSprite();

			if (blob.getTickSinceCreated() > 30 && !changed)
			{			
				blob.SendCommand(blob.getCommandID("swingsound"));	
				/*if(sprite !is null)
				{
					string hitsound = ("Saber"+XORRandom(3)+".ogg");
					sprite.PlaySound(hitsound);
				}*/
			 	CBlob@[] blobsInRadius;
	 			if(!blob.isFacingLeft())
				{
					offset2.x = offset2.x * -1;
				}
			 	Vec2f hitpos = pos + (offset2*2.5);
			  	if (blob.getMap().getBlobsInRadius(hitpos, 10.0f, @blobsInRadius))
			 	{
			 		for (uint i = 0; i < blobsInRadius.length; i++)
			 		{		
						CBlob @b = blobsInRadius[i];
						u32 lasthit = blob.get_u32("lasthit");
						if(b.getTeamNum() != blob.getTeamNum() && lasthit < 1)
						{

							b.server_Hit(b, hitpos, offset2*50, 1.0f, Hitters::burn, false);
							b.server_Hit(b, hitpos, offset2*50, 1.0f, Hitters::sword, false);
							b.AddForce(offset2*(b.getMass()/2));
							mapSparks(hitpos, 0.0f, 5.0f);	
							blob.SendCommand(blob.getCommandID("hitsound"));
							blob.set_u32("lasthit", 30);

						}
			 		}
				}

			}
		}
		blob.set_f32("lastangle", angles);
		blob.set_bool("lastface", face);

	}

	if (arm !is null)
	{
		arm.SetVisible(visible);

		if (visible)
		{
			if (!arm.isAnimation(anim))
			{
				arm.SetAnimation(anim);
			}
			offset = Vec2f(-2, -2);
			arm.SetOffset(offset);
			arm.ResetTransform();
			arm.SetRelativeZ(relativeZ);
			u32 lastfire = blob.get_u32("lastfire");
			f32 angles = angle-lastfire;
			arm.RotateBy(angles, around);
		}
	}
}

void setArmValues2(CBlob@ blob, CSpriteLayer@ arm, bool visible, f32 angle,  f32 angle2, f32 relativeZ, string anim, Vec2f around, Vec2f offset)
{
	if (arm !is null)
	{
		arm.SetVisible(visible);


		if (visible) 
		{
			//print("arm angle: " + angle2);

			if(-angle2 > 0 && -angle2 <= 45)
			{
				if (!arm.isAnimation("short")) 
				{
					arm.SetAnimation("short");
				}
				f32 rise = -angle2*0.1;
				offset = Vec2f(-9, -(1+(rise/3)));
			}						
			if(-angle2 > 45 && -angle2 <= 90)
			{
				if (!arm.isAnimation("default"))
				{
					arm.SetAnimation("default");
				}
				f32 rise = -angle2*0.1;
				offset = Vec2f(-9, -(1+(rise/3)));
			}						

			if(-angle2 < 27 && -angle2 > 0)
			{
				if (!arm.isAnimation("tiny"))
				{
					arm.SetAnimation("tiny");
				}
				//f32 anglerise = (90- (-angle2-90));
				//f32 rise = anglerise*0.1;
				//offset = Vec2f(-9, -(1+(rise/3)));
				angle = angle*(-angle/27);
				offset = Vec2f(-9, -1);
			}			

			if(angle2 >= 0 && angle2 < 27)
			{
				if (!arm.isAnimation("shortest"))
				{
					arm.SetAnimation("shortest");
				}
				//f32 anglerise = (90- (-angle2-90));
				//f32 rise = anglerise*0.1;
				//offset = Vec2f(-9, -(1+(rise/3)));
				angle = 25+angle*(1.5f+(angle/120));//*(angle/27);
				offset = Vec2f(-9, -1);
			}							

			if(angle2 >= 27 && angle2 < 45)
			{
				if (!arm.isAnimation("low"))
				{
					arm.SetAnimation("low");
				}
				//f32 anglerise = (90- (-angle2-90));
				//f32 rise = anglerise*0.1;
				//offset = Vec2f(-9, -(1+(rise/3)));
				angle = 30+angle*(1.2f/*+(angle/100)*/);//*(angle/27);
				offset = Vec2f(-9, -1);
			}			
			if(angle2 >= 45)
			{
				if (!arm.isAnimation("lower"))
				{
					arm.SetAnimation("lower");
				}  
				//f32 anglerise = (90- (-angle2-90));
				//f32 rise = anglerise*0.1;
				//offset = Vec2f(-9, -(1+(rise/3)));
				angle = angle*(1.2);
				f32 offi = (angle2-45)/45;
				offset = Vec2f((-9)+offi, -1);
			}							

			/*if(-angle2 < 0)
			{
				offset = Vec2f(-9, -2);
			}*/
			
			arm.SetOffset(offset);
			arm.ResetTransform();
			arm.SetRelativeZ(relativeZ);
			u32 lastfire = blob.get_u32("lastfire");
			f32 angles = angle-lastfire;
			arm.RotateBy(angles, around);

			CSprite@ sprite = blob.getSprite();
			if(sprite !is null)
			{
				CSpriteLayer@ frontarm = sprite.getSpriteLayer("frontarm");
				if (frontarm !is null)
				{
					if (angle2 > 45 && !frontarm.isAnimation("lowanim"))
					{
						frontarm.SetAnimation("lowanim");
					}  

					if (angle2 < 45 && !frontarm.isAnimation("default"))
					{
						frontarm.SetAnimation("default");
					}  

				}

			}
		}
	}
}


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
		}

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

	ArcherInfo@ archer;
	if (!blob.get("archerInfo", @archer))
	{
		return;
	}


	// animations
	const bool aiming = IsAiming(blob);
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	bool legolas = IsAiming(blob); //archer.charge_state == ArcherParams::legolas_ready || archer.charge_state == ArcherParams::legolas_charging;
	bool crouch = false;

	const u8 knocked = getKnocked(blob);
	Vec2f pos = blob.getPosition();
	Vec2f pos2 = Vec2f(blob.getPosition().x+(this.isFacingLeft() ? -6 : 6), blob.getPosition().y);

	Vec2f aimpos = blob.getAimPos();

	// get the angle of aiming with mouse
	Vec2f vec = aimpos - pos;
	Vec2f vec2 = aimpos - pos2;
	vec2.Normalize();
	vec2 *= 10;
	f32 angle = vec.Angle();
	f32 angle2 = vec2.Angle();
	//print("angle: "+angle);

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
	else if (aiming)
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
	Vec2f armOffset = Vec2f(72.0f, 52.0f + config_offset);
	const u8 arrowType = getArrowType(blob);

	if (aiming)
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

		f32 armangle2 = armangle *1.5;
		DrawGun(this, blob, archer, armangle, armangle2, arrowType, armOffset);
	}
	if (!aiming)
	{
		HideGun(this);
	}

	//set the head anim
	if (knocked > 0 || crouch)
	{
		blob.Tag("dead head");
	}
	else if (blob.isKeyPressed(key_action2))
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

void DrawGun(CSprite@ this, CBlob@ blob, ArcherInfo@ archer, f32 armangle, f32 armangle2, const u8 arrowType, Vec2f armOffset)
{
	f32 sign = (this.isFacingLeft() ? 1.0f : -1.0f);
	CSpriteLayer@ frontarm = this.getSpriteLayer("frontarm");


	setArmValues(this.getBlob(), frontarm, true, armangle, 0.5f, "fired", Vec2f(-4.0f * sign, 0.0f), armOffset);
	frontarm.SetRelativeZ(1.5f);
	setArmValues2(this.getBlob(), this.getSpriteLayer("backarm"), true, armangle2, armangle, 0.1f, "default", Vec2f(-4.0f * sign, 0.0f), armOffset);

	// fire arrow particles

}
void HideGun(CSprite@ this)
{
	CSpriteLayer@ frontarm = this.getSpriteLayer("frontarm");
	CSpriteLayer@ backarm = this.getSpriteLayer("backarm");


	frontarm.SetVisible(false);

	backarm.SetVisible(false);
	// fire arrow particles

}

bool IsAiming(CBlob@ blob)
{
	return blob.isKeyPressed(key_action2);
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
	CParticle@ Body     = makeGibParticle("Entities/Characters/Archer/ArcherGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm      = makeGibParticle("Entities/Characters/Archer/ArcherGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Entities/Characters/Archer/ArcherGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Entities/Characters/Archer/ArcherGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}
