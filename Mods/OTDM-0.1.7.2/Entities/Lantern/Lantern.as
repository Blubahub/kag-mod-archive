// Lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$lantern on$", "Lantern.png", Vec2f(8, 8), 0);
	AddIconToken("$lantern off$", "Lantern.png", Vec2f(8, 8), 3);

	this.Tag("dont deactivate");
	this.Tag("fire source");

	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
}

void onTick(CBlob@ this)
{
	if (this.isLight() && this.isInWater())
	{
		Light(this, false);
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
		this.server_Die();	
		CBlob@[] blobsInRadius;

		if (this.getMap().getBlobsInRadius(this.getPosition(), 150.0f, @blobsInRadius))

		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @blob = blobsInRadius[i];
				if (blob.getName() == "mine" && blob.getTeamNum() == this.getTeamNum())
				{	
					blob.server_Die();
				}
			}
		}
	}

}
