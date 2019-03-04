//#include "CustomBlocks.as";

void onInit(CRules@ this)
{
	Reset(this, getMap());
}

void onRestart(CRules@ this)
{
	Reset(this, getMap());
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	Reset(rules, this);
}

void Reset(CRules@ this, CMap@ map)
{
	if (map !is null)
	{
		map.SetBorderFadeWidth(16);
		
		// map.topBorder = false;
		
		map.SetBorderColourTop(SColor(255, 0, 0, 0));
		map.SetBorderColourLeft(SColor(255, 0, 0, 0));
		map.SetBorderColourRight(SColor(255, 0, 0, 0));
		map.SetBorderColourBottom(SColor(255, 0, 0, 0));
	}
	// if (getNet().isServer())
	// {	
		// u8 r = XORRandom(10);
		// print("r = " + r);
		
		// if (r == 0) 
		// {
			// CBlob@ desert = server_CreateBlob("info_desert", -1, Vec2f(0, 0));
		// }
		// else if (r == 1)
		// {
			// CBlob@ desert = server_CreateBlob("info_jungle", -1, Vec2f(0, 0));
		// }
	// }
}

void onTick(CRules@ this)
{
	if (getGameTime() % (60 * 30) == 0) Reset(this, getMap()); // Damn hack
	
	// CMap@ map = getMap();
	// map.SetBorderFadeWidth(16);
	
	// map.SetBorderColourTop(SColor(0, 0, 0, 0));
	// map.SetBorderColourLeft(SColor(255, 0, 0, 0));
	// map.SetBorderColourRight(SColor(255, 0, 0, 0));
	// map.SetBorderColourBottom(SColor(255, 0, 0, 0));
	
	// map.SetBorderColourTop(SColor(255, 0, 0, 0));
	// map.SetBorderColourLeft(SColor(255, 0, 0, 0));
	// map.SetBorderColourRight(SColor(255, 0, 0, 0));
	// map.SetBorderColourBottom(SColor(255, 0, 0, 0));
}
