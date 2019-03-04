// Archer logic

#include "ArcherCommon.as"
#include "ThrowCommon.as"
#include "Knocked_SSBG.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";

const int FLETCH_COOLDOWN = 45;
const int PICKUP_COOLDOWN = 15;
const int fletch_num_arrows = 1;
const int STAB_DELAY = 10;
const int STAB_TIME = 22;

void onInit( CBlob@ this )
{
	ArcherInfo archer;	  
	this.set("archerInfo", @archer);

    this.set_s8( "charge_time", 0 );
    this.set_u8( "charge_state", ArcherParams::not_aiming );
    this.set_bool( "has_arrow", false );
    this.set_f32("gib health", -3.0f);
    this.Tag("player");
    this.Tag("flesh");
	
	this.push("names to activate", "keg");
	this.push("names to activate", "nuke");

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
    //no spinning
    this.getShape().SetRotationsAllowed(false);
    this.getSprite().SetEmitSound( "Entities/Characters/Archer/BowPull.ogg" );
    this.addCommandID("shoot arrow");
    this.addCommandID("pickup arrow");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

    this.addCommandID(grapple_sync_cmd);

	SetHelp( this, "help self hide", "archer", "Hide    $KEY_S$", "", 1 );
	SetHelp( this, "help self action2", "archer", "$Grapple$ Grappling hook    $RMB$", "", 3 );

    setKnockable( this );
    for (uint i = 0; i < arrowTypeNames.length; i++) {
        this.addCommandID( "pick " + arrowTypeNames[i]);
    }

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick( CBlob@ this )
{
    Knocked(this);

	ArcherInfo@ archer;
	if (!this.get( "archerInfo", @archer )) {
		return;
	}

	if(this.get_u8("knocked") > 0)
	{
		archer.grappling = false;
		archer.charge_state = 0;
		archer.charge_time = 0;
		return;
	}

	CSprite@ sprite = this.getSprite();
    u8 charge_state = archer.charge_state;
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed( key_action2 );
	if (right_click)
	{
		// cancel charging
		if (charge_state != ArcherParams::not_aiming)
		{
			charge_state = ArcherParams::not_aiming;
			archer.charge_time = 0;
			sprite.SetEmitSoundPaused( true );
			sprite.PlaySound("PopIn.ogg");
		}
		else if (canSend(this) && archer.grappling == false) //otherwise grapple
		{
			archer.grappling = true;
			archer.grapple_id = 0xffff;
			archer.grapple_pos = pos;
			sprite.PlaySound("HookShot.ogg", 1.0f, XORRandom(2) == 1 ? 1.0f : 1.5f);
			ParticleAnimated( "Entities/Effects/Sprites/WhitePuff.png",
								this.getPosition(),
								this.getVelocity()*0.5f + (this.getAimPos() - this.getPosition())/(this.getAimPos() - this.getPosition()).getLength(),
								1.0f, 0.5f, 
								2, 
								0.0f, true );			

			archer.grapple_ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			// more intuitive aiming (compensates for gravity and cursor position)
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{	
				archer.grapple_vel = direction * archer_grapple_throw_speed;
			}
			else
				{
				archer.grapple_vel = Vec2f_zero;
			}

			SyncGrapple( this );
		}
		else
		{
			sprite.PlaySound("HookShot.ogg", 1.0f, XORRandom(2) == 1 ? 1.0f : 1.5f);
			ParticleAnimated( "Entities/Effects/Sprites/WhitePuff.png",
								this.getPosition(),
								this.getVelocity()*0.5f + (this.getAimPos() - this.getPosition())/(this.getAimPos() - this.getPosition()).getLength(),
								1.0f, 0.5f, 
								2, 
								0.0f, true );	
		}

		archer.charge_state = charge_state;
	}

	if (archer.grappling)
	{
		//update grapple
		//TODO move to its own script?
		
		if (this.isKeyJustReleased( key_action2 ))
			Sound::Play("HookReel.ogg", this.getPosition());

		if(!this.isKeyPressed(key_action2))
		{

				const f32 archer_grapple_range = archer_grapple_length * archer.grapple_ratio;
				const f32 archer_grapple_force_limit = this.getMass() * archer_grapple_accel_limit;

				CMap@ map = this.getMap();

				//reel in
				//TODO: sound
				if( archer.grapple_ratio > 0.2f)
					archer.grapple_ratio -= 1.0f / getTicksASecond();

				//get the force and offset vectors
				Vec2f force;
				Vec2f offset;
				f32 dist;
				{
					force = archer.grapple_pos - this.getPosition();
					dist = force.Normalize();
					f32 offdist = dist - archer_grapple_range;
					if(offdist > 0)
					{
						offset = force * Maths::Min(8.0f,offdist * archer_grapple_stiffness);
						force *= 1000.0f / (archer.grapple_pos - this.getPosition()).getLength();
					}
					else
					{
						force.Set(0,0);
					}
				}
				
				const f32 drag = map.isInWater(archer.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0,0.5);

				archer.grapple_vel = -force;
				
				this.DisableKeys(key_action2);
				
				Vec2f retract = (archer.grapple_pos - this.getPosition())/(archer.grapple_pos - this.getPosition()).getLength();
				Vec2f next = archer.grapple_pos + archer.grapple_vel - retract;
				next -= offset;

				Vec2f dir = next - archer.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while(delta > 0 && !found) //fake raycast
				{
					if(delta > step)
					{
						archer.grapple_pos += dir * step;
					}
					else
					{
						archer.grapple_pos = next;
					}
					delta -= step;
					CBlob@ b = map.getBlobAtPosition(archer.grapple_pos);
					if (b !is null)
					{
						if(b is this)
						{
							//can't grapple self if not reeled in

							if(canSend(this))
							{								
								archer.grappling = false;
								SyncGrapple( this );
							}
							Sound::Play("HookReset.ogg", this.getPosition());
						}
					}
				}
			
		}
		else
		{
			const f32 archer_grapple_range = archer_grapple_length * archer.grapple_ratio;
			const f32 archer_grapple_force_limit = this.getMass() * archer_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if( archer.grapple_ratio > 0.2f)
				archer.grapple_ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = archer.grapple_pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - archer_grapple_range;
				if(offdist > 0)
				{
					offset = force * Maths::Min(8.0f,offdist * archer_grapple_stiffness);
					force *= Maths::Min(archer_grapple_force_limit, Maths::Max(0.0f, offdist + archer_grapple_slack) * archer_grapple_force);
				}
				else
				{
					force.Set(0,0);
				}
			}

			//left map? close grapple
			if(archer.grapple_pos.x < map.tilesize || archer.grapple_pos.x > (map.tilemapwidth-1)*map.tilesize)
			{
				if(canSend(this))
				{
					SyncGrapple( this );
					archer.grappling = false;
				}
			}
			else if(archer.grapple_id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(archer.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0,0.5);

				archer.grapple_vel = (archer.grapple_vel) + gravity ;

				Vec2f next = archer.grapple_pos + archer.grapple_vel;
				next -= offset;

				Vec2f dir = next - archer.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while(delta > 0 && !found) //fake raycast
				{
					if(delta > step)
					{
						archer.grapple_pos += dir * step;
					}
					else
					{
						archer.grapple_pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, archer, map, dist);
				}

			}
			else //stuck in map -> pull towards pos
			{
				CBlob@ b = null;
				if(archer.grapple_id != 0)
				{
					@b = getBlobByNetworkID( archer.grapple_id );
					if(b is null)
					{
						archer.grapple_id = 0;
					}
				}

				if(b !is null)
				{
					archer.grapple_pos = b.getPosition();
					if( b.isKeyJustPressed(key_action1) ||
						b.isKeyJustPressed(key_action2) ||
						this.isKeyPressed(key_use) )
					{
						if(canSend(this))
						{
							SyncGrapple( this );
							archer.grappling = true;  //I (Chrispin) set it to true to get rid of desync issues
						}
					}
				}
				else if( shouldReleaseGrapple(this, archer, map) )
				{
					if(canSend(this))
					{
						SyncGrapple( this );
						archer.grappling = false;
					}
				} 

				this.AddForce(force*0.5);
				Vec2f target = (this.getPosition() + offset);
				if( !map.rayCastSolid(this.getPosition(),target) )
				{
					this.setPosition(target);
				}

				if(b !is null)
				{
					f32 currentHealth = b.getHealth();
					f32 initialHealth = b.getInitialHealth();
					f32 fractionHealth = (initialHealth - currentHealth)/initialHealth;
					b.AddForce(-force * (0.5 + fractionHealth));
				}

			}
		}

	}

	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;
	
	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get( "moveVars", @moveVars )) {
		return;
	}

	bool ismyplayer = this.isMyPlayer();
	bool hasarrow = archer.has_arrow;
	s8 charge_time = archer.charge_time;
	const bool pressed_action2 = this.isKeyPressed( key_action2 );

	if (charge_state != ArcherParams::stabbing )
	{
		if ((getGameTime()+this.getNetworkID())%10 == 0)
		{
			hasarrow = hasArrows( this );

			if (!hasarrow)
			{
				// set back to default
				for (uint i = 0; i < ArrowType::count; i++)
				{
					hasarrow = hasArrows( this, i);
					if (hasarrow)
					{
						archer.arrow_type = i;
						break;
					}
				}
			}
		}

		this.set_bool( "has_arrow", hasarrow );
		this.Sync("has_arrow", false);

		archer.stab_delay = 0;

		if (charge_state == ArcherParams::legolas_charging) // fast arrows
		{
			if (!hasarrow)
			{
				charge_state = ArcherParams::not_aiming;
				charge_time = 0;
			}
			else
			{
				charge_time++;

				if (charge_time >= ArcherParams::shoot_period-1) {	
					charge_state = ArcherParams::legolas_ready;
				}
			}
		}
		else
		if (charge_state == ArcherParams::legolas_ready) // fast arrows
		{
			archer.legolas_time--;
			if (!hasarrow || archer.legolas_time == 0)
			{
				bool pressed = this.isKeyPressed(key_action1);
				charge_state = pressed ? ArcherParams::readying : ArcherParams::not_aiming;
				charge_time = 0;
				if (archer.legolas_arrows == ArcherParams::legolas_arrows_count)
				{
					Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					SetKnocked(this, 15);
				}
				else if(pressed)
				{
					sprite.RewindEmitSound();
					sprite.SetEmitSoundPaused( false );
				}
			}
			else if (this.isKeyJustPressed(key_action1) ||
						(archer.legolas_arrows == ArcherParams::legolas_arrows_count &&
							!this.isKeyPressed(key_action1) &&
							this.wasKeyPressed(key_action1)) )
			{
				ClientFire( this, charge_time, hasarrow, archer.arrow_type, true );
				charge_state = ArcherParams::legolas_charging;
				charge_time = ArcherParams::shoot_period - ArcherParams::legolas_charge_time;
				Sound::Play("FastBowPull.ogg", pos);
				archer.legolas_arrows--;
				if (archer.legolas_arrows == 0)
				{
					charge_state = ArcherParams::readying;
					charge_time = 5;
					
					sprite.RewindEmitSound();
					sprite.SetEmitSoundPaused( false );
				}
			}	 

		}
		else
		if (this.isKeyPressed(key_action1))
		{
			moveVars.walkFactor *= 0.85f;
			moveVars.canVault = false;

			const bool just_action1 = this.isKeyJustPressed(key_action1);

		//	printf("charge_state " + charge_state );

			if ((just_action1 || this.wasKeyPressed(key_action2) && !pressed_action2) &&
				(charge_state == ArcherParams::not_aiming || charge_state == ArcherParams::fired))
			{
				charge_state = ArcherParams::readying;
				hasarrow = hasArrows( this );
				
				charge_time = 0;

				if (!hasarrow)
				{
					charge_state = ArcherParams::no_arrows;

					if (ismyplayer && !this.wasKeyPressed(key_action1)) { // playing annoying no ammo sound
						Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
					}

					// set back to default
					archer.arrow_type = ArrowType::normal;
				}
				else
				{
					if (ismyplayer)
					{
						if (just_action1)
						{
							const u8 type = archer.arrow_type;
							if (type == ArrowType::fire) {
								sprite.PlaySound( "SparkleShort.ogg" );
							} else if (type == ArrowType::water) {
								sprite.PlaySound( "/WaterBubble" );
							}
						}
					}

					sprite.RewindEmitSound();
					sprite.SetEmitSoundPaused( false );

					if (!ismyplayer) { // lower the volume of other players charging  - ooo good idea
						sprite.SetEmitSoundVolume( 0.5f );
					}
				}
			}
			else if (charge_state == ArcherParams::readying)
			{
				charge_time++;

				if(charge_time > ArcherParams::ready_time)
				{
					charge_time = 1;
					charge_state = ArcherParams::charging;
				}
			}
			else if (charge_state == ArcherParams::charging)
			{
				charge_time++;

				if(charge_time >= ArcherParams::legolas_period)
				{ 
					// Legolas state

					Sound::Play("AnimeSword.ogg", pos, ismyplayer ? 1.3f : 0.7f );
					Sound::Play("FastBowPull.ogg", pos);
					charge_state = ArcherParams::legolas_charging;
					charge_time = ArcherParams::shoot_period - ArcherParams::legolas_charge_time;

					archer.legolas_arrows = ArcherParams::legolas_arrows_count;
					archer.legolas_time = ArcherParams::legolas_time;
				}

				if(charge_time >= ArcherParams::shoot_period)
					sprite.SetEmitSoundPaused( true );
			}
			else if (charge_state == ArcherParams::no_arrows)
			{
				if(charge_time < ArcherParams::ready_time) {
					charge_time++;
				}
			}
		}
		else
		{
			if (charge_state > ArcherParams::readying)
			{
				if (charge_state < ArcherParams::fired)
				{
					ClientFire( this, charge_time, hasarrow, archer.arrow_type, false );

					charge_time = ArcherParams::fired_time;
					charge_state = ArcherParams::fired;
				}
				else //fired..
				{
					charge_time--;

					if (charge_time <= 0) {
						charge_state = ArcherParams::not_aiming;
						charge_time = 0;
					}
				}
			}
			else {
				charge_state = ArcherParams::not_aiming;    //set to not aiming either way
				charge_time = 0;
			}

			sprite.SetEmitSoundPaused( true );
		}
	}

	// safe disable bomb light

	if (this.wasKeyPressed(key_action1) && !this.isKeyPressed(key_action1) )
	{
		const u8 type = archer.arrow_type;
		if (type == ArrowType::bomb) {
			BombFuseOff( this );
		}
	}

	// my player!

    if ( ismyplayer )
    {
		getCamera().mousecamstyle = 2;

		// set cursor

		if (!getHUD().hasButtons()) 
		{
			int frame = 0;
		//	print("archer.charge_time " + archer.charge_time + " / " + ArcherParams::shoot_period );
			if (archer.charge_state == ArcherParams::readying) {
				frame = 1 + float(archer.charge_time)/float(ArcherParams::shoot_period + ArcherParams::ready_time) * 7;
			}
			else if (archer.charge_state == ArcherParams::charging) 
				{
					if (archer.charge_time <= ArcherParams::shoot_period) { 
						frame = float(ArcherParams::ready_time + archer.charge_time)/float(ArcherParams::shoot_period) * 7;
					}
					else
						frame = 9;
				}
				else if (archer.charge_state == ArcherParams::legolas_ready){
						frame = 10;
				}
				else if (archer.charge_state == ArcherParams::legolas_charging){
					frame = 9;
				}
			getHUD().SetCursorFrame( frame );
		}

		// activate/throw

        if (this.isKeyJustPressed(key_action3))
        {
			client_SendThrowOrActivateCommand( this );
        }

		// pick up arrow

		if (archer.fletch_cooldown > 0) {
			archer.fletch_cooldown--;
		}

		// pickup from ground

        if (archer.fletch_cooldown == 0 && this.isKeyPressed(key_action2))
        {
            if (getPickupArrow( this ) !is null /*|| canPickSpriteArrow( this, false ) doesnt work*/) // pickup arrow from ground
            {
                this.SendCommand( this.getCommandID("pickup arrow") );
				archer.fletch_cooldown = PICKUP_COOLDOWN;
            }
        }
    }

	archer.charge_time = charge_time;
	archer.charge_state = charge_state;
	archer.has_arrow = hasarrow;
}

bool checkGrappleStep(CBlob@ this, ArcherInfo@ archer, CMap@ map, const f32 dist)
{
	if(map.getSectorAtPosition( archer.grapple_pos, "barrier" ) !is null) //red barrier
	{
		if(canSend(this))
		{
			archer.grappling = false;
			SyncGrapple( this );
		}
	}
	else if( grappleHitMap(archer, map, dist) )
	{
		Sound::Play("ArrowHitGround.ogg", archer.grapple_pos);
	
		archer.grapple_id = 0;

		archer.grapple_ratio = Maths::Max(0.2, Maths::Min( archer.grapple_ratio, dist / archer_grapple_length ) );

		if(canSend(this)) SyncGrapple( this );

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(archer.grapple_pos);
		if (b !is null)
		{
			if(b is this)
			{
				//can't grapple self if not reeled in
				if(archer.grapple_ratio > 0.5f)
					return false;

				if(canSend(this))
				{
					archer.grappling = false;
					SyncGrapple( this );
				}
				
				Sound::Play("HookReset.ogg", this.getPosition());

				return true;
			}
			else if(b.isCollidable())
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)
				
				Vec2f velocity = archer.grapple_vel;
				this.server_Hit( b, b.getPosition(), Vec2f_zero, 1.0f, archer.arrow_type, true);				

				archer.grapple_id = b.getNetworkID();
				if(canSend(this))
				{
					SyncGrapple( this );
				}

				return true;
			}
		}
	}

	return false;
}

bool grappleHitMap(ArcherInfo@ archer, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(archer.grapple_pos + Vec2f(0,-3)) ||			//fake quad
			map.isTileSolid(archer.grapple_pos + Vec2f(3,0)) ||
			map.isTileSolid(archer.grapple_pos + Vec2f(-3,0))||
			map.isTileSolid(archer.grapple_pos + Vec2f(0,3)) ||
			(dist > 10.0f && map.getSectorAtPosition( archer.grapple_pos, "tree" ) !is null); //tree stick
}

bool grappleHitBlob(CBlob@ this, ArcherInfo@ archer, CMap@ map, const f32 dist = 16.0f)
{
	CBlob@ b = null;
	if(archer.grapple_id != 0)
	{
		@b = getBlobByNetworkID( archer.grapple_id );
		if(b is null)
		{
			archer.grapple_id = 0;
		}
	}

	if(b !is null)
	{
		return true;
		this.Damage(0.5f, b);
	}
	
	return false;
}

bool shouldReleaseGrapple(CBlob@ this, ArcherInfo@ archer, CMap@ map)
{
	return this.isKeyPressed(key_use);
}

bool canSend( CBlob@ this )
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void ClientFire(CBlob@ this, const s8 charge_time, const bool hasarrow, const u8 arrow_type, const bool legolas )
{
	//time to fire!
	if (hasarrow && canSend(this) ) // client-logic
	{
		f32 arrowspeed;

		if (charge_time < ArcherParams::ready_time/2+ArcherParams::shoot_period_1) {
			arrowspeed = ArcherParams::shoot_max_vel * (1.0f/3.0f);
		}
		else if (charge_time < ArcherParams::ready_time/2+ArcherParams::shoot_period_2) {
			arrowspeed = ArcherParams::shoot_max_vel * (4.0f/5.0f);
		}
		else {
			arrowspeed = ArcherParams::shoot_max_vel;
		}

		ShootArrow( this, this.getPosition() + Vec2f(0.0f,-2.0f), this.getAimPos() + Vec2f(0.0f,-2.0f), arrowspeed, arrow_type, legolas );
	}
}

void ShootArrow( CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const u8 arrow_type, const bool legolas = true )
{
    if (canSend(this))
	{ // player or bot
		f32 randomInn = 0.0f;
		if(legolas)
		{
			randomInn = -4.0f + (( f32(XORRandom(2048)) / 2048.0f) * 8.0f);
		}

		Vec2f arrowVel = (aimpos- arrowPos).RotateBy(randomInn,Vec2f(0,0));
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		//print("arrowspeed " + arrowspeed);
		CBitStream params;
		params.write_Vec2f( arrowPos );
		params.write_Vec2f( arrowVel );
		params.write_u8( arrow_type );

		this.SendCommand( this.getCommandID("shoot arrow"), params );
	}
}

CBlob@ getPickupArrow( CBlob@ this )
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius( this.getPosition(), this.getRadius()*1.5f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "arrow")
			{
				return b;
			}
		}
	}
    return null;
}

bool canPickSpriteArrow( CBlob@ this, bool takeout )
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius( this.getPosition(), this.getRadius()*1.5f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			{
				CSprite@ sprite = b.getSprite();
				if (sprite.getSpriteLayer("arrow") !is null)
				{
					if (takeout)
						sprite.RemoveSpriteLayer("arrow");
					return true;
				}
			}
		}
	}
	return false;
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shoot arrow"))
    {
        Vec2f arrowPos = params.read_Vec2f();
        Vec2f arrowVel = params.read_Vec2f();
        u8 arrowType = params.read_u8();
		ArcherInfo@ archer;
		if (!this.get( "archerInfo", @archer )) {
			return;
		}
		archer.arrow_type = arrowType;

		// return to normal arrow - server didnt have this synced
		if (!hasArrows( this, arrowType )) {
			return;
		}

        if (getNet().isServer())
        {
            CBlob@ arrow = server_CreateBlobNoInit( "arrow" );
            if (arrow !is null)
            {
				// fire arrow?
				arrow.set_u8("arrow type", arrowType );
				arrow.Init();

				arrow.IgnoreCollisionWhileOverlapped( this );
                arrow.SetDamageOwnerPlayer( this.getPlayer() );
				arrow.server_setTeamNum( this.getTeamNum() );
				arrow.setPosition( arrowPos );
                arrow.setVelocity( arrowVel );
            }
        }

        this.getSprite().PlaySound( "Entities/Characters/Archer/BowFire.ogg" );
        this.TakeBlob( arrowTypeNames[ arrowType ], 1 );

		archer.fletch_cooldown = FLETCH_COOLDOWN; // just don't allow shoot + make arrow
    }
    else if (cmd == this.getCommandID("pickup arrow"))
    {
        CBlob@ arrow = getPickupArrow( this );
		bool spriteArrow = canPickSpriteArrow( this, false );
        if (arrow !is null || spriteArrow)
        {
			if(arrow !is null)
			{
				ArcherInfo@ archer;
				if (!this.get( "archerInfo", @archer )) {
					return;
				}
				const u8 arrowType = archer.arrow_type;
				if(arrowType == ArrowType::bomb)
				{
					arrow.set_u16("follow", 0); //this is already synced, its in command.
					arrow.setPosition(this.getPosition());
					return;
				}
			}

			CBlob@ mat_arrows = server_CreateBlob( "mat_arrows", this.getTeamNum(), this.getPosition() );
			if (mat_arrows !is null)
			{
				mat_arrows.server_SetQuantity(fletch_num_arrows);
				mat_arrows.Tag("do not set materials");
				this.server_PutInInventory( mat_arrows );

				if (arrow !is null) {
					arrow.server_Die();
				}
				else{
					canPickSpriteArrow( this, true );
				}
			}
			this.getSprite().PlaySound( "Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg" );
        }
    }
    else if( cmd == this.getCommandID(grapple_sync_cmd) )
    {
		HandleGrapple( this, params, !canSend(this) );
	}
    else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		ArcherInfo@ archer;
		if (!this.get( "archerInfo", @archer )) {
			return;
		}
		u8 type = archer.arrow_type;

		int count = 0;
		while(count < arrowTypeNames.length)
		{
			type++;
			count++;
			if (type >= arrowTypeNames.length)
				type = 0;
			if (this.getBlobCount( arrowTypeNames[type] ) > 0)
			{
				archer.arrow_type = type;
				if (this.isMyPlayer())
				{
					Sound::Play("/CycleInventory.ogg");
				}
				break;
			}
		}
	}
	else
    {
		ArcherInfo@ archer;
		if (!this.get( "archerInfo", @archer )) {
			return;
		}
        for (uint i = 0; i < arrowTypeNames.length; i++)
        {
            if (cmd == this.getCommandID( "pick " + arrowTypeNames[i]))
            {
                archer.arrow_type = i;
                break;
            }
        }
    }
}

// arrow pick menu

void onCreateInventoryMenu( CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu )
{
    if (arrowTypeNames.length == 0) {
        return;
    }

    this.ClearGridMenusExceptInventory();
    Vec2f pos( gridmenu.getUpperLeftPosition().x + 0.5f*(gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
               gridmenu.getUpperLeftPosition().y - 32 * 1 - 2*24 );
    CGridMenu@ menu = CreateGridMenu( pos, this, Vec2f( arrowTypeNames.length, 2 ), "Current arrow" );

	ArcherInfo@ archer;
	if (!this.get( "archerInfo", @archer )) {
		return;
	}
	const u8 arrowSel = archer.arrow_type;

    if (menu !is null)
    {
		menu.deleteAfterClick = false;

        for (uint i = 0; i < arrowTypeNames.length; i++)
        {
            string matname = arrowTypeNames[i];
            CGridButton @button = menu.AddButton( arrowIcons[i], arrowNames[i], this.getCommandID( "pick " + matname) );

            if (button !is null)
            {
				bool enabled = this.getBlobCount( arrowTypeNames[i] ) > 0;
                button.SetEnabled( enabled );
				button.selectOneOnClick = true;

				//if (enabled && i == ArrowType::fire && !hasReqs(this, i))
				//{
				//	button.hoverText = "Requires a fire source $lantern$";
				//	//button.SetEnabled( false );
				//}

                if (arrowSel == i) {
                    button.SetSelected(1);
                }
			}
        }
    }
}

// auto-switch to appropriate arrow when picked up
void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	string itemname = blob.getName();
	if (this.isMyPlayer())
	{
		for (uint j = 0; j < arrowTypeNames.length; j++)
		{
			if (itemname == arrowTypeNames[j])
			{
				SetHelp( this, "help self action", "archer", "$arrow$Fire arrow   $KEY_HOLD$$LMB$", "", 3 );
				if (j > 0 && this.getInventory().getItemsCount() > 1) {
					SetHelp( this, "help inventory", "archer", "$Help_Arrow1$$Swap$$Help_Arrow2$         $KEY_TAP$$KEY_F$", "", 2 );
				}
				break;
			}
		}
	}

	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0)
	{
		ArcherInfo@ archer;
		if (!this.get( "archerInfo", @archer )) {
			return;
		}

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (itemname == arrowTypeNames[i]) {
				archer.arrow_type = i;
			}
		}
	}
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (customData == Hitters::stab)
	{
		if (damage > 0.0f)
		{

			// fletch arrow
			if ( hitBlob.hasTag("tree") )	// make arrow from tree
			{
				if (getNet().isServer())
				{
					CBlob@ mat_arrows = server_CreateBlob( "mat_arrows", this.getTeamNum(), this.getPosition() );
					if (mat_arrows !is null)
					{
						mat_arrows.server_SetQuantity(fletch_num_arrows);
						mat_arrows.Tag("do not set materials");
						this.server_PutInInventory( mat_arrows );
					}
				}
				this.getSprite().PlaySound( "Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg" );
			}
			else
				this.getSprite().PlaySound("KnifeStab.ogg");
		}

		if (blockAttack(hitBlob, velocity, 0.0f))
		{
			this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			SetKnocked( this, 30 );
		}
	}
}

