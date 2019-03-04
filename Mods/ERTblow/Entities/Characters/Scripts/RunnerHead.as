// RunnerHead.as
// Custom head loading functionality by Skinney

const s32 NUM_HEADFRAMES = 4;
const s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;

const string default_path = "Entities/Characters/Sprites/Heads.png";
const string blowjob_path = "../Mods/Blowjob/Heads/";
const int blowjob_size = 1024;

int getHeadFrame(CBlob@ blob, int headIndex)
{
	if (headIndex < NUM_UNIQUEHEADS)
	{
		return headIndex * NUM_HEADFRAMES;
	}

	if (headIndex == 255 || headIndex == NUM_UNIQUEHEADS)
	{
		if (blob.getConfig() == "builder")
		{
			headIndex = NUM_UNIQUEHEADS;
		}
		else if (blob.getConfig() == "knight")
		{
			headIndex = NUM_UNIQUEHEADS+1;
		}
		else if (blob.getConfig() == "archer")
		{
			headIndex = NUM_UNIQUEHEADS+2;
		}
		else if (blob.getConfig() == "migrant")
		{
			headIndex = 69 + XORRandom(2); //head scarf or old
		}
		else
		{
			headIndex = NUM_UNIQUEHEADS; //default to builder head
		}
	}
	return (((headIndex - NUM_UNIQUEHEADS / 2) * 2) + (blob.getSexNum() == 0 ? 0 : 1)) * NUM_HEADFRAMES;
}

CSpriteLayer@ LoadHead(CSprite@ this, u8 headIndex)
{
	this.RemoveSpriteLayer("head");

	CBlob@ blob = this.getBlob();
	if (blob !is null)
	{
		string sprite_name = "";

		CPlayer@ player = blob.getPlayer();
		if (player !is null)
		{
			sprite_name = player.getUsername();
		}

		CFileImage@ image = CFileImage(blowjob_path + sprite_name + ".png");
		if (image.getSizeInPixels() == blowjob_size)
		{
			//print("setting up a CUSTOM head");
			blob.set_string("sprite_path", blowjob_path + sprite_name + ".png");
			blob.set_s32("head_frame", 0);
		}
		else
		{
			//print("setting up a DEFAULT head");
			blob.set_string("sprite_path", default_path);
			blob.set_s32("head_frame", getHeadFrame(blob, headIndex));
		}

		CSpriteLayer@ head = this.addSpriteLayer("head", blob.get_string("sprite_path"), 16, 16, blob.getTeamNum(), blob.getSkinNum());
		if (head !is null)
		{
			s32 head_frame = blob.get_s32("head_frame");
			Animation@ anim = head.addAnimation("default", 0, false);
			anim.AddFrame(head_frame);
			anim.AddFrame((head_frame) + 1);
			anim.AddFrame((head_frame) + 2);
			head.SetAnimation(anim);
			head.SetFacingLeft(blob.isFacingLeft());
		}
		return head;
	}
	return null;
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	if (blob !is null)
	{
		int frame = blob.get_s32("head_frame");
		int frameX = (frame % FRAMES_WIDTH) + 2;
		int frameY = frame / FRAMES_WIDTH;
		Vec2f pos = blob.getPosition();
		Vec2f vel = blob.getVelocity();
		f32 hp = Maths::Min(Maths::Abs(blob.getHealth()),2.0f) + 1.5;
		makeGibParticle(blob.get_string("sprite_path"), pos, vel + getRandomVelocity( 90, hp , 30 ), frameX, frameY, Vec2f (16, 16), 2.0f, 20, "/BodyGibFall", blob.getTeamNum());
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob !is null)
	{
		ScriptData@ script = this.getCurrentScript();
		if (script !is null)
		{
			if (blob.getShape().isStatic())
			{
				script.tickFrequency = 60;
			}
			else
			{
				script.tickFrequency = 1;
			}
		}
	}

	CSpriteLayer@ head = this.getSpriteLayer("head");
	if (head is null && (blob.getPlayer() !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3))
	{
		@head = LoadHead(this, blob.getHeadNum());
	}
	if (head !is null) {
		PixelOffset @po = getDriver().getPixelOffset(this.getFilename(), this.getFrame());
		if (po !is null)
		{
			if (po.level == 0)
			{
				head.SetVisible(false);
			}
			else
			{
				head.SetVisible(this.isVisible());
				head.SetRelativeZ(po.level * 0.25f);
			}
			Vec2f headoffset(this.getFrameWidth()/2, -this.getFrameHeight()/2);
			headoffset += this.getOffset();
			headoffset += Vec2f(-po.x, po.y);
			headoffset += Vec2f(0, -2);
			head.SetOffset(headoffset);
			if (blob.hasTag("dead") || blob.hasTag("dead head"))
			{
				head.animation.frame = 2;
			}
			else if (blob.hasTag("attack head"))
			{
				head.animation.frame = 1;
			}
			else
			{
				head.animation.frame = 0;
			}
		}
		else
		{
			head.SetVisible(false);
		}
	}
}