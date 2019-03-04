
//script for a bison

#include "AnimalConsts.as";
#include "MakeScroll.as";
const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const s16 MAD_TIME = 600;
const string chomp_tag = "chomping";

//sprite

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    this.ReloadSprites(blob.getTeamNum(),0); 
    //this.ReloadSprites(0,0); //always blue
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    if (this.isAnimation("revive") && !this.isAnimationEnded()) return;
	if (this.isAnimation("bite") && !this.isAnimationEnded()) return;
    if (blob.getHealth() > 0.0)
    {
		f32 x = blob.getVelocity().x;
		
		if (this.isAnimation("dead"))
		{
			blob.getShape().SetOffset(Vec2f(0,-8));
			
			this.SetAnimation("revive");
		}
		else
		if( blob.hasTag(chomp_tag) && !this.isAnimation("bite"))
		{
			if (!this.isAnimation("bite")) {
			int r = XORRandom(2);
			if(r==0)
			this.PlaySound( "/DragonFireBreath" );
			else
			this.PlaySound( "/DragonFireBreath2" );
			this.SetAnimation("bite");
			return;
			}
		}
		else
		if (Maths::Abs(x) > 0.1f)
		{
			if (!this.isAnimation("walk")) {
				this.SetAnimation("walk");
			}
		}
		else
		{
			if (XORRandom(10)<=3)
			{
				int r = XORRandom(10);
				if(r==0)
				this.PlaySound( "/GregRoar" );
				
				if (XORRandom(3)==0)
				this.PlaySound( "/DragonFlying" );
			}
			if (!this.isAnimation("idle")) {
			this.SetAnimation("idle");
			}
		}
	}
	else 
	{
		if (!this.isAnimation("dead"))
		{
			blob.getShape().SetOffset(Vec2f(0,-16));
			//this.getShape().SetCenterOfMassOffset(Vec2f(0.0f,0));
			this.SetAnimation("dead");
			this.PlaySound( "/GregCry" );
		}
//		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void onGib(CSprite@ this)
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Head     = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 0, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );																									//collumn, //row
    CParticle@ Body     = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 0, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );																									//collumn, //row
    CParticle@ Leg1     = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 2, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );
   	CParticle@ Leg2   = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 3, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );
   	CParticle@ Arm1     = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 1, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 2, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Tail     = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 1, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );
	CParticle@ Wing1     = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 3, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );
	CParticle@ Wing2     = makeGibParticle( "BossRedDragonGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 4, Vec2f (96,96), 2.0f, 20, "/BodyGibFall", team );
	
	for (uint step = 0; step < 20; ++step)
	{
		makeGibParticle( "GenericGibs", pos, vel + getRandomVelocity( 90, hp , 80 ),       4, XORRandom(8), Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
	}
}

//blob
void onInit(CBrain@ this)
{
	// was enabled
	
	this.getCurrentScript().runFlags |= Script::tick_attached;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	//this.getCurrentScript().runFlags = Script::tick_not_attached;
	this.getCurrentScript().runFlags = 0;
	
	//this.getCurrentScript().runFlags = Script::tick_not_attached;
}
void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"player"};
	this.set("tags to eat", tags);
	

	f32 red_dragon_player_dmg = getRules().get_f32("red_dragon_player_dmg");
	this.set_f32("bite damage", red_dragon_player_dmg);

	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq",8);
	this.set_f32(target_searchrad_property, 10000.0f); //560 default
	this.set_f32(terr_rad_property, 185.0f);
	this.set_u8(target_lose_random,34);
	
	this.getBrain().server_SetActive( true );
	
	//for steaks
	//this.set_u8("number of steaks", 1);
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	//for flesh hit
	this.set_f32("gib health", -3.0f);
	
	this.Tag("flesh");
	this.Tag("zombie");
	this.Tag("BossRedDragon");
	this.Tag("boss");
	//this.Tag("Greg");
	this.set_s16("mad timer", 0);

//	this.getShape().SetOffset(Vec2f(0,8));
	
//	this.getCurrentScript().runFlags = Script::tick_blob_in_proximity;
//	this.getCurrentScript().runProximityTag = "player";
//	this.getCurrentScript().runProximityRadius = 320.0f;
	//was enabled
	//this.getCurrentScript().runFlags = Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_attached;
	this.getCurrentScript().runFlags = 0;
	
	//this.getCurrentScript().runFlags = Script::tick_not_attached;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false; //maybe make a knocked out state? for loading to cata?
}
void onDetachMob( CBlob@ this, f32 damage, CBlob@ carriedBlob)
{
	f32 forcePowX = 0;
	f32 forcePowY = 0;
	if (XORRandom(2)==0)
	forcePowX = -1;
	else
	forcePowX = 1;
	if (XORRandom(2)==0)
	forcePowY = -1;
	else
	forcePowY = 1;
	int red_dragon_throwing_power = getRules().get_s32("red_dragon_throwing_power");
	Vec2f forcePow = Vec2f (forcePowX, forcePowY);
	Vec2f force = forcePow * this.getMass() * damage * red_dragon_throwing_power;
	carriedBlob.AddForce( force);
}
void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	 //Drop Attached
	if (this.hasAttached())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = this.getMap();
		const f32 radius = this.getRadius();
		
		f32 x = pos.x;
		Vec2f top = Vec2f(x, map.tilesize);
		Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
		Vec2f end;
		
		if (map.rayCastSolid(top,bottom,end))
		{
			f32 y = end.y;
			
			if (y-pos.y>200 && XORRandom(20)==0 || XORRandom(200)==0)
			{	
				CBlob@ carried = this.getCarriedBlob();
				this.server_DetachAll();
				if (XORRandom(2)==0)
				{
					f32 power = this.get_f32("bite damage");
					//onDetachMob(this, power, carried);
				}
			}
		}
	}
	
	if (this.getHealth()<0.0 && (this.getTickSinceCreated() - this.get_u16("death ticks")) > 300)
	{
		this.server_SetHealth(0.5);
		this.getShape().setFriction( 0.3f );
		this.getShape().setElasticity( 0.1f );
	}
	if (this.getHealth()<0.0) return;
	float difficulty = getRules().get_f32("difficulty");
	int break_chance_modifier = getRules().get_s32("break_chance_modifier");
	int break_chance = break_chance_modifier - 2*(difficulty);	
	int bite_freq = break_chance_modifier - 2*(difficulty);	
	if (break_chance<5) break_chance=5;
	if (bite_freq<15) bite_freq=15;
	if (getNet().isServer() && this.hasTag(chomp_tag) && getGameTime() % 10 == 0 && (XORRandom(bite_freq)==0))
	{	
		string name = this.getName();
		CBlob@[] blobs;
		this.getMap().getBlobsInRadius( this.getPosition(), this.getRadius()+XORRandom(20), @blobs );
		for (uint step = 0; step < blobs.length; ++step)
		{
			//TODO: sort on proximity? done by engine?
			CBlob@ other = blobs[step];
			if (other is this) continue; //lets not run away from / try to eat ourselves...
			if (other.hasTag("flesh") && other.getTeamNum() != this.getTeamNum() || (other.getTeamNum() != this.getTeamNum() && (other.hasTag("boat") || other.hasTag("vehicle")) ))
			{
				f32 power = this.get_f32("bite damage");
				Vec2f vel(0,0);
				this.server_Hit(other,other.getPosition(),vel,power,Hitters::bite, false);
				if (XORRandom(3)==0)
				this.server_Hit(other,other.getPosition(),vel,(power/10),Hitters::fire, false);

				if (!other.hasTag("boss"))
				{
					if (XORRandom(2)==0)
					this.server_AttachTo(other,"PICKUP");
				}
			}
				
		}	
	}

	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft( x < 0 );
	}
	else
	{
		if (this.isKeyPressed(key_left)) {
			this.SetFacingLeft( true );
		}
		if (this.isKeyPressed(key_right)) {
			this.SetFacingLeft( false );
		}
	}

	// relax the madness

	if (getGameTime() % 65 == 0)
	{
		s16 mad = this.get_s16("mad timer");
		if (mad > 0)
		{
			mad -= 65;
			if (mad < 0 ) {
				this.set_u8(personality_property, DEFAULT_PERSONALITY);
			}
			else
			{
				int r = XORRandom(5);
				if(r==0)
				this.getSprite().PlaySound( "/GregRoar" );
				if (XORRandom(5)==0)
				this.getSprite().PlaySound( "/DragonFlying" );
			}
			this.set_s16("mad timer", mad);
		}

//		if (XORRandom(mad > 0 ? 3 : 12) == 0)
//			this.getSprite().PlaySound("/BisonBoo");
	}

	// footsteps

	//this.isOnGround() && 
	
	if (this.isKeyPressed(key_left) || this.isKeyPressed(key_right) || this.isKeyPressed(key_down) || this.isKeyPressed(key_up))
	{
		if (XORRandom(break_chance)==0 || (this.hasTag(chomp_tag) && XORRandom(10)==0))
		{

				s32 red_dragon_tile_dmg_range = getRules().get_s32("red_dragon_tile_dmg_range");
				int xMod = 0;
				int yMod = 0;
				Vec2f dir1 = Vec2f(0, 0);
				Vec2f dirF = Vec2f( 0, 0 );
				CBlob@ bestTarget = getTargetPos(this);
				if (bestTarget !is null)
				{
					//printf("bestTarget selected");
					if (bestTarget.getPosition().x < this.getPosition().x)
					xMod = ((XORRandom(400)+XORRandom(400))*-1);
					else
					xMod = XORRandom(400)+XORRandom(400); 

					if (bestTarget.getPosition().y < this.getPosition().y)
					yMod = ((XORRandom(400)+XORRandom(400))*-1);
					else
					yMod = XORRandom(400)+XORRandom(400);
					
					dir1 = Vec2f(xMod, yMod);
					dirF = Vec2f( xMod, 350 );
				}
				else
				{
					//printf("bestTarget is NULL");
					if (!this.isFacingLeft())
					{
						xMod = XORRandom(400)+XORRandom(400); //printf("FACING RIGHT = "+xMod);// right
					}
					else
					{
						xMod = ((XORRandom(400)+XORRandom(400))*-1); //printf("FACING LEFT = "+xMod);// Left
					}
					dir1 = Vec2f( xMod, XORRandom(350)-XORRandom(350) );

					if (XORRandom(2) == 0)
					{
						dir1 = Vec2f( xMod, XORRandom(400)+XORRandom(400));
					}
					else
					if (XORRandom(3) == 0)
					{
						dir1 = Vec2f( xMod, ((XORRandom(400)+XORRandom(400))*-1) );
					}
					dirF = Vec2f( xMod, 350 );
				}

				dirF.Normalize();
				dir1.Normalize();
				Vec2f fp1 = this.getPosition() + (dirF)*((this.getRadius() + XORRandom(red_dragon_tile_dmg_range)) + XORRandom(11)+5);
				Vec2f tp1 = this.getPosition() + (dir1)*(this.getRadius() + XORRandom(red_dragon_tile_dmg_range));
				s32 red_dragon_tile_dmg = getRules().get_s32("red_dragon_tile_dmg");
				TileType tile = this.getMap().getTile( tp1 ).type;
				if (this.getMap().isTileSolid(tp1) && !this.getMap().isTileGroundStuff(tile))
				this.Tag(chomp_tag); this.getMap().server_DestroyTile(tp1, ((difficulty/14) + red_dragon_tile_dmg));

				if (this.hasTag(chomp_tag) && XORRandom(2)==0)
				this.getMap().server_setFireWorldspace(fp1, true);
				
				if (this.getMap().isTileSolid(tp1) && this.getMap().isTileGroundStuff(tile))
				this.getMap().server_DestroyTile(tp1, ((difficulty/18) + red_dragon_tile_dmg));

				if (this.getMap().isTileBedrock( tile ))
				this.Tag(chomp_tag); this.getMap().server_DestroyTile(tp1, 100);

		}
		
		if ((this.getNetworkID() + getGameTime()) % 9 == 0)
		{
			f32 volume = Maths::Min( 0.1f + Maths::Abs(this.getVelocity().x)*0.1f, 1.0f );
			TileType tile = this.getMap().getTile( this.getPosition() + Vec2f( 0.0f, this.getRadius() + 4.0f )).type;

			if (this.getMap().isTileGroundStuff( tile )) {
				//this.getSprite().PlaySound("/EarthStep", volume, 0.75f );
			}
			else {
				//this.getSprite().PlaySound("/StoneStep", volume, 0.75f );
			}
		}
	}
	
	if(getNet().isServer() && getGameTime() % 10 == 0)
	{
		if(this.get_u8(state_property) == MODE_TARGET || this.isOnGround() || this.get_s16("mad timer") >= MAD_TIME/8 )
		{
			f32 red_dragon_aggro_range = getRules().get_f32("red_dragon_aggro_range");
			CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
			if(this.isOnGround() || this.get_s16("mad timer") >= MAD_TIME/8  || (b !is null &&  this.getDistanceTo(b) < 206.0f) || (b !is null &&  this.getDistanceTo(b) < XORRandom(red_dragon_aggro_range)) || (getGameTime() % 600 == 0))
			{
				this.Tag(chomp_tag);
			}
			else
			{
				this.Untag(chomp_tag);
			}

		}
		else
		{
			this.Untag(chomp_tag);
		}
		this.Sync(chomp_tag,true);
	}
	/*
	s16 mad = this.get_s16("mad timer");
	
	printf("MAD = "+mad+" MAD_TIME/8 = "+MAD_TIME/8);

	if(this.hasTag(chomp_tag))
	printf("CHOMPING");
	else
	printf("NOT CHOMPING");
	*/
}

void MadAt( CBlob@ this, CBlob@ hitterBlob )
{
	const u16 damageOwnerId = (hitterBlob.getDamageOwnerPlayer() !is null && hitterBlob.getDamageOwnerPlayer().getBlob() !is null) ? 
		hitterBlob.getDamageOwnerPlayer().getBlob().getNetworkID() : 0;

	const u16 friendId = this.get_netid(friend_property);
	if (friendId == hitterBlob.getNetworkID() || friendId == damageOwnerId) // unfriend
		this.set_netid(friend_property, 0);
	else // now I'm mad!
	{
		if (this.get_s16("mad timer") <= MAD_TIME/8) //Initial Mad trigger
		{
			int r = XORRandom(5);
				if(r==0)
				this.getSprite().PlaySound( "/GregRoar" ); 
				
				if (XORRandom(3)==0)
				this.getSprite().PlaySound( "/DragonFlying" );
		}
		this.set_s16("mad timer", MAD_TIME);
		this.set_u8(personality_property, DEFAULT_PERSONALITY | AGGRO_BIT);
		this.set_u8(state_property, MODE_TARGET);
		if (hitterBlob.hasTag("player"))
			this.set_netid(target_property, hitterBlob.getNetworkID() );
		else
			if (damageOwnerId > 0) {
				this.set_netid(target_property, damageOwnerId );
			}
	}
}

f32 getGibHealth( CBlob@ this )
{
    if (this.exists("gib health")) {
        return this.get_f32("gib health");
    }

    return 0.0f;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{		
		MadAt( this, hitterBlob );

	if (this.getHealth()>0 && this.getHealth() <= damage)
	{
		if (getNet().isServer())
		this.set_u16("death ticks",this.getTickSinceCreated());
		this.Sync("death ticks",true);
	}
	if (customData == Hitters::arrow) damage*=2.0;
    this.Damage( damage, hitterBlob );
    // Gib if health below gibHealth
    f32 gibHealth = getGibHealth( this );
	
	//printf("ON HIT " + damage + " he " + this.getHealth() + " g " + gibHealth );
    // blob server_Die()() and then gib

	
	//printf("gibHealth " + gibHealth + " health " + this.getHealth() );
    if (this.getHealth() <= gibHealth)
    {
    	int red_dragon_reward_coins = getRules().get_s32("red_dragon_reward_coins");
				
        this.getSprite().Gib();
		if (hitterBlob.hasTag("player"))
		{
			CPlayer@ player = hitterBlob.getPlayer();
			if (player !is null)
			{
				player.setKills(player.getKills() + 5);
				// temporary until we have a proper score system
				player.setScore(  100 * (f32(player.getKills()) / f32(player.getDeaths()+1)) );
				player.server_setCoins( player.getCoins() + (red_dragon_reward_coins/10) );
			}
		} else
		if(hitterBlob.getDamageOwnerPlayer() !is null)
		{
			CPlayer@ player = hitterBlob.getDamageOwnerPlayer();
			player.server_setCoins( player.getCoins() + (red_dragon_reward_coins/10) );
		}
		if (getNet().isServer())
		{
			
			warn("SS: "+getRules().get_bool("scrolls_spawn"));
			int r = XORRandom(30);
			if (r<3 && getRules().get_bool("scrolls_spawn"))
			{
				if (r == 0)
					server_MakePredefinedScroll( hitterBlob.getPosition() + Vec2f(0,-3.0f), "carnage" );
				if (r == 1)
					server_MakePredefinedScroll( hitterBlob.getPosition() + Vec2f(0,-3.0f), "midas" );
				if (r == 2)
					server_MakePredefinedScroll( hitterBlob.getPosition() + Vec2f(0,-3.0f), "drought" );				
				
			}
			else
			{
				server_DropCoins(hitterBlob.getPosition() + Vec2f(0,-3.0f), red_dragon_reward_coins);
			}
		}
        this.server_Die();
    }
		
    return 0.0f; //done, we've used all the damage	
	
}														

#include "Hitters.as";

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("dead"))
		return false;
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (this.getHealth() <= 0.0) return; // dead
	if (blob is null)
		return;

	const u16 friendId = this.get_netid(friend_property);
	CBlob@ friend = getBlobByNetworkID(friendId);
	if ((friend is null || blob.getTeamNum() != friend.getTeamNum()) && blob.getName() != this.getName() && blob.hasTag("flesh") && !blob.hasTag("dead") && blob.getName() != "Wraith")
	{
		const f32 vellen = this.getShape().vellen;
		f32 power = this.get_f32("bite damage");
		if (vellen > 0.1f)
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getVelocity();
			Vec2f other_pos = blob.getPosition();
			Vec2f direction = other_pos - pos;		
			direction.Normalize();
			vel.Normalize();
			//if (vel * direction > 0.33f)
			if (getNet().isServer() && XORRandom(2)==0 && !blob.hasTag("boss"))
			{
				
				f32 power = this.get_f32("bite damage");
				this.server_Hit( blob, point1, vel, power, Hitters::bite, false);
				if (XORRandom(3)==0)
				this.server_Hit( blob, point1, vel, (power/10), Hitters::crush, false);


				if (!blob.hasTag("boss") && blob.hasTag("flesh") && blob.getName() != "Caravel")
				{
					if (XORRandom(5)==0)
						this.server_AttachTo(blob,"PICKUP");
				}
				//this.getShape().getConsts().collideWhenAttached = true;
				//blob.getShape().getConsts().collideWhenAttached = true;
			}
		}	

		MadAt( this, blob );
	}
}

CBlob@ getTargetPos (CBlob@ this)
{
	CBlob@ blob = this;

	Vec2f pos = blob.getPosition();

	CBlob@[] potentials;
	CBlob@[] blobsInRadius;
	if (blob.getMap().getBlobsInRadius( pos, 5000.0f, @blobsInRadius ))
	{

		// find players or campfires

		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is blob && b.getTeamNum() != blob.getTeamNum() && !b.hasTag("dead") && !b.hasTag("zombie") && b.hasTag("player"))
			{								  
				// omit full beds or when bot
				const string name = b.getName();
				potentials.push_back(b);
			}
		}	 

		// pick closest/best
		if (potentials.length > 0)
		{				
			while (potentials.size() > 0)
			{
				f32 closestDist = 999999.9f;
				uint closestIndex = 999;

				for (uint i = 0; i < potentials.length; i++)
				{
					CBlob @b = potentials[i];
					Vec2f bpos = b.getPosition();
					f32 distToPlayer = (bpos - pos).getLength();
					f32 dist = distToPlayer;
					if (distToPlayer > 0.0f && dist < closestDist)
					{
						closestDist = dist;
						closestIndex = i;
					}
				} 
				if (closestIndex >= 999) {
					break;
				} 
				return potentials[closestIndex];
			}
		}
	}
	return null;
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (hitBlob !is null && customData == Hitters::flying)
	{
		Vec2f force = velocity * this.getMass() * 0.35f ;
		force.y -= 1.0f;
		hitBlob.AddForce( force);
	}
}


