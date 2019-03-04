// Lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(8.0f);
	this.SetLightColor(SColor(255, 0, 0, 171));

	this.Tag("dont deactivate");
	this.Tag("fire source");
	this.Tag("ignore_arrow");

	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
	this.getSprite().SetAnimation("fire");
	this.getSprite().SetEmitSound("Castle in the Darkness.ogg");
	this.getSprite().SetEmitSoundPaused(false);
}
