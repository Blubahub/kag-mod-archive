const f32 SPAN = 9.0f;//seconds

const array<string> anims = {
	"decay_0",
	"decay_1",
	"decay_2",
	"decay_3",
	"decay_4",
	"decay_5",
	"decay_6",
	"decay_7",
	"decay_8",
};

void onInit( CBlob@ this )
{
	this.server_SetTimeToDie( SPAN );
	this.getCurrentScript().tickFrequency = 10;
}

void onTick( CBlob@ this )
{
	if (XORRandom(8) == 0)
	{
		Vec2f pos = this.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4);
		SColor color = SColor(255, XORRandom(50) + 50, XORRandom(100) + 100, XORRandom(20) + 10);
		droplets(pos, color);
	}
}

void droplets(Vec2f pos, SColor color)
{
	ParticlePixel( pos, Vec2f(), color, true );
}

void onInit( CSprite@ this )
{
	u8 frame = this.getBlob().get_u8("goo frame");
	this.SetZ(-40.0f);
	this.SetAnimation(anims[frame]);
	this.animation.time = Maths::Round( SPAN*30/this.animation.getFramesCount() - XORRandom(30));
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}