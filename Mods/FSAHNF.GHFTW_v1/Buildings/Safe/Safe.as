

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetZ(-20.0f);
	this.set_string("username","");
	this.set_s16("coins",0);
	
	this.addCommandID("deposit");
	this.addCommandID("withdraw");
	
	this.Tag("builder always hit");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if(forBlob.getPlayer() !is null)
	if(forBlob.getPlayer().getUsername() == this.get_string("username"))return true;
	return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.isOverlapping(this))
	if(caller.getPlayer() !is null)
	if(caller.getPlayer().getUsername() == this.get_string("username"))
	{
		{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton(19, Vec2f(-6, -6), this, this.getCommandID("deposit"), "Deposit 50 coins", params);
		}
		{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton(16, Vec2f(6, -6), this, this.getCommandID("withdraw"), "Withdraw 50 coins", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
		CPlayer @player = getPlayerByUsername(this.get_string("username"));
		if(player !is null){
			if (cmd == this.getCommandID("deposit"))
			{
				if(player.getCoins() >= 50){
					player.server_setCoins(player.getCoins()-50);
					this.set_s16("coins",this.get_s16("coins")+50);
				}
			}
			if (cmd == this.getCommandID("withdraw"))
			{
				if(this.get_s16("coins") >= 50){
					player.server_setCoins(player.getCoins()+50);
					this.set_s16("coins",this.get_s16("coins")-50);
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	CPlayer @player = getPlayerByUsername(this.get_string("username"));
	if (getNet().isServer())
	if(player !is null){
		player.server_setCoins(player.getCoins()+this.get_s16("coins"));
	}
}