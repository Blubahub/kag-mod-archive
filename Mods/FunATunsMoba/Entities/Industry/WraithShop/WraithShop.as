// Knight Workshop

#include "Requirements.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("getthis");
	this.set_u32("minionCD", 0);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");
}

CBlob@ SpawnMook(Vec2f pos, const string &in classname, u8 team)
{
	CBlob@ blob = server_CreateBlobNoInit(classname);
	if (blob !is null)
	{
		//setup ready for init
		blob.server_setTeamNum(team);
		blob.setPosition(pos + Vec2f(4.0f, 0.0f));
		blob.Init();
		blob.Tag("bot");
		blob.getBrain().server_SetActive(true);
		blob.server_SetTimeToDie(60 * 3);	 // delete after 6 minutes
	}
	return blob;
}

void onTick(CBlob@ this)
{
	if( this.getTeamNum() < 3 && this.get_u32("minionCD") > 800)
	{
		Vec2f pos = this.getPosition();
		SpawnMook(pos, "wraith", this.getTeamNum());
		this.set_u32("minionCD", 0);
	}
	else{
		this.set_u32("minionCD", this.get_u32("minionCD") + 1 );
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}