//Made by Vamist
//Team level holder


void onInit(CRules@ this)
{
	onRestart(this); //Go run restart stuff
}

void onRestart(CRules@ this)
{
	print("Restarting, setting all levels to 0");
	this.set_u8("0TL",0);//Team num + TL (Team level)
	this.set_u8("1TL",0);
}