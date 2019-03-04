// BarrelSpawner.as

const u16 SPAWN_TICKS = 150;
const f32 SPAWN_VEL = 8.0f;

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);   // push to background
	
	this.getShape().SetRotationsAllowed(false);

	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");

	CShape@ shape = this.getShape();
	shape.SetStatic(true);
}

void onTick(CBlob@ this)
{
	if (!getNet().isServer())
		return;

	if (getGameTime() % SPAWN_TICKS == 0)
	{
		CBlob @barrelBlob = server_CreateBlob("barrel", -1, this.getPosition());
		if (barrelBlob !is null)
		{
			barrelBlob.Tag("Item");

			barrelBlob.set_bool("isRolling", true);
			if (XORRandom(2) == 0)
			{
				barrelBlob.SetFacingLeft(true);
			}
			else
			{
				barrelBlob.SetFacingLeft(false);
			}

			bool isRolling = this.get_bool( "isRolling" );	
			bool isFacingLeft = this.isFacingLeft();	
			CBitStream bt;
			bt.write_bool( isRolling );	
			bt.write_bool( isFacingLeft );	
			this.SendCommand( barrelBlob.getCommandID("sync state"), bt );

			Vec2f randVel = getRandomVelocity(0.0f, SPAWN_VEL, 360.0f);
			barrelBlob.setVelocity(randVel);
		}
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}
