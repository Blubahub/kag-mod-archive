//Made by Vamist
#define CLIENT_ONLY


//What is what
//bool HungerStarted is so you know that the blob has hunger
//u8 hungerNum is the hunger number, if 0, it will die, if higher then 100 it will reset back to 100
//to add hunger, just get the blob, and add blob.add_u8("hungerNum",1) (this will increase hungerNum by 1)
//

void onInit(CRules@ this)
{
	//
}



void onTick(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();
	if(p !is null)
	{
		CBlob@ blob = p.getBlob();
		if(blob !is null)
		{
			if(blob.get_bool("hungerStarted"))
			{
				if((getGameTime() % 10) == 0)//change this to how often you want it to tick down
				{
					blob.add_u8("hungerNum", -1);
				}

				u8 hungNum = blob.get_u8("hungerNum");
				if(hungNum == 0)
				{
					blob.server_Die();
				}
				else if(hungNum > 100)
				{
					blob.set_u8("hungerNum",100);
				}
			}
			else
			{
				blob.set_bool("hungerStarted", true);
				blob.set_u8("hungerNum", 100);
			}
		}
	}
}
