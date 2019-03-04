void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(getNet().isServer())
	if(blob !is null && blob.getName() == "ghost")
	{
		blob.server_Die();
		this.server_Heal(1);
	}
}