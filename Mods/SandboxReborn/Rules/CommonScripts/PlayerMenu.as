bool checkAccessRank(CPlayer@ player, string rank)
{
	if (player is null)
		return false;
	return getSecurity().checkAccess_Feature(player, "sopranos_"+rank);
}

bool isSoprano(CPlayer@ player)// don and boss
{
	return ( checkAccessRank(player, "don") || checkAccessRank(player, "boss") );
}

bool canUseAdvanced(CPlayer@ player)// gangsters
{
	return ( isSoprano(player) || checkAccessRank(player, "gangster") );
}

bool canUseBasic(CPlayer@ player)// thugs and hitmen
{
	return ( canUseAdvanced(player) || checkAccessRank(player, "thug") || checkAccessRank(player, "hitman") );
}

bool canUseDefault(CPlayer@ player)
{
	return true;
}

void onInit(CRules@ this)
{
	this.addCommandID("teleport");
	this.addCommandID("teleport end");
	this.addCommandID("pick class");
	this.addCommandID("pick team");
	this.addCommandID("spawn blob");
	this.addCommandID("spawn room");
	this.addCommandID("none");

	AddIconToken("$builder_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 8);
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);

	for (u8 i = 0; i < 10; i++){AddIconToken("$TEAM" + i + "$", "TeamChangeIcon.png", Vec2f(16, 32), i);}
	AddIconToken("$TEAM153$", "TeamChangeIcon.png", Vec2f(16, 32), 10);
	AddIconToken("$TEAM154$", "TeamChangeIcon.png", Vec2f(16, 32), 11);

	AddIconToken("$FarEndLEFT$", "SSGUI.png", Vec2f(32, 32), 0);
	AddIconToken("$FarEndRIGHT$", "SSGUI.png", Vec2f(32, 32), 1);
	AddIconToken("$TRAVEL_LEFT$", "GUI/MenuItems.png", Vec2f(32, 32), 23);
	AddIconToken("$TRAVEL_RIGHT$", "GUI/MenuItems.png", Vec2f(32, 32), 22);
}

void onTick( CRules@ this )
{
    if(getNet().isClient())
	{
		CPlayer@ p = getLocalPlayer();
		if (p !is null && p.getBlob() !is null)
		{
        	if (getControls().ActionKeyPressed(AK_MENU))
        	{
			    ShowPlayerMenu(this, p);
        	}
		}
    }
}

void AddSwapTeamButton(CGridMenu@ menu, CPlayer@ player, u8 team)
{
	CBitStream params;
	params.write_u16(player.getNetworkID());
	params.write_u8(team);
	CGridButton@ button2 = menu.AddButton("$TEAM" + team + "$", "Team: " + team, getRules().getCommandID("pick team"), Vec2f(1, 2), params);
}

void AddChangeClassButton(CGridMenu@ menu, CPlayer@ player, string config, string name, string icon)
{
	CBitStream params;
	params.write_u16(player.getBlob().getNetworkID());
	params.write_string(config);

	CGridButton@ button = menu.AddButton(icon, name, getRules().getCommandID("pick class"), Vec2f(2, 2), params);
}

void AddTeleportButton(CGridMenu@ menu, CPlayer@ player, bool left)
{
	CBitStream params;
	params.write_u16(player.getBlob().getNetworkID());
	params.write_bool(left);
	menu.AddButton("$FarEnd" + (left ? "LEFT$" : "RIGHT$"), "Travel to the far " + (left ? "left" : "right"), getRules().getCommandID("teleport end"), Vec2f(2, 2), params);
}

void ShowPlayerMenu(CRules@ this, CPlayer@ player)
{
	getHUD().ClearMenus(true);
	CBlob@ pBlob = player.getBlob();

	{ // team / class swapping
		bool basic = canUseBasic(player);
		CGridMenu@ menu = CreateGridMenu(Vec2f(getDriver().getScreenCenterPos().x, 10), null, Vec2f(basic ? 18 : 16, 2), "Change Team / Swap Class");
		
		if (basic) AddSwapTeamButton(menu, player, 153);
		for (u8 i = 0; i < 5; i++){ AddSwapTeamButton(menu, player, i); }

		AddChangeClassButton(menu, player, "builder", "Builder", "$builder_class_icon$");
		AddChangeClassButton(menu, player, "knight", "Knight", "$knight_class_icon$");
		AddChangeClassButton(menu, player, "archer", "Archer", "$archer_class_icon$");

		for (u8 i = 5; i < 10; i++){ AddSwapTeamButton(menu, player, i); }
		if (basic) AddSwapTeamButton(menu, player, 154);
	}

	{ // teleports
		bool basic = canUseBasic(player);

		CBlob@[] tunnels;
		getTunnelsForButtons(pBlob, @tunnels);

		CBlob@[] players;
		getBlobsByTag("player", @players);
		
		const u8 x = tunnels.length * 2 + 4;
		const u8 y = basic ? (((players.length) / x) + 3 ) : 2;

		CGridMenu@ menu = CreateGridMenu(Vec2f(getDriver().getScreenCenterPos().x, 256), pBlob, Vec2f(x, y), "Teleport");
		if (menu !is null)
		{
			u16 callerID = pBlob.getNetworkID();

			CBitStream exitParams;
			exitParams.write_netid(callerID);
			menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("none"), exitParams);
			//menu.AddKeyCommand(AK_MENU, this.getCommandID("none"), exitParams);
			menu.SetDefaultCommand(this.getCommandID("none"), exitParams);

			AddTeleportButton(menu, player, true);
			for (uint i = 0; i < tunnels.length; i++)
			{
				CBlob@ tunnel = tunnels[i];
				if (tunnel is null)
				{
					menu.AddButton("$CANCEL$", "You are here", Vec2f(2, 2));
				}
				else
				{
					CBitStream params;
					params.write_u16(callerID);
					params.write_u16(tunnel.getNetworkID());
					menu.AddButton(getTravelIcon(pBlob, tunnel), getTravelDescription(pBlob, tunnel), this.getCommandID("teleport"), Vec2f(2, 2), params);
				}
			}
			AddTeleportButton(menu, player, false);
			if (basic)
			{
				for (uint i = 0; i < players.length; i++)
				{
					CBlob@ p = players[i];
					if (p !is pBlob)
					{
						CBitStream params;
						params.write_u16(callerID);
						params.write_u16(p.getNetworkID());
						menu.AddButton(getTravelIcon(pBlob, p), "Teleport to " + p.getInventoryName(), this.getCommandID("teleport"), Vec2f(1, 1), params);
					}
				}
			}
		}
	}
	
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pick team"))
	{
		if (getNet().isServer())
		{
			// build menu for them
			CBlob@ caller = getBlobByNetworkID(params.read_u16());

			if (caller !is null)
			{
				caller.server_setTeamNum(params.read_u8());
			}
		}
	}
	else if (cmd == this.getCommandID("pick class"))
	{
		if (getNet().isServer())
		{
			// build menu for them
			CBlob@ caller = getBlobByNetworkID(params.read_u16());

			if (caller !is null)
			{
				string classconfig = params.read_string();
				CBlob @newBlob = server_CreateBlob(classconfig, caller.getTeamNum(), caller.getPosition());

				if (newBlob !is null)
				{
					// copy health and inventory
					// make sack
					CInventory @inv = caller.getInventory();

					if (inv !is null)
					{
						if (caller.getInventory() !is null)
						{
							caller.MoveInventoryTo(newBlob);
						}
					}

					// set health to be same ratio
					float healthratio = caller.getHealth() / caller.getInitialHealth();
					newBlob.server_SetHealth(newBlob.getInitialHealth() * healthratio);

					// plug the soul
					newBlob.server_SetPlayer(caller.getPlayer());
					newBlob.setPosition(caller.getPosition());

					caller.Tag("switch class");
					caller.server_SetPlayer(null);
					caller.server_Die();
				}
			}
		}
	}
	else if (cmd == this.getCommandID("teleport"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ tunnel = getBlobByNetworkID(params.read_u16());
		if (caller !is null && tunnel !is null)
		{
			if (getNet().isServer())
			{
				Travel(caller, tunnel);
			}
		}
		else if (caller !is null && caller.isMyPlayer())
			Sound::Play("NoAmmo.ogg");
	}
	else if (cmd == this.getCommandID("teleport end"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		bool left = params.read_bool();
		if (caller !is null)
		{
			if (getNet().isServer())
			{
				Travel(caller, left);
			}
		}
		else if (caller !is null && caller.isMyPlayer())
			Sound::Play("NoAmmo.ogg");
	}
	else if (cmd == this.getCommandID("none"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null && caller.isMyPlayer())
			getHUD().ClearMenus();
	}
}








void Travel(CBlob@ caller, Vec2f pos)
{
	if (caller !is null)
	{
		if (caller.isAttached())   // attached - like sitting in cata? move whole cata
		{
			const int count = caller.getAttachmentPointCount();
			for (int i = 0; i < count; i++)
			{
				AttachmentPoint @ap = caller.getAttachmentPoint(i);
				CBlob@ occBlob = ap.getOccupied();
				if (occBlob !is null)
				{
					occBlob.setPosition(pos);
					occBlob.setVelocity(Vec2f_zero);
					occBlob.getShape().PutOnGround();
				}
			}
		}
		// move caller
		caller.setPosition(pos);
		caller.setVelocity(Vec2f_zero);
		caller.getShape().PutOnGround();

		Sound::Play("Travel.ogg", caller.getPosition());
	}
}

void Travel(CBlob@ caller, CBlob@ tunnel)
{
	if (caller !is null && tunnel !is null)
	{
		Travel(caller, tunnel.getPosition());
	}
}

void Travel(CBlob@ caller, bool left)
{
	CMap@ map = getMap();
	if (map !is null)
	{
		f32 x = left ? 32.0f : map.tilemapwidth * map.tilesize - 32.0f;
		Travel(caller, Vec2f(x, map.getLandYAtX(s32(x / map.tilesize)) * map.tilesize - 16.0f));
	}
}

bool getTunnelsForButtons(CBlob@ this, CBlob@[]@ tunnels)
{
	CBlob@[] list;
	getBlobsByTag("travel tunnel", @list);
	Vec2f thisPos = this.getPosition();

	// add left tunnels
	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum() && blob.getPosition().x < thisPos.x)
		{
			bool added = false;
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint tunnelInd = 0; tunnelInd < tunnels.length; tunnelInd++)
			{
				CBlob@ tunnel = tunnels[tunnelInd];
				if ((tunnel.getPosition() - thisPos).getLength() < distToBlob)
				{
					tunnels.insert(tunnelInd, blob);
					added = true;
					break;
				}
			}
			if (!added)
				tunnels.push_back(blob);
		}
	}

	tunnels.push_back(null);	// add you are here

	// add right tunnels
	const uint tunnelIndStart = tunnels.length;

	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum() && blob.getPosition().x >= thisPos.x)
		{
			bool added = false;
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint tunnelInd = tunnelIndStart; tunnelInd < tunnels.length; tunnelInd++)
			{
				CBlob@ tunnel = tunnels[tunnelInd];
				if ((tunnel.getPosition() - thisPos).getLength() > distToBlob)
				{
					tunnels.insert(tunnelInd, blob);
					added = true;
					break;
				}
			}
			if (!added)
				tunnels.push_back(blob);
		}
	}
	return tunnels.length > 0;
}

string getTravelIcon(CBlob@ player, CBlob@ tunnel)
{
	if (tunnel.getName() == "war_base")
		return "$WAR_BASE$";

	if (tunnel.getPosition().x > player.getPosition().x)
		return "$TRAVEL_RIGHT$";

	return "$TRAVEL_LEFT$";
}

string getTravelDescription(CBlob@ player, CBlob@ tunnel)
{
	if (tunnel.getName() == "war_base")
		return "Return to base";

	if (tunnel.getPosition().x > player.getPosition().x)
		return "Travel right";

	return "Travel left";
}