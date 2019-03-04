const int BUTTON_SIZE_1 = 2;
const int BUTTON_SIZE_2 = 4;

void onInit( CRules@ this )
{
	this.addCommandID("LaunchMenuPick");
	
    this.addCommandID("pick teams");
    this.addCommandID("pick spectator");
	this.addCommandID("pick none");
	
	this.addCommandID("pick_spawn");

    this.addCommandID("pick_knight");
    this.addCommandID("pick_archer");
}

/*void onTick( CRules@ this )
{
    if (!getNet().isServer()) {
        return;
    }

	if (getControls().isKeyPressed(KEY_KEY_M)) {print("===================/Hey1/===============");
		LaunchMenuPick( this, getLocalPlayer() );
	}
}*/

void ShowTeamMenu( CRules@ this )
{
    if (getLocalPlayer() is null) {
        return;
    }

    CGridMenu@ menu = CreateGridMenu( getDriver().getScreenCenterPos(), null, Vec2f((this.getTeamsCount() + 0.5f) * BUTTON_SIZE_2, BUTTON_SIZE_2), "Change team" );

    if (menu !is null)
    {
		AddIconToken( "$BLUE_TEAM$", "GUI/TeamIcons.png", Vec2f(96, 96), 0 );
		AddIconToken( "$RED_TEAM$", "GUI/TeamIcons.png", Vec2f(96, 96), 1 );
		AddIconToken( "$TEAMGENERIC$", "GUI/TeamIcons.png", Vec2f(96, 96), 2 );
		
		CBitStream exitParams;
		exitParams.write_u16( getLocalPlayer().getNetworkID() );
		menu.AddKeyCommand( KEY_ESCAPE, this.getCommandID("pick none"), exitParams );
		menu.SetDefaultCommand( this.getCommandID("pick none"), exitParams );

        string icon, name;

        for (int i = 0; i < this.getTeamsCount(); i++)
        {
            CBitStream params;
            params.write_u16( getLocalPlayer().getNetworkID() );
            params.write_u8(i);

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
                    params.write_u16( getLocalPlayer().getNetworkID() );
                    params.write_u8( this.getSpectatorTeamNum() );
                    CGridButton@ button2 = menu.AddButton( "$SPECTATOR$", "Spectator", this.getCommandID("pick spectator"), Vec2f(BUTTON_SIZE_2/2, BUTTON_SIZE_2), params );
                }
                icon = "$RED_TEAM$";
                name = "Red Team";
            }
            else
            {
                icon = "$TEAMGENERIC$";
                name = "Generic";
            }

            CGridButton@ button =  menu.AddButton( icon, name, this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE_2, BUTTON_SIZE_2), params );
        }
    }
	
    LaunchMenuPick( this, getLocalPlayer().getNetworkID() );
	CreateClassMenuPick( this , getLocalPlayer().getNetworkID() );
}

void LaunchMenuPick( CRules@ this, u16 ID )
{		
	u8 howMuch_Points = this.get_u8("Points_Count");
	
	u8 team_ally = getPlayerByNetworkId( ID ).getTeamNum();
	u8 team_enemy = (team_ally*(-1) + 1);

	CGridMenu@ oldmenu = getGridMenuByName("Pick spawn point");

	if (oldmenu !is null) {
		oldmenu.kill = true;
	}
			
	// color team icons
	AddIconToken( "$SPAWN_AT_POINT_allie$", "CP/CP_MenuPick.png", Vec2f(48, 48), 0, team_ally );
	AddIconToken( "$SPAWN_AT_POINT_enemy$", "CP/CP_MenuPick.png", Vec2f(48, 48), 0, 3 );
	AddIconToken( "$SPAWN_AT_POINT_common$", "CP/CP_MenuPick.png", Vec2f(48, 48), 0, 7 );
	// build Spawn_menu for spawns
	CGridMenu@ Spawn_menu = CreateGridMenu( Vec2f(getScreenWidth()/2.0f, getScreenHeight() - (getScreenHeight()/3.7f)), null, Vec2f( howMuch_Points*BUTTON_SIZE_1, BUTTON_SIZE_1), "Pick spawn point" );
					
	if (Spawn_menu !is null)
	{
		for (s8 i=0; i < howMuch_Points; i++)
		{	
			CBitStream params;	
						
            params.write_u16( getLocalPlayer().getNetworkID() );
            params.write_s8(i);
			
			if(this.get_u8("Team_Point"+i) == team_ally){
				Spawn_menu.AddButton( "$SPAWN_AT_POINT_allie$", "Click to spawn there", this.getCommandID("pick_spawn"), Vec2f(BUTTON_SIZE_1, BUTTON_SIZE_1), params );
			}
			else if(this.get_u8("Team_Point"+i) == team_enemy){
				Spawn_menu.AddButton( "$SPAWN_AT_POINT_enemy$", "You can't spawn here!", this.getCommandID("pick_spawn"), Vec2f(BUTTON_SIZE_1, BUTTON_SIZE_1), params );
			}
			else{
				Spawn_menu.AddButton( "$SPAWN_AT_POINT_common$", "You can't spawn here!", this.getCommandID("pick_spawn"), Vec2f(BUTTON_SIZE_1, BUTTON_SIZE_1), params );
			}
		}
	}
}

void CreateClassMenuPick( CRules@ Rule , u16 ID )
{
	CGridMenu@ menu = CreateGridMenu( Vec2f(getScreenWidth()/2.0f, getScreenHeight()-15), null, Vec2f( 2*BUTTON_SIZE_1, BUTTON_SIZE_1), "Pick Class" );
	
	u8 team = getPlayerByNetworkId( ID ).getTeamNum();
	
	AddIconToken( "$Kinght$", "CP/CP_MenuPick.png", Vec2f(48, 48), 1, team );
	AddIconToken( "$Archer$", "CP/CP_MenuPick.png", Vec2f(48, 48), 2, team );
	
	if (menu !is null)
	{
		CBitStream params;			
        params.write_u16( getLocalPlayer().getNetworkID() );
		
		menu.AddButton( "$Kinght$", "Knights forever", Rule.getCommandID("pick_knight"), Vec2f(BUTTON_SIZE_1, BUTTON_SIZE_1), params );
		menu.AddButton( "$Archer$", "Archers op -_-", Rule.getCommandID("pick_archer"), Vec2f(BUTTON_SIZE_1, BUTTON_SIZE_1), params );
	}
}

void PickSpawn( CRules@ Rule, CBitStream @params)
{
	u16 ID = params.read_u16();

	Rule.set_s8("SpawnPoint_Player"+ID, params.read_s8());
	Rule.Sync("SpawnPoint_Player"+ID, true); 
	
	CGridMenu@ menu = getGridMenuByName("Pick spawn point");
	if (menu !is null) {
		menu.kill = true;
	}
    //getHUD().ClearMenus(true);
}

void ReadChangeTeam( CRules@ this, CBitStream @params )
{
	u16 ID = params.read_u16();
	
    CPlayer@ player = getPlayerByNetworkId( ID );
    u8 team = params.read_u8();

    if (player is getLocalPlayer())
    {
		player.client_ChangeTeam( team );
		player.client_RequestSpawn(0);
		getHUD().ClearMenus(true);
    }
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("pick teams"))
    {
        ReadChangeTeam( this, params );
    }
    else if (cmd == this.getCommandID("pick spectator"))
    {
        ReadChangeTeam( this, params );
	}
	
    if (cmd == this.getCommandID("pick_spawn"))
    {
        PickSpawn( this, params );
    }
	
    if (cmd == this.getCommandID("pick_knight"))
    {        
		this.set_string("ClassPlayer"+params.read_u16(), "knight");
		//getHUD().ClearMenus(true);
	}
	else if (cmd == this.getCommandID("pick_archer"))
    {        
		this.set_string("ClassPlayer"+params.read_u16(), "archer");
		//getHUD().ClearMenus(true);
	}	
}
