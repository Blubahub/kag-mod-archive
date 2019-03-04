#include "Diplomat_Main.as";
#include "StandardRespawnCommand.as";

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("HumanMainSpawn", Vec2f(0.0f, -4.0f));
	InitClasses(this);
	this.Tag("change class drop inventory");

	this.Tag("respawn");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)//TODO Cleanup
{

	CRules@ rules = getRules();
	u8 team1Status = getDiplomatStatus(rules,0,1);
	u8 team2Status = getDiplomatStatus(rules,0,2);
	u8 team3Status = getDiplomatStatus(rules,0,3);
	switch(caller.getTeamNum())
	{
		case 0:
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());

			CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);
			break;
		}

		case 1:
		{
			if(getDiplomatStatus(rules,0,1) == 3)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());

				CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);
			}
			break;
		}

		case 2:
		{
			if(getDiplomatStatus(rules,0,2) == 3)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());

				CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);
			}
			break;
		}

		case 3:
		{
			if(getDiplomatStatus(rules,0,3) == 3)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());

				CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);
			}
			break;
		}

	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}
