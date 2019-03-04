#include "StandardRespawnCommand.as";

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-10); //background/
	this.getShape().getConsts().mapCollisions = false;

	this.set_Vec2f("shop offset", Vec2f_zero);

	//stuff from tentlogic.as
	InitClasses(this);
	this.Tag("change class drop inventory");
	this.addCommandID("button_join");

	this.Tag("faction_base");
	//this.Tag("set");

	// minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
	this.set_bool("created", false);
	
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	SetNearbyBlobsToTeam(this, 7, this.getTeamNum(), 180.0f);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// create menu for class change
	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$change_class$", Vec2f(0, 0), this, SpawnCmd::buildMenu, "Swap Class", params);
	}
	if (this.isOverlapping(caller))
	{
		if (caller.getTeamNum() >= 100)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("button_join"), "Join the Fac", params);
			//button.SetEnabled(recruitment_enabled && upkeep_gud);
		}
		/*
		if (caller.getTeamNum() == this.getTeamNum())
		{
			CBitStream params_menu;
			params_menu.write_u16(caller.getNetworkID());
			// CButton@ button_menu = caller.CreateGenericButton(11, Vec2f(14, 5), this, this.getCommandID("faction_menu"), "Faction Management", params_menu);
			CButton@ button_menu = caller.CreateGenericButton(11, Vec2f(1, -8), this, this.getCommandID("faction_menu"), "Faction Management", params_menu);
		}*/
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("button_join"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CBlob@ blob = getBlobByNetworkID(id);
		
		u8 myTeam = this.getTeamNum();
	
		if (myTeam < 7 && blob !is null && this.isOverlapping(blob) && blob.hasTag("player"))
		{
			CPlayer@ p = blob.getPlayer();
			if (p !is null)
			{
				if (p.getTeamNum() >= 100)
				{
					this.getSprite().PlaySound("party_join.ogg");
						
					if (getNet().isServer())
					{	
						p.server_setTeamNum(myTeam);
						CBlob@ newPlayer = server_CreateBlob("builder", myTeam, blob.getPosition());
						newPlayer.server_SetPlayer(p);
						blob.server_Die();
					}
				}
			}
		}
	}
	else onRespawnCommand(this, cmd, params);
}

void onChangeTeam(CBlob@ this, const int oldTeam )
{
	CBlob@[] forts;
	getBlobsByTag("faction_base", @forts);

	int newTeam = this.getTeamNum();
	int totalFortCount = forts.length;
	int oldTeamForts = 0;
	
	CRules@ rules = getRules();
	
	for(uint i = 0; i < totalFortCount; i++)
	{
		int fortTeamNum = forts[i].getTeamNum();
		if (fortTeamNum == oldTeam) oldTeamForts++;
	}
	
	if (oldTeamForts <= 0)
	{
		if (getNet().isServer())
		{
			CBitStream bt;
			bt.write_u8(newTeam);
			bt.write_u8(oldTeam);

			getRules().SendCommand(getRules().getCommandID("captureFac"), bt);
		}
	}
	else SetNearbyBlobsToTeam(this, oldTeam, newTeam, 178.0f);
}

void SetNearbyBlobsToTeam(CBlob@ this, const int oldTeam, const int newTeam, const int radius)
{
	CBlob@[] teamBlobs;
	this.getMap().getBlobsInRadius(this.getPosition(), radius, @teamBlobs);

	for (uint i = 0; i < teamBlobs.length; i++)
	{
		CBlob@ b = teamBlobs[i];
		if(!b.hasTag("faction_base") && b.getName() != "ruins" && (b.getTeamNum() == oldTeam || b.getTeamNum() > 6) && !b.hasTag("player"))
		{
			b.server_setTeamNum(newTeam);
		}
	}
}

void onDie(CBlob@ this)
{
	CBlob@[] forts;
	getBlobsByTag("faction_base", @forts);

	u8 team = this.getTeamNum();
	int totalFortCount = forts.length;
	int TeamForts = 0;
	
	for(uint i = 0; i < totalFortCount; i++)
	{
		int fortTeamNum = forts[i].getTeamNum();
	
		if (fortTeamNum == team) TeamForts++;
	}
	
	if (TeamForts <= 0)
	{
		CBitStream params;
		params.write_u8(team);
		getRules().SendCommand(getRules().getCommandID("killFac"), params);
	}
}