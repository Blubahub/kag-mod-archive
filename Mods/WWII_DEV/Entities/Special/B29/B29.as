#include "Hitters.as";
// const u32 fuel_timer_max = 30 * 600;


void onInit(CBlob@ this)
{

	CMap@ map = this.getMap();
	float map_height = map.tilesize * map.tilemapheight;
	this.setPosition(Vec2f(50, map_height * -1 -100));

	CSprite@ sprite = this.getSprite();

	if (sprite !is null)
	{
		Animation@ anim = sprite.addAnimation("default", XORRandom(3) + 3, true);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
	}

//	pos = this.getPosition();

}

void onInit(CShape@ this)
{

//this.SetGravityScale(-222.0f);


}

void onTick(CBlob@ this)
{
	Vec2f pos = this.getPosition();

	CMap@ map = this.getMap();
	float map_right = map.tilesize*map.tilemapwidth;
	float map_middle = map_right / 2;

	float drop_min = map_middle - 5;
	float drop_max = map_middle + 5;

	Vec2f vel = this.getVelocity();
	this.setVelocity(Vec2f(5, -0.6));


	if(!this.hasTag("dropped"))
	{

	if(pos.x > drop_min && pos.x < drop_max) {
		this.Tag("dropped");
		Vec2f bpos = pos + Vec2f(0, +15);
		CBlob@ blob = server_CreateBlob("mat_nuke", this.getTeamNum(), bpos);
		this.server_SetTimeToDie( 40 );

	} 

}
}
