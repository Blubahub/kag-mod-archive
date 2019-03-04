void onInit(CBlob@ this)
{
	this.setPosition(this.getPosition()+Vec2f(0,-4));
	
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;

	this.getSprite().SetZ(50.0f);   // push to background
}



		
		
void onTick(CBlob@ this)
{
	int blueplayers = 0;
	int blueplayersalive = 0;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(!b.hasTag("dead") && b.hasTag("player") && b.getTeamNum() == 0)
			{
				blueplayers += 1;
			}
		}
	}
	
	CBlob@[] players;
	getBlobsByTag("player", @players);
	for (uint i = 0; i < players.length; i++)
	{
		CPlayer@ player = players[i].getPlayer();
		if (player !is null && player.getTeamNum() == 0)
		{
			blueplayersalive += 1;
		}
	}
	
	if(blueplayers > blueplayersalive/2)getRules().Tag("completed_level_alternate");
}