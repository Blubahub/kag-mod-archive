// generic character head script

#include "EquipCommon.as";
#include "HumanoidAnimCommon.as";
#include "LimbsCommon.as";
#include "PaletteSwap.as";
#include "EquipCommon.as";

const s32 NUM_HEADFRAMES = 4;
const s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;
const int NUM_HAIR_FRAMES = 5;

int getHeadFrame(CBlob@ blob, int headIndex)
{
	return (blob.getSexNum() == 0 ? 0 : 1) * NUM_HEADFRAMES;
}

CSpriteLayer@ LoadHead(CSprite@ this, u8 headIndex)
{
	this.RemoveSpriteLayer("head");
	this.RemoveSpriteLayer("left_eye");
	this.RemoveSpriteLayer("right_eye");
	this.RemoveSpriteLayer("hair");
	
	CBlob@ blob = this.getBlob();
	
	// set defaults
	s32 headFrame = getHeadFrame(blob, headIndex);
	blob.set_s32("head index", headFrame);
	blob.set_u8("head sex", blob.getSexNum());
	int race = blob.get_s8("head_type")*NUM_HEADFRAMES*2;
	
	int hair_num = blob.get_u8("hair_index");
	int hair_colour = blob.get_u8("hair_colour");
	
	if(blob.get_s8("head_type") == 1 || blob.get_s8("head_type") == 4)hair_colour = 1; //Ectoplasm
	if(blob.get_s8("head_type") == 7)hair_colour = 4; //Gold - blonde
	if(blob.get_s8("head_type") == 8)hair_colour = 16; //Shadow
	
	CSpriteLayer@ head = this.addSpriteLayer("head", "Base_Head.png", 16, 16, 0, 0);
	InitLayer(this,head, headFrame+race);
	
	CSpriteLayer@ left_eye = this.addSpriteLayer("left_eye", "LeftEyes.png", 16, 16, 0, 0);
	InitLayer(this,left_eye, headFrame+(getLeftEye(blob)*NUM_HEADFRAMES*2));
	blob.set_u8("sprite_left_eye",getLeftEye(blob));
	
	CSpriteLayer@ right_eye = this.addSpriteLayer("right_eye", "RightEyes.png", 16, 16, 0, 0);
	InitLayer(this,right_eye, headFrame+(getRightEye(blob)*NUM_HEADFRAMES*2));
	blob.set_u8("sprite_right_eye",getRightEye(blob));
	
	CSpriteLayer@ helmet = this.addSpriteLayer("helmet", "character_no_helmet.png", 32, 32, 0, 0);
	
	CSpriteLayer@ hair = null;
	if(hair_num != 0 || blob.getSexNum() != 0){
		
		if(!Texture::exists("hair"+hair_num+"_"+hair_colour))Texture::createFromFile("hair"+hair_num+"_"+hair_colour, "Hair.png");
		
		string tex = PaletteSwapTexture("hair"+hair_num+"_"+hair_colour, "HairPalette.png", hair_colour);
	
		@hair = this.addSpriteLayer("hair", "Hair.png", 16, 16, 0, 0);
		hair.SetTexture(tex, 16, 16);
		InitHair(this, hair, hair_num*NUM_HAIR_FRAMES*2 + (blob.getSexNum() == 0 ? 0 : 1)*2);
	}
	
	if(blob.get_s8("head_type") == 1){
		if(head !is null)head.setRenderStyle(RenderStyle::additive);
		if(left_eye !is null)left_eye.setRenderStyle(RenderStyle::additive);
		if(right_eye !is null)right_eye.setRenderStyle(RenderStyle::additive);
		if(hair !is null)hair.setRenderStyle(RenderStyle::additive);
	}
	
	return head;
}

void InitLayer(CSprite@ this, CSpriteLayer@ layer, u8 headFrame){
	if (layer !is null)
	{
		Animation@ anim = layer.addAnimation("default", 0, false);
		anim.AddFrame(headFrame);
		anim.AddFrame(headFrame + 1);
		anim.AddFrame(headFrame + 2);
		layer.SetAnimation(anim);

		layer.SetFacingLeft(this.getBlob().isFacingLeft());
	}
}

void InitHair(CSprite@ this, CSpriteLayer@ layer, u8 hair){
	if (layer !is null)
	{
		Animation@ anim = layer.addAnimation("default", 0, false);
		anim.AddFrame(hair);
		anim.AddFrame(hair + 1);
		anim.AddFrame(hair + NUM_HAIR_FRAMES);
		anim.AddFrame(hair + NUM_HAIR_FRAMES + 1);
		layer.SetAnimation(anim);

		layer.SetFacingLeft(this.getBlob().isFacingLeft());
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	ScriptData@ script = this.getCurrentScript();
	if (script is null)
		return;

	if (blob.getShape().isStatic())
	{
		script.tickFrequency = 60;
	}
	else
	{
		script.tickFrequency = 1;
	}


	// head animations
	CSpriteLayer@ head = this.getSpriteLayer("head");

	// load head when player is set or it is AI
	if (head is null && (blob.getPlayer() !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3))
	{
		@head = LoadHead(this, blob.getHeadNum());
	}

	// set the head offset and Z value according to the pink/yellow pixels
	//PixelOffset @po = getDriver().getPixelOffset(this.getFilename(), this.getFrame());

	PixelOffset @po = getDriver().getPixelOffset(this.getFilename(), this.getFrame());
	
	if (po !is null)
	{
		// behind, in front or not drawn
		bool Visible = true;
		if(head !is null)Visible = head.isVisible();
		f32 RelZ = 0;
		u8 Frame = 0;
		bool lying_down = false;
		
		if (po.level == 0)
		{
			Visible = false;
		}
		else
		{
			RelZ = po.level * 0.25f;
		}

		// set the proper offset
		Vec2f headoffset(this.getFrameWidth() / 2, -this.getFrameHeight() / 2);
		headoffset += this.getOffset();
		headoffset += Vec2f(-po.x, po.y);
		headoffset += Vec2f(0, -2);
		

		if (blob.hasTag("sleep head"))
		{
			Frame = 0;
			headoffset += Vec2f(-1, 0);
			lying_down = true;
		}
		else if (blob.hasTag("dead") || blob.hasTag("dead head"))
		{
			Frame = 2;

			// sparkle blood if cut throat
			if (getNet().isClient() && getGameTime() % 2 == 0 && blob.hasTag("cutthroat"))
			{
				Vec2f vel = getRandomVelocity(90.0f, 1.3f * 0.1f * XORRandom(40), 2.0f);
				ParticleBlood(blob.getPosition() + Vec2f(this.isFacingLeft() ? headoffset.x : -headoffset.x, headoffset.y), vel, SColor(255, 126, 0, 0));
				if (XORRandom(100) == 0)
					blob.Untag("cutthroat");
			}
		}
		else if (blob.hasTag("attack head"))
		{
			Frame = 1;
		}
		else
		{
			Frame = 0;
		}
		
		
		if (head !is null){
			head.SetOffset(headoffset);
			if(!Visible)head.SetVisible(false);
			head.SetRelativeZ(RelZ);
			head.animation.frame = Frame;
			head.ResetTransform();
			if(lying_down){
				if(blob.isFacingLeft())head.RotateBy(90, Vec2f(0,3));
				else head.RotateBy(-90, Vec2f(0,3));
			}
		}
		
		CSpriteLayer@ left_eye = this.getSpriteLayer("left_eye");
		if (left_eye !is null){
			left_eye.SetOffset(headoffset);
			if(!Visible)left_eye.SetVisible(false);
			left_eye.SetRelativeZ(RelZ+0.02f);
			left_eye.animation.frame = Frame;
			left_eye.ResetTransform();
			if(lying_down){
				if(blob.isFacingLeft())left_eye.RotateBy(90, Vec2f(0,3));
				else left_eye.RotateBy(-90, Vec2f(0,3));
			}
		}
		
		CSpriteLayer@ right_eye = this.getSpriteLayer("right_eye");
		if (right_eye !is null){
			right_eye.SetOffset(headoffset);
			if(!Visible)right_eye.SetVisible(false);
			right_eye.SetRelativeZ(RelZ+0.01f);
			right_eye.animation.frame = Frame;
			right_eye.ResetTransform();
			if(lying_down){
				if(blob.isFacingLeft())right_eye.RotateBy(90, Vec2f(0,3));
				else right_eye.RotateBy(-90, Vec2f(0,3));
			}
		}
		
		CSpriteLayer@ hair = this.getSpriteLayer("hair");
		if (hair !is null){
			hair.SetOffset(headoffset);
			if(head !is null)hair.SetVisible(head.isVisible());
			hair.SetRelativeZ(RelZ+0.03f);
			if(Frame < 2)hair.animation.frame = 0;
			else hair.animation.frame = 1;
			if(getEquippedBlob(blob, "head") !is null){
				hair.animation.frame += 2;
				if(getEquippedBlob(blob, "head").hasTag("full_helmet"))hair.SetVisible(false);
			}
			hair.ResetTransform();
			if(lying_down){
				if(blob.isFacingLeft())hair.RotateBy(90, Vec2f(0,3));
				else hair.RotateBy(-90, Vec2f(0,3));
			}
		}
		
		CSpriteLayer@ helmet = this.getSpriteLayer("helmet");
		if (helmet !is null){
			if(blob.getSexNum() == 1)helmet.SetOffset(headoffset);
			else helmet.SetOffset(headoffset+Vec2f(0,-1));
			if(!Visible)helmet.SetVisible(false);
			helmet.SetRelativeZ(RelZ+0.04f);
			helmet.ResetTransform();
			if(lying_down){
				if(blob.isFacingLeft())helmet.RotateBy(90, Vec2f(0,3));
				else helmet.RotateBy(-90, Vec2f(0,3));
			}
		}
	}
}
