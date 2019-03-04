//day time bonuses for human players
#define SERVER_ONLY
#include "RunnerCommon.as";
// regen hp back to
const string max_prop = "regen maximum";
const string rate_prop = "regen rate";
const string frequency_prop = "regen frequency";

void onInit(CBlob@ this)
{
	if (!this.exists(max_prop))
		this.set_f32(max_prop, this.getInitialHealth());

	if (!this.exists(rate_prop))
		this.set_f32(rate_prop, 0.5f); //0.5 hearts per second

	if (!this.exists(frequency_prop))
		this.set_u32(frequency_prop, 240); //how often the heal effect happens

	//this.getCurrentScript().tickFrequency = 200; //legacy, this is an efficient way to apply a healing effect, 
												   //but we cant have movement buffs or anything else
												   //if it's not ticking constantly
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if (map.getDayTime()<0.8 || map.getDayTime()>0.2) //regen hp only at day
    {
    	if(this.getTeamNum() == 0)
    	{
    		//day time movement buff
    		RunnerMoveVars@ moveVars;
			if (this.get("moveVars", @moveVars))			
			{
				moveVars.walkFactor = 1.2f;
				moveVars.jumpFactor = 1.1f;
			}

			if ((getGameTime() % this.get_u32(frequency_prop)) == 0 )
			{	//day time hp regen
    			this.server_Heal(this.get_f32(rate_prop));
    		}
    	}
	}

	if (this.isAttached()) //greg workaround TODO: make it a button on the greg similar to shop
	{
		if (this.isKeyJustPressed(key_use))
		{
			this.server_DetachFromAll();
		}
	}
}
