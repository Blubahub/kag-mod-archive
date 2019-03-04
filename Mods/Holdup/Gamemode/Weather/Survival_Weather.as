uint start_rain = 0;
uint end_rain = 0;

void onInit(CRules@ this)
{	
	// print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
}

void onRestart(CRules@ this)
{
	u32 time = getGameTime();
	
	start_rain = time + 5000 + XORRandom(50000);
	end_rain = start_rain + XORRandom(6000);
	print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
}

void onTick(CRules@ this)
{
	if (getNet().isServer())
	{
		u32 time = getGameTime();
				
		if (time == start_rain)
		{
			CBlob@[] rain;
			getBlobsByName("info_desert", @rain);
			// getBlobsByName("info_dead", @rain);
			
			if (rain.length == 0)
			{
				CBlob@ rain = server_CreateBlobNoInit("rain");
				// rain.server_SetTimeToDie(end_rain - start_rain);
				rain.Init();
				rain.server_SetTimeToDie((end_rain - start_rain) / 30);
			}
			
			start_rain = time + 5000 + XORRandom(50000);
			end_rain = start_rain + XORRandom(6000);
			print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
		}
	}
}

// void onRender(CRules@ this)
// {
	
// }