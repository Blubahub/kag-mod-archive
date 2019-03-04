// show menu that only allows to join spectator


const int BUTTON_SIZE = 4;


// Maybe move from CGRID to the ONREDER thing

void onInit(CRules@ this)
{
	this.addCommandID("pick team0");
	this.addCommandID("pick team1");
	this.addCommandID("pick team2");
	this.addCommandID("pick team3");
	this.addCommandID("pick teams");
	this.addCommandID("pick spectator");
	this.addCommandID("pick none");
	this.addCommandID("pick test");

	AddIconToken("$BLUE_TEAM$", "GUI/TeamIcons.png", Vec2f(96, 96), 0);
	AddIconToken("$Humans$", "Sprites/GUI/HumanIcon.png", Vec2f(96,96), 0);
	AddIconToken("$Dwarfs$", "Sprites/GUI/DwarfIcon.png", Vec2f(96,96),0);
	AddIconToken("$Elves$", "Sprites/GUI/ElfIcon.png", Vec2f(96,96),0,2	);
	AddIconToken("$Orcs$", "Sprites/GUI/OrcIcon.png", Vec2f(96,96),0,3);
	AddIconToken("$RED_TEAM$", "GUI/TeamIcons.png", Vec2f(96, 96), 1);
	AddIconToken("$TEAMGENERIC$", "GUI/TeamIcons.png", Vec2f(96, 96), 2);
}

void ShowTeamMenu(CRules@ this)
{
	if (getLocalPlayer() is null)
	{
		return;
	}
	if(getLocalPlayer().getTeamNum() == 254)
		this.Tag("Menu Loaded");
		
	getHUD().ClearMenus(true);

	CPlayer@ player = getLocalPlayer();

	//CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), null, Vec2f((this.getTeamsCount() + 1.5f) * BUTTON_SIZE, BUTTON_SIZE), "Change team");

	CGridMenu@ upperMenu = CreateGridMenu(getDriver().getScreenCenterPos(), null, Vec2f(4 * BUTTON_SIZE, BUTTON_SIZE), "Pick your race!");


	if(upperMenu !is null)
	{
		CBitStream exitParams;
		exitParams.write_u16(getLocalPlayer().getNetworkID());
		upperMenu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("pick none"), exitParams);
		upperMenu.SetDefaultCommand(this.getCommandID("pick none"), exitParams);

		string team0 = this.get_string("Team0");
		string team1 = this.get_string("Team1");
		string team2 = this.get_string("Team2");
		string team3 = this.get_string("Team3");
		for(int i = 0; i < 4; i++)
		{
			CBitStream params;
			params.write_u16(getLocalPlayer().getNetworkID());
			if(i == 0)
			{
				params.write_u8(0);
				CGridButton@ button  =  upperMenu.AddButton("$"+team0+"$", "Pick your race!", this.getCommandID("pick team0"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
				button.hoverText = team0 + "\n";
			}
			else if(i == 1)
			{
				params.write_u8(1);
				CGridButton@ button =  upperMenu.AddButton("$"+team1+"$", "Pick your race!", this.getCommandID("pick team1"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
				button.hoverText = team1 + "\n";
			}
			else if(i == 2)
			{
				params.write_u8(2);
				CGridButton@ button =  upperMenu.AddButton("$"+team2+"$", "Pick your race!", this.getCommandID("pick team2"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
				button.hoverText = team2 + "\n";
			}
			else if(i == 3)
			{
				params.write_u8(3);
				CGridButton@ button =  upperMenu.AddButton("$"+team3+"$", "Pick your race!", this.getCommandID("pick team3"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
				button.hoverText = team3 + "\n";
			}
		}

	}
}

// the actual team changing is done in the player management script -> onPlayerRequestTeamChange()

void ReadChangeTeam(CRules@ this, CBitStream @params)
{
	CPlayer@ player = getPlayerByNetworkId(params.read_u16());
	u8 team = params.read_u8();
	if(player.getTeamNum() == 254)
		this.Untag("Menu Loaded");
	print(""+team);
	//this.set_bool(player.getUsername()+" on menu", false);
	//this.Sync(player.getUsername()+" on menu",false);
	if (player is getLocalPlayer())
	{
		player.client_ChangeTeam(team);
		player.server_setTeamNum(team);//REMOVE WHEN NOT USING SINGLE
		//player.client_RequestSpawn(0);
		getHUD().ClearMenus(true);
	}
	else if(getNet().isServer())
	{
		player.server_setTeamNum(team);
	}
}



void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pick team0"))
	{
		ReadChangeTeam(this, params);
	}
	else if(cmd == this.getCommandID("pick team1"))
	{
		ReadChangeTeam(this, params);
	}
	else if(cmd == this.getCommandID("pick team2"))
	{
		ReadChangeTeam(this, params);
	}
	else if(cmd == this.getCommandID("pick team3"))
	{
		ReadChangeTeam(this, params);
	}
	else if (cmd == this.getCommandID("pick spectator"))
	{
		ReadChangeTeam(this, params);
	}
	else if (cmd == this.getCommandID("pick none"))
	{
		if(getNet().isClient())
		{
			CPlayer@ player = getLocalPlayer();
			if (player is getLocalPlayer() && player.getTeamNum() == 255)
			{
				getHUD().ClearMenus();
				ShowTeamMenu(this);
			}
		}
		else
		{
			getHUD().ClearMenus();
		}
		
	}
	else if(cmd == this.getCommandID("pick test"))
	{
		ReadChangeTeam(this,params);
	}
}
