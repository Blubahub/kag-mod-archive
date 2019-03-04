#include "MakeMat.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50); //-60 instead of -50 so sprite layers are behind ladders
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	
	this.Tag("builder always hit");
	
	this.set_s16("smoke",0);
	this.Tag("takes_smoke");
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	if(this.get_s16("smoke") >= 1){
		CBlob@ smokey = server_CreateBlobNoInit("smoke");
		smokey.setPosition(this.getPosition() + Vec2f(0, -10));
		smokey.setVelocity(Vec2f((XORRandom(1000)-500.0f)/2000.0f,-1));
		smokey.server_setTeamNum(-1);
		smokey.Init();
		
		this.set_s16("smoke",this.get_s16("smoke")-1);
	}
}