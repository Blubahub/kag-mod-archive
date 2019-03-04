void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(100.0f);
	this.SetLightColor(SColor(255, 180, 230, 255));
	
	this.getShape().SetStatic(true);
}