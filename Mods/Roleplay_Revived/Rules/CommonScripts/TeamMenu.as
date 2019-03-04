// show menu that only allows to join spectator

const int BUTTON_SIZE = 4;

void onInit(CRules@ this)
{
	this.addCommandID("pick teams");
	this.addCommandID("pick spectator");
	this.addCommandID("pick none");
	this.addCommandID("pick test");

	AddIconToken("$BLUE_TEAM$", "GUI/TeamIcons.png", Vec2f(96, 96), 0);
	AddIconToken("$TeamTest1$", "Sprites/GUI/test1ok.png", Vec2f(64,64), 0);
	AddIconToken("$RED_TEAM$", "GUI/TeamIcons.png", Vec2f(96, 96), 1);
	AddIconToken("$TEAMGENERIC$", "GUI/TeamIcons.png", Vec2f(96, 96), 2);
}

void ShowTeamMenu(CRules@ this)
{
	if (getLocalPlayer() is null)
	{
		return;
	}

	getHUD().ClearMenus(true);


	//CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), null, Vec2f((this.getTeamsCount() + 1.5f) * BUTTON_SIZE, BUTTON_SIZE), "Change team");

	CGridMenu@ upperMenu = CreateGridMenu(getDriver().getScreenCenterPos(), null, Vec2f(3 * BUTTON_SIZE, BUTTON_SIZE), "Faction one?");


	if(upperMenu !is null)
	{
		CBitStream params;
		params.write_u16(getLocalPlayer().getNetworkID());
		CGridButton@ button2 =  upperMenu.AddButton("$TeamTest1$", "Human team test", this.getCommandID("pick test"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
		CGridButton@ button = upperMenu.AddEmptyButton();
		button.SetHoverText("Beep");
	}


	/*CGridMenu@ upperMenu2 = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(-200,50), null, Vec2f(3 * BUTTON_SIZE, BUTTON_SIZE), "Faction two?");


	if(upperMenu2 !is null)
	{
		CBitStream params;
		params.write_u16(getLocalPlayer().getNetworkID());
		CGridButton@ button3 =  upperMenu2.AddButton("$TeamTest1$", "Human team test", this.getCommandID("pick test"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
		CGridButton@ button4 = upperMenu2.AddEmptyButton();
		button4.SetHoverText("Beep");
	}*/

	/*if (menu !is null)
	{
		CBitStream exitParams;
		menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("pick none"), exitParams);
		menu.SetDefaultCommand(this.getCommandID("pick none"), exitParams);

		string icon, name;

		for (int i = 0; i < this.getTeamsCount() + 1; i++)
		{
			CBitStream params;
			params.write_u16(getLocalPlayer().getNetworkID());
			params.write_u8(i);
			print("" + this.getTeamsCount());

			if (i == 0)
			{
				icon = "$BLUE_TEAM$";
				name = "Blue Team";
			}
			else if (i == 1)
			{
				// spectator
				{
					CBitStream params;
					params.write_u16(getLocalPlayer().getNetworkID());
					params.write_u8(this.getSpectatorTeamNum());
					CGridButton@ button2 = menu.AddButton("$SPECTATOR$", getTranslatedString("Spectator"), this.getCommandID("pick spectator"), Vec2f(BUTTON_SIZE / 2, BUTTON_SIZE), params);
				}
				icon = "$RED_TEAM$";
				name = "Red Team";
			}
			else if(i == 2)
			{
				print("true");
				icon = "$TeamTest1$";
				name = "Testing this team";
				CGridButton@ button =  menu.AddButton(icon, getTranslatedString(name), this.getCommandID("pick test"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
			}
			else
			{
				icon = "$TEAMGENERIC$";
				name = "Generic";
			}

			CGridButton@ button =  menu.AddButton(icon, getTranslatedString(name), this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
		}
	}*/
}

// the actual team changing is done in the player management script -> onPlayerRequestTeamChange()

void ReadChangeTeam(CRules@ this, CBitStream @params)
{
	CPlayer@ player = getPlayerByNetworkId(params.read_u16());
	u8 team = params.read_u8();

	if (player is getLocalPlayer())
	{
		player.client_ChangeTeam(team);
		// player.client_RequestSpawn(0);
		getHUD().ClearMenus();
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pick teams"))
	{
		ReadChangeTeam(this, params);
	}
	else if (cmd == this.getCommandID("pick spectator"))
	{
		ReadChangeTeam(this, params);
	}
	else if (cmd == this.getCommandID("pick none"))
	{
		getHUD().ClearMenus();
	}
	else if(cmd == this.getCommandID("pick test"))
	{
		ReadChangeTeam(this,params);
	}
}
