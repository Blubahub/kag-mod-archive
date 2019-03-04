#include "SoundMod.as"

string[] mytunes = {"TR01-Theme.ogg", "TR02-Trenches.ogg", "TR03-Desert.ogg", "TR04-Swamp.ogg", "TR05-Forest.ogg", "TR06-City.ogg", "TR07-Village.ogg", "TR-Bestsong.ogg", "TR-Running!.ogg" };
int[] mytunedurations = {72, 66, 96, 62, 64, 63, 68, 107, 82};

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

	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 90, 240, 110));

	this.addCommandID("play tune");

	SoundMod Mixer();

	for (int i = 0; i < mytunes.length; i++)
	{
		Mixer.addTune(mytunes[i], mytunedurations[i]);
	}

	this.set("Mixer", Mixer);
}

void onTick(CBlob@ this)
{
	getRules().set_u16("jukebox network id", this.getNetworkID());
	
	SoundMod@ Mixer;
	if (!this.get("Mixer", @Mixer)) return;

	if (Mixer.isTunePlaying())
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("play");
	}
	else {
		this.SetLight(false);
		this.getSprite().SetAnimation("default");
	}

	if (getGameTime() % getTicksASecond() == 0) 
	{
		Mixer.tuneTimer();
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	SoundMod@ Mixer;
	if (!this.get("Mixer", @Mixer)) return;

	Vec2f tl, br, c_tl, c_br;
	this.getShape().getBoundingRect(tl, br);
	caller.getShape().getBoundingRect(c_tl, c_br);
	bool isOverlapping = br.x - c_tl.x > 0.0f && br.y - c_tl.y > 0.0f && tl.x - c_br.x < 0.0f && tl.y - c_br.y < 0.0f;

	if(isOverlapping)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		if (!Mixer.isTunePlaying()) caller.CreateGenericButton("$play tune$", Vec2f(0, 0), this, this.getCommandID("play tune"), "Play Tune", params);
		else caller.CreateGenericButton("$play tune$", Vec2f(0, 0), this, this.getCommandID("play tune"), "You cannot start a new tune while one is being played", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("play tune"))
	{
		SoundMod@ Mixer;
			
		if (!this.get("Mixer", @Mixer)) return;

		if (!Mixer.isTunePlaying())
		{
			Mixer.playTune(mytunes[XORRandom(mytunes.length())]);
		}
	}
}