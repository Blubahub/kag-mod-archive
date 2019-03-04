
const string[] powerupTags = { "powerup superjump",
                               "powerup slash timestop",
                               "powerup fast arrows"
                             };

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-500.0f);
	this.getSprite().animation.frame = (this.getNetworkID() * 31) % 4;
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound(CFileMatcher("Heart.ogg").getFirst());
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}