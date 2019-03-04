void onInit(CBlob@ this)
{
	this.addCommandID("interact");
}

void onDie(CBlob@ this){
	if(!this.hasTag("no_slime"))if(getNet().isServer())server_CreateBlob("slime", this.getTeamNum(), this.getPosition()+Vec2f(0,-8)); 
}

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue
}

void onTick(CBlob@ this)
{
	if (XORRandom(1000) == 0)
	{
		if (getNet().isServer())
		{
			Vec2f pos = this.getPosition();
			bool otherslime = false;
			int eggsCount = 0;
			int slimeCount = 0;
			CBlob@[] blobs;
			this.getMap().getBlobsInRadius(pos, 64, @blobs);
			for (uint step = 0; step < blobs.length; ++step)
			{
				CBlob@ other = blobs[step];
				if (other is this)
					continue;

				const string otherName = other.getName();
				if (otherName == "slime")
				{
					slimeCount++;
				}
			}

			if(slimeCount < 10)
			{
				CBlob@ slime = server_CreateBlob("slime", this.getTeamNum(), this.getPosition() + Vec2f(0.0f, 5.0f));
				slime.Tag("baby");
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(2, Vec2f(0,0), this, this.getCommandID("interact"), "Interact.", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if    (caller !is null)
	{
		if (cmd == this.getCommandID("interact"))
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold is null){
				if(getNet().isServer())server_CreateBlob("cage", this.getTeamNum(), this.getPosition()+Vec2f(0,-8));
				this.server_Die();
			}
		}
	}
}