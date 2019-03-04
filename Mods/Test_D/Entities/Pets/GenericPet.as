#include "Pets.as"

const f32 TOY_DISTANCE = 140.0f;
const f32 NO_PICKUP_DISTANCE = 16.0f;

void onInit(CBlob@ this)
{
	const u8 type = getPetType(this);

	string greeting;
	f32 owner_distance;
	f32 acceleration;
	f32 land_speed;
	f32 jump_amount;
	bool follow = false;
	string greet_sound;
	string far_sound;
	u8 toy = 255;
	bool fetch = false;
	bool fly = false;
	switch (type)
	{
		case CHICKEN:
			greeting = "Cluck Cluck!";
			owner_distance = 30.0f;
			acceleration = 0.3f;
			land_speed = 1.5f;
			jump_amount = 1.5f;
			follow = true;
			greet_sound = "ChickenGreet";
			far_sound = "ChickenFar";
			toy = TOY_NEST;
			break;

		case DOG:
			greeting = "Woof! Woof!";
			owner_distance = 10.0f;
			acceleration = 0.2f;
			land_speed = 2.5f;
			jump_amount = 2.5f;
			follow = true;
			greet_sound = "DogGreet";
			far_sound = "DogFar";
			toy = TOY_FRISBEE;
			fetch = true;
			break;

		case CAT:
			greeting = "Purrrr";
			owner_distance = 50.0f;
			acceleration = 0.5f;
			land_speed = 1.0f;
			jump_amount = 2.0f;
			follow = true;
			greet_sound = "CatPurr";
			far_sound = "CatMeow";
			toy = TOY_WOOLBALL;
			break;

		case FERN:
			toy = TOY_FERTILIZER;
			break;
		case CACTUS:
			//do we want some sort of words of wisdom here?
			greeting = "Ouch!";
			toy = TOY_FERTILIZER;
			break;

		case BUNNY:
			greeting = "Kip-kip";
			owner_distance = 15.0f;
			acceleration = 0.25f;
			land_speed = 1.1f;
			jump_amount = 5.0f;
			follow = true;
			greet_sound = "BunnySnore";
			far_sound = "BunnyScreech";
			toy = TOY_CARROT;
			break;			

		case PARROT:
			greeting = "";
			owner_distance = 0.5f;
			acceleration = 0.3f;
			land_speed = 2.0f;
			jump_amount = 0.0f;
			fly = follow = true;
			greet_sound = "ParrotHello";
			far_sound = "ParrotFar";
			toy = TOY_MASCOT;
			fetch = true;
			break;				
	}

	this.set_string("greeting", greeting);
	this.set_f32("acceleration", acceleration);
	this.set_f32("owner_distance", owner_distance);
	this.set_f32("land_speed", land_speed);
	this.set_f32("jump_amount", jump_amount);
	this.set_bool("follow", follow);
	this.set_string("greet_sound", greet_sound);
	this.set_string("far_sound", far_sound);
	this.set_u8("toy", toy);
	this.set_bool("fetch", fetch);
	this.set_bool("fly", fly);
}

void onTick(CBlob@ this)
{
	CBlob@ owner = getPetOwner(this);
	const u8 type = getPetType(this);
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	CSprite@ sprite = this.getSprite();
	const bool isOnGround = this.isOnGround();
	const bool isOnWall = this.isOnWall();
	const bool isOnLadder = this.isOnLadder();
	const u32 time = getGameTime();
	CMap@ map = getMap();

	const f32 land_speed = this.get_f32("land_speed");
	const f32 acceleration = this.get_f32("acceleration");
	const f32 owner_distance = this.get_f32("owner_distance");
	const f32 jump_amount = this.get_f32("jump_amount");
	const bool fly = this.get_bool("fly");
	bool follow = this.get_bool("follow");
	string animation = "stand";
	const u8 toyType = this.get_u8("toy");	

	if (owner !is null)
	{
		Vec2f followPos = owner.getPosition();
		f32 followDistance = owner_distance;

		//face if attached

		if (this.isAttached())
		{
			this.SetFacingLeft(owner.isFacingLeft());
		}

		// follow toy

		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(pos, TOY_DISTANCE, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @toy = blobsInRadius[i];
				if (toy !is this && toy.getName() == "toy" && getToyType(toy) == toyType)
				{
					Vec2f toyPos = toy.getPosition();
					if (!map.rayCastSolid (pos, toyPos))
					{
						const bool closeToOwner = (owner.getPosition() - toyPos).getLength() < NO_PICKUP_DISTANCE;
						if (!closeToOwner && !toy.isAttached()) // in some distnace from owner
						{
							follow = true;
							followPos = toyPos;
							followDistance = 1.5f;
						}
						else 
						//if (closeToOwner) {
						if (Maths::Abs(toyPos.x - owner.getPosition().x) < NO_PICKUP_DISTANCE){
							// drop if close to owner
							if (toy.isAttachedTo(this)){
								toy.server_DetachFromAll();
							}
						}
					}
				}
			}
		}		

		// follow owner or toy

		// cat is capricious
		if (follow && type == CAT){
			//follow = getGameTime() % 600 > 300;
		}

		// what to do on toy

		CBlob@[] overlapping;
		if (this.getOverlapping(@overlapping))
		{
			for (uint i = 0; i < overlapping.length; i++)
			{
				CBlob@ overlap = overlapping[i];
				if (overlap.getName() == "toy" && getToyType(overlap) == toyType){
					if (type == CAT && getGameTime() % 55 > 20)
					{
						overlap.setVelocity( Vec2f(0.0f, -0.65f) );
						animation = "play";
					}
					if (type == BUNNY && getGameTime() % 55 == 0)
					{
						sprite.PlaySound("StartChomp");
						overlap.server_Die();
					}		
					if (type == FERN || type == CACTUS)
					{
						sprite.PlaySound("StartChomp");
						overlap.server_Die();
					}	
				}
			}
		}		

		if (follow)
		{
			const f32 dist = Maths::Abs(followPos.x - pos.x);

			if (followPos.x > pos.x + followDistance)
			{
				vel.x += acceleration;
				this.SetFacingLeft(false);
				animation = vel.y < 0.01f ? "walk" : "stand";
			}
			else if (followPos.x < pos.x - followDistance)
			{
				vel.x -= acceleration;
				this.SetFacingLeft(true);
				animation = vel.y < 0.01f ? "walk" : "stand";
			}
			else if (!isOnGround && !this.isAttached())
			{
				animation = "walk";
			}

			const bool ceiling = getMap().rayCastSolid(pos, pos + Vec2f(0.0f, -32.0f));

			if (!ceiling)
			{
				// jump after owner

				if (!fly && (isOnGround && !isOnLadder && dist < 1.75f*followDistance && followPos.y < pos.y - (followDistance * 0.4f + 8.0f)) || (isOnWall && time % 3 == 0))
				{
					vel.y -= jump_amount;
				}

				// ladder

				if (!fly && isOnLadder && !isOnGround)
				{
					vel.y += (followPos.y > pos.y ? jump_amount : -jump_amount) * 0.3f;
				}

				// fly over stuff
				if (fly && isOnWall){
					vel.y -= jump_amount;
				}
			}

			if (fly)
			{
				const f32 height = -8.0f;
				this.getShape().SetGravityScale(0.5f);

				if (this.hasAttached()&& getGameTime() % 240 > 120) // fly away
				{
					vel.y -= acceleration;
				}
				else if (followPos.y > pos.y -height + followDistance)
				{
					vel.y += acceleration;
				}
				else if (followPos.y < pos.y -height - followDistance)
				{
					vel.y -= acceleration;					
				}
				else if (dist <= followDistance) {
					vel *= 0.5f;
					this.getShape().SetGravityScale(0.0f);
				}

				if (vel.getLengthSquared() > 0.6f){
					animation = "fly";
				}
				else {
					animation = "stand";
				}
			}

			// sounds

			if (dist > followDistance * 1.5f && XORRandom(70) == 0){
				PlayPetSound( this, "far_sound" );
			}
		}

	}

	vel.x = Maths::Clamp(vel.x, -land_speed, land_speed);

	this.setVelocity(vel);

	sprite.SetAnimation(animation);
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (this.get_bool("fetch") && blob.getName() == "toy" && getToyType(blob) == this.get_u8("toy"))
		{
			// pickup toy if far away from owner
			CBlob@ owner = getBlobByNetworkID(this.get_netid("owner"));
			if (owner !is null && (owner.getPosition() - blob.getPosition()).getLength() > NO_PICKUP_DISTANCE){
				this.server_AttachTo(blob, 1);
			}
		}
	}
}


// SPRITE

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	const u8 type = getPetType(blob);

	switch (type)
	{
		case FERN:
		{
			Animation@ anim = this.addAnimation("stand", 0, false);
			anim.AddFrame(6);
		}
		break;

		case CACTUS:
		{
			Animation@ anim = this.addAnimation("stand", 0, false);
			anim.AddFrame(7);
		}
		break;

		case CHICKEN:
		{
			Animation@ anim = this.addAnimation("stand", 0, false);
			anim.AddFrame(0);
		}
		{
			Animation@ anim = this.addAnimation("walk", 5, true);
			int[] frames = {1, 2, 3, 4};
			anim.AddFrames(frames);
		}
		break;

		case DOG:
		{
			Animation@ anim = this.addAnimation("stand", 0, false);
			anim.AddFrame(8);
		}
		{
			Animation@ anim = this.addAnimation("walk", 4, true);
			int[] frames = {9, 10, 11, 12};
			anim.AddFrames(frames);
		}
		break;

		case CAT:
		{
			Animation@ anim = this.addAnimation("stand", 0, false);
			anim.AddFrame(16);
		}
		{
			Animation@ anim = this.addAnimation("walk", 5, true);
			int[] frames = {17, 18, 19, 20};
			anim.AddFrames(frames);
		}
		{
			Animation@ anim = this.addAnimation("play", 5, true);
			int[] frames = {21, 22};
			anim.AddFrames(frames);
		}		
		break;

		case BUNNY:
		if (XORRandom(2) == 0)
		{
			{
				Animation@ anim = this.addAnimation("stand", 0, false);
				anim.AddFrame(32);
			}
			{
				Animation@ anim = this.addAnimation("walk", 4, true);
				int[] frames = {33, 34, 35, 36};
				anim.AddFrames(frames);
			}
		}
		else
		{
			{
				Animation@ anim = this.addAnimation("stand", 0, false);
				anim.AddFrame(40);
			}
			{
				Animation@ anim = this.addAnimation("walk", 4, true);
				int[] frames = {41, 42, 43, 44};
				anim.AddFrames(frames);
			}	
		}
		break;

		case PARROT:
		{
			Animation@ anim = this.addAnimation("stand", 0, false);
			anim.AddFrame(24);
		}
		{
			Animation@ anim = this.addAnimation("walk", 3, true);
			int[] frames = {25, 26, 27, 28};
			anim.AddFrames(frames);
		}
		{
			Animation@ anim = this.addAnimation("fly", 3, true);
			int[] frames = {25, 26, 27, 28};
			anim.AddFrames(frames);
		}		
		break;		
	}
}
