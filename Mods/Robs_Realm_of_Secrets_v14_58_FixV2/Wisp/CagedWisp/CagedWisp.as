int g_lastSoundPlayedTime = 0;

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(11, 213, 255, 171));
	
	this.set_u32("lastSoundPlayedTime", 0);
	
	this.addCommandID("interact");
}

void onDie(CBlob@ this){
	if(!this.hasTag("no_wisp"))if(getNet().isServer())server_CreateBlob("wisp", this.getTeamNum(), this.getPosition()+Vec2f(0,-8)); 
}

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue
	this.getCurrentScript().tickFrequency = 50;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(2, Vec2f(0,0), this, this.getCommandID("interact"), "Interact.", params);
}

void onTick(CBlob@ this)
{
	if (this.get_u32("lastSoundPlayedTime") + 200 < getGameTime() && XORRandom(100) < 40)
	{		
		this.getSprite().PlaySound((XORRandom(100) < 50) ? "/MigrantScream1" : "/MigrantSayNo", 1.00f, 1.50f);
		this.set_u32("lastSoundPlayedTime", getGameTime());
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("interact"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "mat_stone"){
						server_CreateBlob("cage", hold.getTeamNum(), this.getPosition());
						server_CreateBlob("stone_core", hold.getTeamNum(), this.getPosition());
						this.Tag("no_wisp");
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "mat_gold"){
						server_CreateBlob("cage", hold.getTeamNum(), this.getPosition());
						server_CreateBlob("gold_core", hold.getTeamNum(), this.getPosition());
						this.Tag("no_wisp");
						hold.server_Die();
						this.server_Die();
					}
					if(hold.getName() == "staff"){
						server_CreateBlob("cage", hold.getTeamNum(), this.getPosition());
						server_CreateBlob("life_staff", hold.getTeamNum(), this.getPosition());
						this.Tag("no_wisp");
						hold.server_Die();
						this.server_Die();
					}
				}
			} else {
				if(getNet().isServer())server_CreateBlob("cage", this.getTeamNum(), this.getPosition()+Vec2f(0,-8));
				this.server_Die();
			}
		}
	}
}