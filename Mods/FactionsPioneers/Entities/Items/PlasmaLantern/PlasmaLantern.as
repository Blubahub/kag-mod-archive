// Plasma lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightColor(SColor(255, 0, 200, 255));
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$plasmalantern on$", "PlasmaLantern.png", Vec2f(8, 8), 0);
	AddIconToken("$plasmalantern off$", "PlasmaLantern.png", Vec2f(8, 8), 3);

	this.Tag("dont deactivate");
	this.Tag("fire source");

	this.getCurrentScript().tickFrequency = 24;
}

void onTick(CBlob@ this)
{
	if (!this.isInWater())
	{
		this.SetLightRadius(32.0f);
	}
	else
	{
		this.SetLightRadius(64.0f);
	}
}

void Light(CBlob@ this, bool on)
{
	if (!on)
	{
		this.SetLight(false);
		this.getSprite().SetAnimation("nofire");
	}
	else
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("fire");
	}
	this.getSprite().PlaySound("SparkleShort.ogg");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		Light(this, !this.isLight());
	}

}
