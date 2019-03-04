// script for rooms that hold migrants in them

void onInit(CBlob@ this)
{
	this.Tag("migrant room"); 																
}
		   


void onRender( CSprite@ this )
{
	CPlayer@ p = getLocalPlayer();	
	if (p is null) { return; }
	CBlob@ blob = this.getBlob();
	const u32 nextRespawnTime = blob.get_u32("Respawn in");
	const int dif = nextRespawnTime - getGameTime();
	Vec2f pos = blob.getScreenPos();
}
