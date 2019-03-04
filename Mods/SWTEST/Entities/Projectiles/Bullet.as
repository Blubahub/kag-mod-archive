
#include "Hitters.as";
#include "ExtraSparks.as";
#include "Knocked.as"

const s32 bomb_fuse = 120;
const f32 arrowMediumSpeed = 8.0f;
const f32 arrowFastSpeed = 13.0f;
//maximum is 15 as of 22/11/12 (see ArcherCommon.as)

const f32 ARROW_PUSH_FORCE = 6.0f;
const f32 SPECIAL_HIT_SCALE = 1.0f; //special hit on food items to shoot to team-mates

const s32 FIRE_IGNITE_TIME = 5;


//Arrow logic

//blob functions
void onInit(CBlob@ this)
{
	//this.getSprite().PlaySound("/AKFire.ogg");
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	this.Tag("projectile");

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
		{
			Animation@ anim = sprite.addAnimation("arrow", 0, false);
			anim.AddFrame(0);
			sprite.SetAnimation(anim);
			/*
			CSpriteLayer@ glow = sprite.addSpriteLayer("glow", "Bullet.png", 16, 8);
			if (glow !is null)
			{
				glow.setRenderStyle(RenderStyle::light);
				Animation@ anim2 = glow.addAnimation("default", 0, false);
				anim2.AddFrame(1);
				glow.SetRelativeZ(-0.1f);
				glow.SetAnimation(anim2);
			}*/
			this.SetLight(true);
		 	this.SetLightRadius(24.0f);
			SColor lightColor = SColor(255, 0, 0, 255);

		 	if(this.getTeamNum() == 1)
		 	{
		 		lightColor = SColor(255, 255, 0, 0);
		 		
		 	}

			this.SetLightColor(lightColor);

		}
	this.server_SetTimeToDie(0.8);
}

void onTick(CBlob@ this)
{

	CSprite@ sprite = this.getSprite();

	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);

	f32 angle;

	angle = (this.getVelocity()).Angle();
	Pierce(this);
	this.setAngleDegrees(-angle);
	if (this.getTickSinceCreated() < 10)
	{
		this.setVelocity(this.getVelocity()*1.05f);
	}

}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided"))
	{
		if (!solid && !blob.hasTag("flesh") &&
		        (blob.getName() != "mounted_bow" || this.getTeamNum() != blob.getTeamNum()))
		{
			return;
		}

		Vec2f initVelocity = this.getOldVelocity();
		f32 vellen = initVelocity.Length();
		if (vellen < 0.1f)
			return;

		f32 dmg = 0.0f;
		if (blob.getTeamNum() != this.getTeamNum())
		{
			dmg = 1.0f;
		}
			// this isnt synced cause we want instant collision for arrow even if it was wrong
		this.server_Hit(blob, point1, initVelocity, dmg, Hitters::crush);
		//not piercing
		this.Tag("collided");
		this.server_Die();

	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("projectile"))
	{
		return false;
	}	

	if(blob.hasTag("specialshot"))
	{
		return true;
	}


	bool check = this.getTeamNum() != blob.getTeamNum();
	if (!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (check)
	{
		if (this.hasTag("collided") || blob.hasTag("dead"))
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	return false;
}

void Pierce(CBlob @this, CBlob@ blob = null)
{
	Vec2f end;
	CMap@ map = this.getMap();
	Vec2f position = blob is null ? this.getPosition() : blob.getPosition();

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		ArrowHitMap(this, end, this.getOldVelocity(), 1.0f, Hitters::crush);
	}
}

void ArrowHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	this.Tag("collided");
	this.server_Die();
	//this.server_Die();
	if (velocity.Length() > arrowFastSpeed)
	{
		this.getSprite().PlaySound("StoneStep4.ogg");
	}
	else
	{
		this.getSprite().PlaySound("StoneStep4.ogg");
	}

	f32 radius = this.getRadius();

	f32 angle = velocity.Angle();

	this.set_u8("angle", Maths::get256DegreesFrom360(angle));

	Vec2f norm = velocity;
	norm.Normalize();
	norm *= (1.5f * radius);
	Vec2f lock = worldPoint - norm;
	this.set_Vec2f("lock", lock);

	this.Sync("lock", true);
	this.Sync("angle", true);

	this.setVelocity(Vec2f(0, 0));
	this.setPosition(lock);
	//this.getShape().server_SetActive( false );


	this.set_Vec2f("fire pos", (worldPoint + (norm * 0.5f)));
}


//random object used for gib spawning
Random _gib_r(0xa7c3a);
void onDie(CBlob@ this)
{	
	if(this.hasTag("collided"))
	{
		Vec2f sparkpos = this.getPosition();
		mapSparks(sparkpos, 0, 1.0f);

	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{

}

/*
void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	const u8 arrowType = this.get_u8("arrow type");
	// unbomb, stick to blob
	if (this !is hitBlob && customData == Hitters::crush)
	{
		// affect players velocity

		const f32 scale = specialArrowHit(hitBlob) ? SPECIAL_HIT_SCALE : 1.0f;

		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if (speed > ArcherParams::shoot_max_vel * 0.5f)
		{
			f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass() + 1) * scale;

			if (this.hasTag("bow arrow"))
			{
				force *= 1.3f;
			}

			hitBlob.AddForce(velocity * force);

			// stun if shot real close

			if (this.getTickSinceCreated() <= 4 &&
			        speed > ArcherParams::shoot_max_vel * 0.845f &&
			        hitBlob.hasTag("player"))
			{
				SetKnocked(hitBlob, 2);
				Sound::Play("/Stun", hitBlob.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			}
		}
	}
}*/

