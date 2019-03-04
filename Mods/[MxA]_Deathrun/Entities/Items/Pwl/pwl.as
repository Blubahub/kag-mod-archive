// Lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(7.0f);
	this.SetLightColor(SColor(100, 0, 0, 171));

	this.Tag("dont deactivate");
	this.Tag("fire source");
	this.Tag("ignore_arrow");

	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
	this.getSprite().SetAnimation("fire");
	this.getShape().SetStatic(true);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	this.Chat("I'm watching you");
	return false;
}
