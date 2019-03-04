void onInit(CSprite@ this)
{
	ReloadSprites(this);
}

void ReloadSprites(CSprite@ sprite)
{
	string filename = "Copter.png";
	string filename2 = "BigCopter.png";
	string filename3 = "SmallCopter.png";

	sprite.ReloadSprite(filename);

	// (re)init arm and cage sprites
	sprite.RemoveSpriteLayer("copter");
	CSpriteLayer@ copter = sprite.addSpriteLayer("copter", filename2, 72, 16);

	if (copter !is null)
	{
		Animation@ anim = copter.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		copter.SetOffset(Vec2f(17, -21.0f));
		copter.SetRelativeZ(0.01f);
	}	


	sprite.RemoveSpriteLayer("copter2");
	CSpriteLayer@ copter2 = sprite.addSpriteLayer("copter2", filename3, 16, 16);

	if (copter2 !is null)
	{
		Animation@ anim = copter2.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		copter2.ResetTransform();
		copter2.SetOffset(Vec2f(79.0f, -2.0f));
		copter2.SetRelativeZ(1.5f);
		//rotation handled by update
	}
}
void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob is null) return;

	CSpriteLayer@ copter = this.getSpriteLayer("copter");
	u16 frame = blob.get_u16("copter frame");
	if (copter !is null)
	{
		copter.animation.frame = frame;
		if(frame >= 5) frame = 0;

		else
		{
			frame++;
		}

	}

	blob.set_u16("copter frame", frame);

	CSpriteLayer@ copter2 = this.getSpriteLayer("copter2");
	f32 frame2 = blob.get_f32("copter frame 2");
	if (copter2 !is null)
	{
		copter2.animation.frame = frame2/2;
		if(frame2 >= 7) frame2 = 0;

		else
		{
			frame2 = frame2+1;
		}

	}

	blob.set_f32("copter frame 2", frame2);

}