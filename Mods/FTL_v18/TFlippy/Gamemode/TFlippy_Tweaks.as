void onInit(CRules@ this)
{
	CMap@ map = getMap();
	SColor col = SColor(0, 0, 0, 0);
	
	map.SetBorderColourLeft(col);
	map.SetBorderColourRight(col);
	map.SetBorderColourTop(col);
	map.SetBorderColourBottom(col);
	map.SetBorderFadeWidth(1);
}

void onRestart(CRules@ this)
{

}

void onReload(CRules@ this)
{

}

void onTick(CRules@ this)
{

}