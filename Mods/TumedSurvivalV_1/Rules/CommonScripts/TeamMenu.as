// KAG rp standard "www.tiny.cc/bkforum" // Version: "..\Scripts\rp.as" //

const int BUTTON_SIZE = 4;

void onInit( CRules@ this )
{
    this.addCommandID("pick teams");
    this.addCommandID("pick spectator");
    this.addCommandID("pick none");

    AddIconToken( "$BLUE$", "GUI/TeamIcons.png", Vec2f(96, 96), 0 );
    AddIconToken( "$RED$", "GUI/TeamIcons.png", Vec2f(96, 96), 1 );
    AddIconToken( "$TEAMGENERIC$", "", Vec2f(96, 96), 4 );
}

void ShowTeamMenu( CRules@ this )
{
    if (getLocalPlayer() is null) {
        return;
    }
    
    getHUD().ClearMenus(true);

    CGridMenu@ menu = CreateGridMenu( getDriver().getScreenCenterPos(), null, Vec2f((this.getTeamsCount() + 0.5f) * BUTTON_SIZE, BUTTON_SIZE), "Change Race" );

    if (menu !is null)
    {
        CBitStream exitParams;
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
                icon = "$BLUE$";
                name = "Blue";
            }
            else if (i == 1)
            {
                icon = "$RED$";
                name = "Red";
            }
            else if (i == 2)
            {
                icon = "$BLUE$";
                name = "Green";
            }
             else
            {
                icon = "$RED$";
                name = "Violet";
                // spectator
                {
                    CBitStream params;
                    params.write_u16( getLocalPlayer().getNetworkID() );
                    params.write_u8( this.getSpectatorTeamNum() );
                    CGridButton@ button2 = menu.AddButton( "$SPECTATOR$", "Spectator", this.getCommandID("pick spectator"), Vec2f(BUTTON_SIZE/2, BUTTON_SIZE), params );
                }
            }

            CGridButton@ button =  menu.AddButton( icon, name, this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params );
        }
    }
}


void ReadChangeTeam( CRules@ this, CBitStream @params )
{
    CPlayer@ player = getPlayerByNetworkId( params.read_u16() );
    u8 team = params.read_u8();

    if (player is getLocalPlayer())
    {
        player.client_ChangeTeam( team );
        getHUD().ClearMenus();
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
    else if (cmd == this.getCommandID("pick none"))
    {
        getHUD().ClearMenus();
    }
}