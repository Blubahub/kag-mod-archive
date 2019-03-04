#include "SoundMod.as"

u16 jukeboxnetworkid;

void onInit(CBlob@ this)
{
	this.Tag("invincible");

	this.setPosition(this.getPosition() + Vec2f(0,4));

	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(-50);
}

void onInit(CSprite@ this)
{
	{ //invisible by default
		Animation@ anim = this.addAnimation("default", 0, false);
		int[] frames = {30};
		anim.AddFrames(frames);
	}

	u32 speed_bass = 6;
	u32 speed_guitar = 4;

	{
		Animation@ anim = this.addAnimation("guitarist", speed_guitar, true);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("bassist", speed_bass, true);
		int[] frames = {10, 11, 12, 13, 14, 15, 16, 17, 8, 9, 18, 19};
		anim.AddFrames(frames);
	}
	{
		Animation@ anim = this.addAnimation("drummer", speed_guitar, true);
		int[] frames = {20, 21, 22, 23, 24, 25, 26, 27};
		anim.AddFrames(frames);
	}
}

void onTick(CSprite@ this)
{
	jukeboxnetworkid = getRules().get_u16("jukebox network id");
	CBlob@ jukebox = getBlobByNetworkID(jukeboxnetworkid);

	if (jukebox is null) return;

	SoundMod@ Mixer;

	if (!jukebox.get("Mixer", @Mixer)) return;

	CBlob@ b = this.getBlob();
	if(b is null) return;

	u8 my_class = b.get_u8("class");
	if(my_class != 0)
	{
		string[] anims = {
			"default",
			"guitarist",
			"bassist",
			"drummer"
		};
		if(my_class < anims.length)
		{
			this.SetAnimation(anims[my_class]);
			this.getAnimation(anims[my_class]).loop = Mixer.isTunePlaying();
		}
	}
}
