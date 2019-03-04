// BF_Cyst script

#include "Hitters.as";

const f32 DAMAGE = 0.5f;
const f32 AOE = 24.0f;

const u8 triggerTime = 90;

void onInit(CBlob@ this)
{
	this.set_u8( "gooTime", 50 );
	this.getCurrentScript().tickIfTag = "activated";
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		this.Tag("activated");	
        this.SetLightRadius(5.0f);
        this.SetLightColor(SColor(255, 128, 200, 0 ));
        this.SetLight(true);

		CSprite@ sprite = this.getSprite();
		// add a countdown animation
		sprite.SetAnimation("pulsate");

		// ToDo:add a custom sound
		sprite.PlaySound("/branches1.ogg", 1.5f, 0.65f);
	}
}

void onTick(CBlob@ this)
{
	if (!this.exists("triggerTimer"))
	{
		this.set_s32("triggerTimer", getGameTime() + triggerTime);
	}
	s32 Timer = this.get_s32("triggerTimer") - getGameTime();
	if (Timer <= 0)
	{
		Trigger(this);
	}
}

void Trigger(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	Vec2f checkPos = pos;

	// special FX
	this.getSprite().PlaySound( "splat.ogg" );
	ParticleAnimated( "/BF_GooSplat.png",
				  this.getPosition(), Vec2f(0,0), 0.0f, 2.0f, 3,
				  -0.1f, false );

	for (int count = 0; count < 9; count +=1)
	{
		Tile tileCheck = map.getTile(checkPos);
		//print("tileCheck      |  type = " + tileCheck.type);
		Create(this, map, checkPos, tileCheck, count);
		if (!this.exists("offset"))
		{
			this.set_s8("offset", -8);
			checkPos.Set(checkPos.x, checkPos.y + this.get_s8("offset"));
		}
		else
		{
			checkPos.RotateBy(45.0f, pos);
			//print("checkPos       |  check = " + checkPos.x +", "+ checkPos.y);
		}
	}
	this.server_Die();
}

void Create(CBlob@ this, CMap@ map, Vec2f checkPos, Tile tileCheck, int count)
{
	if (getNet().isServer())
	{
		if (canBeCreated(this, map, tileCheck))
		{
			CBlob@ ladder = server_CreateBlobNoInit("bf_laddercyst");
			ladder.server_setTeamNum(this.getTeamNum());
			ladder.set_u8("goo frame", count);
			ladder.setPosition(checkPos);
			ladder.Init();
		}
	}
}

void onDie( CBlob@ this )
{
	Vec2f pos = this.getPosition();
	CBlob@[] aoeBlobs;
	CMap@ map = getMap();
	map.getBlobsInRadius( pos, AOE, @aoeBlobs );

	if ( aoeBlobs.length() > 0 )
	{
		for ( u8 i = 0; i < aoeBlobs.length(); i++ )
		{
			CBlob@ blob = aoeBlobs[i];
			if ( !getMap().rayCastSolidNoBlobs( pos, blob.getPosition() ) )
			{
				if ( getNet().isServer() )
					this.server_Hit( blob, pos, Vec2f_zero, DAMAGE, 40, blob.getName() == "bf_gooball" );
			}
		}
	}
}

bool canBeCreated(CBlob@ this, CMap@ map, Tile tileCheck)
{
	return map.isTileBackground(tileCheck) && !map.isTileGrass(tileCheck.type) && !map.hasTileSolidBlobs(tileCheck);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (this.getTeamNum() == byBlob.getTeamNum());
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if ( !this.hasTag( "activated" ) || this.isAttached() || getGameTime() - this.get_u16( "detachTime" ) < 3 )
		return;
	
	if ( ( blob is null && solid ) || 
		 ( blob !is null && this.getTeamNum() != blob.getTeamNum() && blob.hasTag( "block" ) ) )
	{
		this.setPosition( point1 + normal * 1.4f * this.getRadius() );	
		this.getShape().SetStatic( true );
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.getShape().SetStatic( false );
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.getSprite().SetZ( -1.0f );
	this.set_u16( "detachTime", getGameTime() );
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return !this.hasTag("activated");
}