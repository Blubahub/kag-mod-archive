void onInit(CBlob@ this)
{
	AddIconToken("$TOGGLE_FLIGHT_ON$", "SR_InventoryIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$TOGGLE_FLIGHT_OFF$", "SR_InventoryIcons.png", Vec2f(32, 32), 3);
	this.addCommandID("toggle flight");

	AddIconToken("$TOGGLE_PHASE_ON$", "SR_InventoryIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$TOGGLE_PHASE_OFF$", "SR_InventoryIcons.png", Vec2f(32, 32), 4);
	this.addCommandID("toggle phase");

	AddIconToken("$TOGGLE_AQUA_ON$", "SR_InventoryIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$TOGGLE_AQUA_OFF$", "SR_InventoryIcons.png", Vec2f(32, 32), 5);
	this.addCommandID("toggle aqua");

	//experimental
	/*
	AddIconToken("$TOGGLE_NODMG_ON$", "BuilderIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$TOGGLE_NODMG_OFF$", "BuilderIcons.png", Vec2f(32, 32), 2);
	this.addCommandID("toggle nodmg");
	*/
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu@ gridmenu)
{
	const Vec2f MENU_POS = this.getName() == "builder"?
		gridmenu.getUpperLeftPosition() + Vec2f(-36, -180):
		this.getName() == "archer"?
		gridmenu.getUpperLeftPosition() + Vec2f(-84, -56):
		//knight and all other
		gridmenu.getUpperLeftPosition() + Vec2f(-36, -56);

	const int numButtons = 3;
	// const Vec2f MENU_POS = Vec2f(500, 500);
	CGridMenu@ sandboxTools = CreateGridMenu(MENU_POS, this, Vec2f(1, numButtons), "");
	if(sandboxTools !is null)
	{
		sandboxTools.SetCaptionEnabled(false);
		sandboxTools.deleteAfterClick = false;

		if (this !is null)
		{
			CBitStream params;
			params.write_u16(this.getNetworkID());

			if (this.get_bool("flight"))
			{
				CGridButton@ toggleflight =
					sandboxTools.AddButton("$TOGGLE_FLIGHT_OFF$", "",
					this.getCommandID("toggle flight"), Vec2f(1, 1), params);

				if(toggleflight !is null)
					toggleflight.SetHoverText("Stop flying\n");
			}
			else
			{
				CGridButton@ toggleflight =
					sandboxTools.AddButton("$TOGGLE_FLIGHT_ON$", "",
					this.getCommandID("toggle flight"), Vec2f(1, 1), params);

				if(toggleflight !is null)
					toggleflight.SetHoverText("Start flying\n");
			}

			if (!this.getShape().getConsts().collidable)
			{
				CGridButton@ togglephase =
					sandboxTools.AddButton("$TOGGLE_PHASE_OFF$", "",
					this.getCommandID("toggle phase"), Vec2f(1, 1), params);

				if (togglephase !is null)
					togglephase.SetHoverText("Stop phasing through entities\n");
			}
			else
			{
				CGridButton@ togglephase =
					sandboxTools.AddButton("$TOGGLE_PHASE_ON$", "",
					this.getCommandID("toggle phase"), Vec2f(1, 1), params);

				if (togglephase !is null)
					togglephase.SetHoverText("Phase through entities\n");
			}

			if (this.get_bool("aqua"))
			{
				CGridButton@ toggleaqua =
					sandboxTools.AddButton("$TOGGLE_AQUA_OFF$", "",
					this.getCommandID("toggle aqua"), Vec2f(1, 1), params);

				if (toggleaqua !is null)
					toggleaqua.SetHoverText("Stop breathing underwater\n");
			}
			else
			{
				CGridButton@ toggleaqua =
					sandboxTools.AddButton("$TOGGLE_AQUA_ON$", "",
					this.getCommandID("toggle aqua"), Vec2f(1, 1), params);

				if (toggleaqua !is null)
					toggleaqua.SetHoverText("Breathe underwater\n");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	// cause SOMEONE couldn't finish their getNameFromCommandID functions...
	string[] possibleCommands = {"toggle flight", "toggle phase", "toggle aqua"};

	string cmdName;
	for (int i=0;i<possibleCommands.length;i++)
	{
		if (this.getCommandID(possibleCommands[i]) == cmd)
		{
			cmdName = possibleCommands[i];
			break;
		}
	}

	string[] tokens = cmdName.split(" ");
	if (tokens.length >= 2 && tokens[0] == "toggle")
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);

		if (caller !is null)
		{
			if (tokens[1] == "phase")//toggle phasing
				caller.getShape().getConsts().collidable =
					!caller.getShape().getConsts().collidable;
			else
			{
				caller.set_bool(tokens[1], !caller.get_bool(tokens[1]));
			}
		}
	}
}
