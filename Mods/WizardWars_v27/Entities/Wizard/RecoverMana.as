//recover mana
#include "WizardCommon.as";
const u8 BASE_MANA_REGEN_RATE = 3;
const u8 TEST_MANA_REGEN_RATE = 10;

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	
	if ( sv_test )
		this.set_u8("mana regen rate", TEST_MANA_REGEN_RATE);	
	else
		this.set_u8("mana regen rate", BASE_MANA_REGEN_RATE);	
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated() < 2)
	{
		u8 manaRegenRate = BASE_MANA_REGEN_RATE;
	
		//adjusting mana regen rate based on team balance
		uint team0 = 0;
		uint team1 = 0;
		for (u32 i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ p = getPlayer(i);
			if (p !is null)
			{
				if (p.getTeamNum() == 0)
					team0++;
				else if (p.getTeamNum() == 1)
					team1++;
			}
		}
		
		if ( team0 > 0 && team1 > 0 )
		{
			CPlayer@ thisPlayer = this.getPlayer();
			if ( thisPlayer !is null )
			{
				int thisPlayerTeamNum = thisPlayer.getTeamNum(); 
				
				if ( team0 < team1 && thisPlayerTeamNum == 0 )
				{
					manaRegenRate *= (team1/team0);
				}
				else if ( team1 < team0 && thisPlayerTeamNum == 1 )
				{
					manaRegenRate *= (team0/team1);
				}
			}
		}
		
		this.set_u8("mana regen rate", manaRegenRate);	
	}
	
	if (getGameTime() % getTicksASecond() == 0)
	{
		WizardInfo@ wiz;
		if (!this.get( "wizardInfo", @wiz )) {
			return;
		}
		
		u8 adjustedManaRegenRate = this.get_u8("mana regen rate");
		
		//now regen mana
		s32 mana = wiz.mana;
		s32 maxMana = wiz.maxMana;
		if (mana < maxMana)
		{
			if (maxMana - mana >= adjustedManaRegenRate)
				wiz.mana += adjustedManaRegenRate;
			else
				wiz.mana = maxMana;
		}
	}
}