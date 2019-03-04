// Flag logic
void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 5;

	//cannot fall out of map
	this.SetMapEdgeFlags(u8(CBlob::map_collide_up) |
	                     u8(CBlob::map_collide_down) |
	                     u8(CBlob::map_collide_sides));

	Vec2f pos = this.getPosition();
}

//sprite

void onInit(CSprite@ this)
{
	this.SetZ(-10.0f);
	CSpriteLayer@ flag = this.addSpriteLayer("flag_layer", "/CTF_Flag.png", 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (flag !is null)
	{
		flag.SetOffset(Vec2f(15, -4));
		flag.SetRelativeZ(1.0f);
		Animation@ anim = flag.addAnimation("default", XORRandom(3) + 3, true);
		anim.AddFrame(0);
		anim.AddFrame(2);
		anim.AddFrame(4);
		anim.AddFrame(6);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ by)
{
	return true;
}
