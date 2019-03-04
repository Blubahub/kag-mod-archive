#include "Particles.as";

int particleNumber = 0;


void onTick(CPlayer@ player)
{
	if(dashGoing == true) // fix this, move to diffrent file, low tick rate (maybe 1?)
	{
		if(gameTimeEnd > getGameTime())
		{
			print("yes");
			CBlob@ this = player.getBlob();
			if(getGameTime() > gameTimeStart + 7 && particleNumber == 3 )	
			{
				this.setVelocity(OldVelocity);
				particleNumber = 4;
			}
			else if(getGameTime() > gameTimeStart + 5 && particleNumber == 2)
			{
				DashEffectTemp(this.getPosition());
				particleNumber = 3;
			}
			else if(getGameTime() > gameTimeStart + 3 && particleNumber == 1)
			{
				DashEffectTemp(this.getPosition());
				particleNumber = 2;
			}
			else if(getGameTime() > gameTimeStart + 1 && particleNumber == 0)
			{
				DashEffectTemp(this.getPosition());
				particleNumber = 1;
			}
			/*else if(getGameTime() > gameTimeStart + 10)
			{
				DashEffectTemp(this.getPosition());
			}*/
		}
	}
	else
	{
		if(!(particleNumber == 0))
		{
			particleNumber = 0;
		}
	}
}
