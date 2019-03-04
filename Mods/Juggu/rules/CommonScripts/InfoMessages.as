void onInit(CRules@ this)
{
	/*if(getNet().isServer())
	{
		this.addCommandID("info");
		this.set_u32("info timer", 0);
	}*/
}

void onTick(CRules@ this)
{
	/*if(getNet().isServer())
	{
		u32 infoTimerDuration = 60 * getTicksASecond();
		u32 infoTimer = this.get_u32("info timer");
		infoTimer += 1;
		
		CBitStream params;
		if(infoTimer == infoTimerDuration || infoTimer == infoTimerDuration * 2)
		{
			if(infoTimer == infoTimerDuration * 2)
			{
				infoTimer = 0;
				params.write_u8(1);
			}
			else
			{
				params.write_u8(0);
			}
			this.SendCommand(this.getCommandID("info"), params, true);
		}
		
		this.set_u32("info timer", infoTimer);
	}*/
	
	if(getNet().isClient())
	{
		if((getGameTime() + 1) % getTicksASecond() == 0 && !this.exists("start info"))
		{
			this.set_bool("start info", true);
			client_AddToChat("== Type !info for mod info. ==", SColor(255, 127, 0, 127));
		}
	}
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!info")
	{
		if(player.isMyPlayer())
		{
			chatModInfo();
		}
		return false;
	}
	else if (text_in == "!nova")
	{
		if(player.isMyPlayer())
		{
			chatNovaInfo();
		}
		return false;
	}
	
	return true;
}

/*void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("info"))
	{
		if(getNet().isClient())
		{
			u8 param = params.read_u8();
			if(param == 0)
			{
				client_AddToChat("== Type !info for mod info. ==", SColor(255, 127, 0, 127));
			}
			else
			{
				client_AddToChat("== Type !info for mod info. == ", SColor(255, 127, 0, 127));
			}
		}
	}
}*/

void chatModInfo()
{
	SColor color(255, 127, 0, 0);
	client_AddToChat("=== Juggernaut Mod ===", color);
	client_AddToChat("Created by: Bunnie (Team Leader/Server Host), Koi_ (Programmer), and merser433 (Spriter/Designer)", color);
	client_AddToChat("For every 6 Heroes there will be 1 Juggernaut.", color);
	client_AddToChat("Players are cycled for Juggernaut so everyone will get their turn.", color);
	client_AddToChat("Juggernauts have 60 hearts. They deal 1.5 damage for jabs, and 3 damage for slashes.", color);
	client_AddToChat("Juggernauts also have a special Nova ability. Type !nova for info.", color);
}

void chatNovaInfo()
{
	SColor color(255, 127, 0, 0);
	client_AddToChat("", color);
	client_AddToChat("=== Juggernaut Nova Ability ===", color);
	client_AddToChat("Press [LSHIFT] as a Juggernaut to use your Nova ability.", color);
	client_AddToChat("When used, the Nova ability will push away any players or objects near you at high velocity.", color);
	client_AddToChat("After use, your Nova ability will take 20 seconds to recharge.", color);
	client_AddToChat("", color);
}