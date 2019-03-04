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
	this.Tag("ignore_arrow");

	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
	
	this.addCommandID("use");
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
		Light(this, !this.isLight());
	}
	
	if (cmd == this.getCommandID("use"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(caller.get_u8("eyes") > 0){
				caller.sub_u8("eyes", 1);
				caller.add_u8("burnt_eyes", 1);
				if(getNet().isClient())if(getLocalPlayer() is caller.getPlayer()){
					SetScreenFlash(255, 255, 0, 0);
					client_AddToChat("Without thinking, you plunge your eye into the flame, blinding yourself.", SColor(255, 128, 64, 0));
				}
				if(getNet().isServer()){
					caller.Sync("eyes",true);
					caller.Sync("burnt_eyes",true);
				}
			}
		}
	}

}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() is this)
	if(caller.get_u8("eyes") > 0)
	if(caller.hasTag("researched_heat")){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("use"), "Stare", params);
	}
}
