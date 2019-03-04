void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		string playersprite = "Builder_" + player.getUsername() + ".png";
		CFileImage@ image = CFileImage(playersprite);
		if (image.getSizeInPixels() == 65536)
		{
			this.getSprite().ReloadSprite("../Mods/SandboxReborn-1.4.3.7/Entites/Characters/Builder/Custom/"+playersprite);
		}
	}
}