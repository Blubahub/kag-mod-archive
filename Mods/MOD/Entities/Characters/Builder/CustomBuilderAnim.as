void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		string playersprite = "Builder_" + player.getUsername() + ".png";
		CFileImage@ image = CFileImage(playersprite);
		if (image.getSizeInPixels() == 65536)
		{
			this.getSprite().ReloadSprite("../Mods/SopranosSandbox/Entities/Characters/Builder/Custom/"+playersprite);
		}
	}
}