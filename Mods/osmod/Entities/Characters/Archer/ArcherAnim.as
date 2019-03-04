// Archer animations

#include "ArcherCommon.as"
#include "FireParticle.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "Hitters.as";
#include "ExtraSparks.as";
#include "ArcherLogic.as";
//#include "CustomAnim.as";
const f32 config_offset = -4.0f;

void onInit(CSprite@ this)
{
	//LoadSprites2(this);
	//this.SetEmitSound("SaberHum.ogg");
	this.SetEmitSoundPaused(false);
}
/*
void onChangeTeam(CBlob@ this, const int oldTeam)
{

	CSprite@ sprite = this.getSprite();
	print("loading sprite..");
	if(sprite !is null)
	{
		print("not null");
		LoadSprites(sprite);

	}
}

*//*
void LoadSprites(CSprite@ this)
{
	string texname = "BodyParts.png";
	
	CBlob@ blob = this.getBlob();
	if(blob !is null)
	{	
		CPlayer@ player = blob.getPlayer();
		if(player !is null)
		{
			texname = blob.get_string("skinpath2");

		}

	}

	this.ReloadSprite(texname, this.getConsts().frameWidth, this.getConsts().frameHeight,
	                  this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	this.RemoveSpriteLayer("rightarm");
	CSpriteLayer@ rightarm = this.addSpriteLayer("rightarm", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightarm !is null)
	{
		Animation@ anim = rightarm.addAnimation("default", 0, false);
		anim.AddFrame(2);
		rightarm.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightarm.SetAnimation("default");
		rightarm.SetVisible(true);
		rightarm.SetRelativeZ(0.3);
	}

	this.RemoveSpriteLayer("leftarm");
	CSpriteLayer@ leftarm = this.addSpriteLayer("leftarm", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftarm !is null)
	{
		Animation@ anim = leftarm.addAnimation("default", 0, false);
		anim.AddFrame(2);
		leftarm.SetOffset(Vec2f(-0.0f, 5.0f + config_offset));
		leftarm.SetAnimation("default");
		leftarm.SetVisible(true);
		leftarm.SetRelativeZ(0.3);
	}

	this.RemoveSpriteLayer("righthand");
	CSpriteLayer@ righthand = this.addSpriteLayer("righthand", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (righthand !is null)
	{
		Animation@ anim = righthand.addAnimation("default", 0, false);
		anim.AddFrame(3);
		righthand.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		righthand.SetAnimation("default");
		righthand.SetVisible(true);
		righthand.SetRelativeZ(0.3);
	}
	this.RemoveSpriteLayer("lefthand");
	CSpriteLayer@ lefthand = this.addSpriteLayer("lefthand", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (righthand !is null)
	{
		Animation@ anim = lefthand.addAnimation("default", 0, false);
		anim.AddFrame(3);
		lefthand.SetOffset(Vec2f(-0.0f, 5.0f + config_offset));
		lefthand.SetAnimation("default");
		lefthand.SetVisible(true);
		lefthand.SetRelativeZ(0.3);
	}
	this.RemoveSpriteLayer("rightleg");
	CSpriteLayer@ rightleg = this.addSpriteLayer("rightleg", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightleg !is null)
	{
		Animation@ anim = rightleg.addAnimation("default", 0, false);
		anim.AddFrame(4);
		rightleg.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightleg.SetAnimation("default");
		rightleg.SetVisible(true);
		rightleg.SetRelativeZ(1.3);
	}


	this.RemoveSpriteLayer("leftleg");
	CSpriteLayer@ leftleg = this.addSpriteLayer("leftleg", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftleg !is null)
	{
		Animation@ anim = leftleg.addAnimation("default", 0, false);
		anim.AddFrame(4);
		leftleg.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		leftleg.SetAnimation("default");
		leftleg.SetVisible(true);
		leftleg.SetRelativeZ(0.8);
	}

	this.RemoveSpriteLayer("leftfoot");
	CSpriteLayer@ leftfoot = this.addSpriteLayer("leftfoot", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (leftfoot !is null)
	{
		Animation@ anim = leftfoot.addAnimation("default", 0, false);
		anim.AddFrame(5);
		leftfoot.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		leftfoot.SetAnimation("default");
		leftfoot.SetVisible(true);
		leftfoot.SetRelativeZ(0.7);
	}

	this.RemoveSpriteLayer("rightfoot");
	CSpriteLayer@ rightfoot = this.addSpriteLayer("rightfoot", texname, 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rightfoot !is null)
	{
		Animation@ anim = rightfoot.addAnimation("default", 0, false);
		anim.AddFrame(5);
		rightfoot.SetOffset(Vec2f(-0.0f, 0.0f + config_offset));
		rightfoot.SetAnimation("default");
		rightfoot.SetVisible(true);
		rightfoot.SetRelativeZ(1.0);
	}


}*/
void setLegValues(CBlob@ blob, CSpriteLayer@ rightleg, CSpriteLayer@ leftleg, CSpriteLayer@ rightfoot, CSpriteLayer@ leftfoot, CSpriteLayer@ rightarm, CSpriteLayer@ leftarm, CSpriteLayer@ righthand, CSpriteLayer@ lefthand )
{

	//CSpriteLayer@ rightarm = blob.getSprite().getSpriteLayer("rightarm");
	int facing = blob.isFacingLeft() ? 1 : -1;
	bool face = blob.isFacingLeft();
	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));
	bool standing = blob.isOnGround() && !walking;
	bool backwards = false;
	if( blob.isKeyPressed(key_left) && !face || blob.isKeyPressed(key_right) && face)
	{
		backwards = true;
	}
	s32 backward = backwards ? -1 : 1;
	if(rightleg !is null && leftleg !is null && rightfoot !is null && leftfoot !is null && rightarm !is null && leftarm !is null && righthand !is null && lefthand !is null)
	{
		s32 lla = blob.get_s32("lla");
		s32 llt = blob.get_s32("llt");

		s32 lfa = blob.get_s32("lfa");
		s32 lft = blob.get_s32("lft");

		s32 rla = blob.get_s32("rla");
		s32 rlt = blob.get_s32("rlt");

		s32 rfa = blob.get_s32("rfa");
		s32 rft = blob.get_s32("rft");

		s32 laa = blob.get_s32("laa");
		s32 lat = blob.get_s32("lat");

		s32 raa = blob.get_s32("raa");
		s32 rat = blob.get_s32("rat");

		s32 lha = blob.get_s32("lha");
		s32 lht = blob.get_s32("lht");

		s32 rha = blob.get_s32("rha");
		s32 rht = blob.get_s32("rht");


		Vec2f pos = blob.getPosition();
		Vec2f rightoffset = Vec2f(3, 0);//*facin
		Vec2f leftoffset = Vec2f(-1, 0);//*facin

		Vec2f rightoffset2 = Vec2f(8, 5);//*facin
		Vec2f leftoffset2 = Vec2f(-2, 5);//*facin

		//leftoffset.x -= (facing*8);


		leftleg.ResetTransform();
		rightleg.ResetTransform();

		leftfoot.ResetTransform();
		rightfoot.ResetTransform();
		leftarm.ResetTransform();
		rightarm.ResetTransform();
		lefthand.ResetTransform();
		righthand.ResetTransform();



		Vec2f rightjoint = pos + rightoffset;//*facin
		Vec2f leftjoint = pos + leftoffset;//*facin
 		Vec2f around = Vec2f(0.0f, 0.0f);

		if(standing && !blob.hasTag("dead"))
		{	
			llt = 10;
			rlt = -10;

			lft = -1;
			rft = -8;

			lat = 1;
			rat = -17;

			lht = 10;
			rht = -1;

			//rightoffset.x ++;
			//leftoffset.x ++;
			blob.set_s32("walkcycle", 0);
		}
		if(walking && !blob.hasTag("dead"))
		{
			s32 cycle = blob.get_s32("walkcycle");
			if(cycle < 40 && !backwards)
			{
				cycle=cycle+(blob.isOnGround()? 3 : 1);
			}					

			if(cycle > 0 && backwards)
			{
				cycle=cycle-(blob.isOnGround()? 3 : 1);
			}		

			if(cycle >= 40 && !backwards)
			{
				cycle = 0;
			}


			if(cycle <= 0 && backwards)
			{
				cycle = 39;
			}

			blob.set_s32("walkcycle", cycle);

			if(cycle < 10)
			{
				llt = 50;
				rlt = -50;

				lft = 40;
				rft = -90;

				rat = 0;
				lat = -90;

				lht = 0;
				rht = 90;


			}	/*
			else if(cycle >= 10 && cycle < 20)
			{
				
			}	*/
			else if(cycle >= 20 && cycle < 30)
			{	
				llt = -50;
				rlt = 50;

				lft = -90;
				rft = 40;

				rat = -90;
				lat = 0;

				lht = 90;
				rht = 0;

			}	
/*
			else if(cycle >= 30 && cycle < 40)
			{
				
			}	*/

			lht = lat+90;
			rht = rat+90;/*
			lha = laa+90;
			rha = laa+90;*/
		}

		bool crouching = (!walking && blob.isOnGround() && blob.isKeyPressed(key_down));
		if(!crouching)
		{
			if(blob.getShape() !is null)
			{
				blob.getShape().SetOffset(Vec2f(0, 4));

			}

		}

		Vec2f dirleft = Vec2f(0, 5);
		dirleft.RotateBy(lla, around);

		Vec2f dirright = Vec2f(2, 5);
		dirright.RotateBy(rla, around);

		Vec2f dirleft2 = Vec2f(0, 5);
		dirleft2.RotateBy(raa, around);

		Vec2f dirright2 = Vec2f(0, 5);
		dirright2.RotateBy(laa, around);



		s32 facing2 = blob.isFacingLeft() ? -180 : 180;
		s32 facing3 = blob.isFacingLeft() ? 1 : -8;
		s32 facing4 = blob.isFacingLeft() ? 0 : 8;

		rightoffset2 = Vec2f(0, 0) + dirright;
		leftoffset2 = Vec2f(-3, 0) + dirleft;



		Vec2f offsets2 = Vec2f(4, -8);

		Vec2f offsets3 = Vec2f(-4, -8);



		Vec2f offsets4 = dirright2 + Vec2f(-5, -8);

		Vec2f offsets5 = dirleft2 + Vec2f(3, -8);

		rightarm.SetRelativeZ(10.1f);
		righthand.SetRelativeZ(10.1f);
		leftarm.SetRelativeZ(-0.1f);
		lefthand.SetRelativeZ(-0.1f);

		if(crouching && !walking)
		{	
			if(blob.getShape() !is null)
			{
				blob.getShape().SetOffset(Vec2f(0, -3));

			}
			llt = 100;
			rlt = 10;

			lft = -10;
			rft = -90;
			lefthand.SetRelativeZ(0.1f);
		
			lat = 50;
			rat = -50;

			lht = rat-20;
			rht = lat+30;

			dirright2 = Vec2f(0, 5);
			dirright2.RotateBy(raa, around);
			Vec2f dirleft2 = Vec2f(0, 5);
			dirleft2.RotateBy(raa, around);
			Vec2f offsets4 = dirright2 + Vec2f(-5, -5);
/*
			dirleft2 = Vec2f(0, 3);
			dirleft2.RotateBy(laa, around);


			offsets4 =Vec2f(-5, 2) +dirright2;

			offsets5 =Vec2f(4, -2)+dirleft2;*/

		}
/*
		else if(!face)
		{
			offsets4 = dirright2 + Vec2f(5+facing3, -5);

			offsets5 = dirleft2 + Vec2f(-4+facing4, -5);

			dirleft2.RotateBy(laa*-1, around);

			dirright2.RotateBy(raa*-1, around);



			righthand.SetOffset(offsets4);
			lefthand.SetOffset(offsets5);

			rightarm.SetRelativeZ(-0.1f);
			righthand.SetRelativeZ(-0.1f);
			leftarm.SetRelativeZ(10.1f);
			lefthand.SetRelativeZ(10.1f);
		}*/
		if(lla != llt)
		{
			lla += 0.1 +(1+(llt - lla)/(blob.isOnGround()? 5 : 10));
		}

		if(rla != rlt)
		{
			rla += 0.1 +(1+(rlt - rla)/(blob.isOnGround()? 5 : 10));
		}

		if(lfa != lft)
		{
			lfa += 0.1 +(1+(lft - lfa)/(blob.isOnGround()? 5 : 10));
		}

		if(rfa != rft)
		{
			rfa += 0.1 +(1+(rft - rfa)/(blob.isOnGround()? 5 : 10));
		}

		if(laa != lat)
		{
			laa += 0.1 +(1+(lat - laa)/(blob.isOnGround()? 5 : 10));
		}

		if(raa != rat)
		{
			raa += 0.1 +(1+(rat - raa)/(blob.isOnGround()? 5 : 10));
		}

		if(lha != lht)
		{
			lha += 0.1 +(1+(lht - lha)/(blob.isOnGround()? 5 : 10));
		}

		if(rha != rht)
		{
			rha += 0.1 +(1+(rht - rha)/(blob.isOnGround()? 5 : 10));
		}

		leftleg.ResetTransform();

		blob.set_s32("llt", llt);
		blob.set_s32("lft", lft);

		blob.set_s32("rlt", rlt);
		blob.set_s32("rft", rft);

		blob.set_s32("lat", lat);
		blob.set_s32("rat", rat);

		blob.set_s32("lht", lht);
		blob.set_s32("rht", rht);


		blob.set_s32("lla", lla);
		blob.set_s32("lfa", lfa);

		blob.set_s32("rla", rla);
		blob.set_s32("rfa", rfa);

		blob.set_s32("laa", laa);
		blob.set_s32("raa", raa);

		blob.set_s32("lha", lha);
		blob.set_s32("rha", rha);
/*
		laa -= 90;
		raa -= 90;
		lha -= 90;
		rha -= 90;*/
		rightarm.SetOffset(offsets2);
		leftarm.SetOffset(offsets3);
		righthand.SetOffset(offsets5);
		lefthand.SetOffset(offsets4);
		leftfoot.SetOffset(leftoffset2);
		rightfoot.SetOffset(rightoffset2);
		leftleg.SetOffset(leftoffset);
		rightleg.SetOffset(rightoffset);

		leftleg.RotateBy(lla*facing, around); //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		rightleg.RotateBy(rla*facing, around);
		leftfoot.RotateBy(lfa*facing, around);
		rightfoot.RotateBy(rfa*facing, around);
		leftarm.RotateBy(laa*facing, around);
		rightarm.RotateBy(raa*facing, around);
		lefthand.RotateBy(lha*facing, around);
		righthand.RotateBy(rha*facing, around);




		//saber.TranslateBy(Vec2f(1.0f, 2.0f));
	}




}
void setArmValues(CBlob@ blob, CSpriteLayer@ rightarm)
{
	//CSpriteLayer@ rightarm = blob.getSprite().getSpriteLayer("rightarm");
	s32 facing = blob.isFacingLeft() ? 1 : -1;
	s32 facing2 = blob.isFacingLeft() ? 0 : 270;
	bool face = blob.isFacingLeft();
	//rightarm.setFacingLeft(face);
	if(rightarm !is null)
	{
		Vec2f aimpos = blob.getAimPos();
		Vec2f pos = blob.getPosition();
		Vec2f diff = aimpos - pos;
		diff.Normalize();
		rightarm.ResetTransform();
		f32 angle = -diff.Angle()+facing2;
		rightarm.RotateBy(angle, Vec2f(0,0));
		Vec2f offset2 = Vec2f(0, -8);//*facin

		rightarm.SetOffset(offset2);

		//saber.TranslateBy(Vec2f(1.0f, 2.0f));
	}






/*
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
		Vec2f offset2 = diff*5;//*facing;

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
		//saber.TranslateBy(Vec2f(1.0f, 2.0f));

		f32 angles = angle-(angle*facing)*(-facing);
		//print(""+angle);
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

			 	//CBlob@[] blobsInRadius;
	 			if(!blob.isFacingLeft())
				{
					offset2.x = offset2.x * -1;
				}
			 	Vec2f hitpos = pos + (offset2*3);

				//CBitStream params;
				//params.write_Vec2f(hitpos);
				//params.write_Vec2f(offset2);
				
				//blob.SendCommand(blob.getCommandID("slash"));
				blob.set_Vec2f("hitpos", hitpos);
				blob.set_Vec2f("hitvel", offset2*50);
			 	//saberSlash(blob, hitpos, offset2);
			 	
			 	blob.set_bool("slashing", true);
			 	//print("saberSlash sent");

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
			s32 lastfire = blob.get_s32("lastfire");
			f32 angles = angle-lastfire;
			arm.RotateBy(angles, around);
		}
	}
}
/*
void saberSlash(CBlob@ blob, Vec2f hitpos, Vec2f offset2)
{
	print("saberSlashing.....................");

	if(!getNet().isServer())
	{
		print("saberSlash not serverside :(");
		return;
	}
	print("saberSlashing!!!!");
	CBlob@[] blobsInRadius;

  	if (blob.getMap().getBlobsInRadius(hitpos, 10.0f, @blobsInRadius))
 	{
 		for (uint i = 0; i < blobsInRadius.length; i++)
 		{		
			CBlob @b = blobsInRadius[i];
			s32 lasthit = blob.get_s32("lasthit");
			if(b !is null && b.getTeamNum() != blob.getTeamNum() && lasthit < 1)
			{

				b.server_Hit(b, hitpos, offset2*50, 1.0f, Hitters::burn, false);
				b.server_Hit(b, hitpos, offset2*50, 1.0f, Hitters::sword, false);
				b.AddForce(offset2*(b.getMass()/2));
				mapSparks(hitpos, 0.0f, 5.0f);
				blob.SendCommand(blob.getCommandID("hitsound"));
				blob.set_s32("lasthit", 30);

			}
 		}
	}*/
}
void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	UpdateBody(this, blob);
	// animations

}

void UpdateBody(CSprite@ this, CBlob@ blob)
{

	CSpriteLayer@ leftarm = this.getSpriteLayer("leftarm");

	CSpriteLayer@ rightarm = this.getSpriteLayer("rightarm");

	CSpriteLayer@ lefthand = this.getSpriteLayer("lefthand");

	CSpriteLayer@ righthand = this.getSpriteLayer("righthand");

	CSpriteLayer@ rightleg = this.getSpriteLayer("rightleg");
	CSpriteLayer@ leftleg = this.getSpriteLayer("leftleg");

	CSpriteLayer@ rightfoot = this.getSpriteLayer("rightfoot");
	CSpriteLayer@ leftfoot = this.getSpriteLayer("leftfoot");
	//if(rightarm is null) return;

	//setArmValues(blob, rightarm);//, leftarm, righthand, lefthand);

	setLegValues(blob, rightleg, leftleg, rightfoot, leftfoot, rightarm, leftarm, righthand, lefthand);

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
