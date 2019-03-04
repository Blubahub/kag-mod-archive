void DestroyNature()
{
	if(getNet().isClient())
	{
		Sound::Play("mysterious_perc_05.ogg");
		Sound::Play("ambient_cavern.ogg");
		
		SetScreenFlash(255, 255, 255, 255);
		ShakeScreen(15, 200, Vec2f(0, 0));
	}
}