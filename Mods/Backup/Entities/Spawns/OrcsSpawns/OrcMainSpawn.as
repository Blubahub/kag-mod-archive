#include "Diplomat_Main.as";
#include "StandardRespawnCommand.as";

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("OrcMainSpawn", Vec2f(0.0f, -4.0f));
	InitClasses(this);
	this.Tag("change class drop inventory");
	this.addCommandID("Looking at EXP");

	this.Tag("respawn");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)//TODO CleanUP
{

	CRules@ rules = getRules();
	u8 team1Status = getDiplomatStatus(rules,3,1);
	u8 team2Status = getDiplomatStatus(rules,3,2);
	u8 team3Status = getDiplomatStatus(rules,0,3);
	switch(caller.getTeamNum())
	{
		case 0:
		{
			if(getDiplomatStatus(rules,0,1) == 3)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());

				CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);
			}
			break;
		}

		case 1:
		{
			if(getDiplomatStatus(rules,1,3) == 3)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());

				CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);
			}
			break;
		}

		case 2:
		{
			if(getDiplomatStatus(rules,1,2) == 3)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());

				CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);
			}
			break;
		}

		case 3:
		{
			CBitStream paramsBlob;
			CBitStream paramsPlayer;
			paramsBlob.write_u16(caller.getNetworkID());
			paramsPlayer.write_u16(caller.getPlayer().getNetworkID());


			CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), paramsBlob);
			CButton@ button2 = caller.CreateGenericButton("$change_class$", Vec2f(-12, 7), this, this.getCommandID("Looking at EXP"), getTranslatedString("Level up"), paramsPlayer);
		}

	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("Looking at EXP"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_u16());
		if(player !is null)
		{
			print("done");
			player.Tag("Menu stuff");
	
			player.Tag("EXP Menu");
		}
	}
	else
	{

		onRespawnCommand(this, cmd, params);
	}
}
