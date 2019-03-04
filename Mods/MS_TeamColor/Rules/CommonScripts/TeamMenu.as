// show menu that only allows to join spectator

const int BUTTON_SIZE = 4;

void onInit(CRules@ this)
{
	this.addCommandID("pick teams");
	this.addCommandID("pick spectator");
	this.addCommandID("pick none");

	AddIconToken("$BLUE_TEAM$", "GUI/TeamIcons.png", Vec2f(96, 96), 0);
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

	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), null, Vec2f((this.getTeamsCount() + 0.5f) * BUTTON_SIZE, BUTTON_SIZE), "Change team");

	if (menu !is null)
	{
		CBitStream exitParams;
		menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("pick none"), exitParams);
		menu.SetDefaultCommand(this.getCommandID("pick none"), exitParams);

		CBitStream params1;
		params1.write_u16(getLocalPlayer().getNetworkID());
		params1.write_u8(2);
		CGridButton@ button1 =  menu.AddButton("$BLUE_TEAM$", "Alliance Team", this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params1);

		CBitStream params2;
		params2.write_u16(getLocalPlayer().getNetworkID());
		params2.write_u8(this.getSpectatorTeamNum());
		CGridButton@ button2 = menu.AddButton("$SPECTATOR$", "Spectator", this.getCommandID("pick spectator"), Vec2f(BUTTON_SIZE / 2, BUTTON_SIZE), params2);
				
		CBitStream params3;
		params3.write_u16(getLocalPlayer().getNetworkID());
		params3.write_u8(1);
		CGridButton@ button3 =  menu.AddButton("$RED_TEAM$", "Horde Team", this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params3);


		/** string icon, name;

		//int getTeamsCount = this.getTeamsCount() - 1; //remove button team 2
		//for (int i = 0; i < getTeamsCount; i++)

		for (int i = 0; i < this.getTeamsCount(); i++) // Original
		{
			int t = i;
			if( t == 0){ t = 2;} // team0 button for team 2

			CBitStream params;
			params.write_u16(getLocalPlayer().getNetworkID());
			params.write_u8(t); // alteração

			if (i == 1)
			{
				// spectator
				{
					CBitStream params;
					params.write_u16(getLocalPlayer().getNetworkID());
					params.write_u8(this.getSpectatorTeamNum());
					CGridButton@ button2 = menu.AddButton("$SPECTATOR$", "Spectator", this.getCommandID("pick spectator"), Vec2f(BUTTON_SIZE / 2, BUTTON_SIZE), params);
				}

				icon = "$RED_TEAM$";
				name = "Horde Team";
				
			}
			else if( i == 0)
			{
				icon = "$BLUE_TEAM$";
				name = "Alliance Team";
			}
			else{}

			CGridButton@ button =  menu.AddButton(icon, name, this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
			

		}   **/
	}
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
}
