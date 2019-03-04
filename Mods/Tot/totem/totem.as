//Made by Vamist


void onInit(CBlob@ this)
{
	this.addCommandID("Upgrade1");
	this.addCommandID("Upgrade2");
	this.addCommandID("Upgrade3");
	this.addCommandID("Upgrade");

	//TODO add tokens for each bit. I've gave them a temp name, so go and do what ever
	//AddIconToken("$BLUE_TEAM$", "GUI/TeamIcons.png", Vec2f(96, 96), 0);
}


bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}



void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (!this.isAttached())//is not attached
		{
			if(!this.hasTag("noBuild"))//if it has set the no build barrier
			{
				this.Tag("noBuild");
				this.getSprite().SetZ(-40.0f);
				this.getShape().SetStatic(true);//set static (no moving)
				this.doTickScripts = false;
				Vec2f pos = this.getPosition();
				CMap@ map = this.getMap();
				map.server_AddSector(pos + Vec2f(-12, -56), pos + Vec2f(12, 8), "no build", "", this.getNetworkID());
				this.set_u8("UpgradeNum",0);
				this.Sync("UpgradeNum",true);
			}
			else//has been placed on the floor with no build
			{
				//print("Test");
				//do shop
			}
		}
		else//its on the floor
		{
			//Make some money/research points
		}

	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	//TODO
	//add requirements before allowing upgrades
	if(caller.getTeamNum() == this.getTeamNum())
	{
		if(this.get_u8("UpgradeNum") == 0)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$tot_token$", Vec2f(0,0), this, this.getCommandID("Upgrade1"), getTranslatedString("Upgrade first Totem level"), params);
		}
		else if(this.get_u8("UpgradeNum") == 1)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$tot_token$", Vec2f(12, 7), this, this.getCommandID("Upgrade2"), getTranslatedString("Upgrade second Totem level"), params);
		}
		else if(this.get_u8("UpgradeNum") == 2)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$tot_token$", Vec2f(12, 7), this, this.getCommandID("Upgrade3"), getTranslatedString("Upgrade last Totem level"), params);
		}
		else
		{
			//User can't upgrade any more! do something to tell them.
		}
	}
}

void buttonUpgrade(CBlob@ this, CBitStream @params)
{
	CGridMenu@ upperMenu = CreateGridMenu(getDriver().getScreenCenterPos(), null, Vec2f(3, 1), "Pick your upgrade!");
	CBlob@ caller = getBlobByNetworkID(params.read_u16());

	//do a loop, params does not get called until clicked
	for(int8 a = 1; a < 4; a++)
	{
		params.write_u8(a);
		string name = '';
		if(a == 1)
			name = 'defense';
		else if(a == 2)
			name = 'offense';
		else
			name = 'trading';

		upperMenu.AddButton("$tot_"+name+"$", a,getTranslatedString(name),this.getCommandID("Upgrade"), params);
		
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("Upgrade1"))
	{
		print("Hello world again x2");
		buttonUpgrade(this,params); //Add this to the other upgrade2 and 3 when ready.
		//this.set_u8("UpgradeNum",1); //Remove comment when you want to increase to next level.
		//this.Sync("UpgradeNum",true);
	}
	else if(cmd == this.getCommandID("Upgrade2"))
	{
		this.set_u8("UpgradeNum",2);
		this.Sync("UpgradeNum",true);
	}
	else if(cmd == this.getCommandID("Upgrade3"))
	{
		this.set_u8("UpgradeNum",3);//after 3, i would suggest making a notification so the user knows they can't upgrade any more
		this.Sync("UpgradeNum",true);
	}
	else if(cmd == this.getCommandID("Upgrade"))
	{
		//TODO have the rules change upon increaseing x number for the team (I would suggest CRules for x team number)
		int8 num = params.read_u8();
		if(num == 1)
			print('h');
			//defnse
		else if(num == 2)
			print('h');
			//offense
		else if(num == 3)
			print('h');
			//trading
	}
}

void onDie(CBlob@ this)
{
	//server_DropCoins(this.getPosition(),this.get_u16("coins"));
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	
}
