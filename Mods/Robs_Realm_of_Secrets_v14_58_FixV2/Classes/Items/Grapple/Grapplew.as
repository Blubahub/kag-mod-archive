const f32 archer_grapple_length = 72.0f;
const f32 archer_grapple_slack = 16.0f;
const f32 archer_grapple_throw_speed = 20.0f;

const f32 archer_grapple_force = 2.0f;
const f32 archer_grapple_accel_limit = 1.5f;
const f32 archer_grapple_stiffness = 0.1f;

const string grapple_sync_cmd = "grapple sync";

void onInit(CBlob@ this)
{
	this.set_Vec2f("grapple_offset",Vec2f(0,0));
	
	this.set_bool("grappling",false);
	this.set_u16("grapple_id",0);
	this.set_f32("grapple_ratio",1);
	this.set_f32("cache_angle",1);
	this.set_Vec2f("grapple_pos",Vec2f(0,0));
	this.set_Vec2f("grapple_vel",Vec2f(0,0));
	
	this.addCommandID(grapple_sync_cmd);
}

void onTick(CBlob@ this)
{
	ManageGrapple(this);
}

void ManageGrapple(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed(key_action2);
	if (right_click)
	{
		if (canSend(this))
		{
			this.set_bool("grappling",true);
			this.set_u16("grapple_id",0xffff);
			this.set_Vec2f("grapple_pos",pos);

			this.set_f32("grapple_ratio",1.0f);//allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			//aim in direction of cursor
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{
				this.set_Vec2f("grapple_vel",direction * archer_grapple_throw_speed);
			}
			else
			{
				this.set_Vec2f("grapple_vel",Vec2f_zero);
			}

			SyncGrapple(this);
		}
	}

	if (this.get_bool("grappling"))
	{
		//update grapple
		
		if (!this.isKeyPressed(key_action2))
		{
			if (canSend(this))
			{
				this.set_bool("grappling",false);
				SyncGrapple(this);
			}
		}
		else
		{
			const f32 archer_grapple_range = archer_grapple_length * this.get_f32("grapple_ratio");
			const f32 archer_grapple_force_limit = this.getMass() * archer_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if (this.get_f32("grapple_ratio") > 0.2f)
				this.set_f32("grapple_ratio",this.get_f32("grapple_ratio")-(1.0f / getTicksASecond()));

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = this.get_Vec2f("grapple_pos") - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - archer_grapple_range;
				if (offdist > 0)
				{
					offset = force * Maths::Min(8.0f, offdist * archer_grapple_stiffness);
					force *= Maths::Min(archer_grapple_force_limit, Maths::Max(0.0f, offdist + archer_grapple_slack) * archer_grapple_force);
				}
				else
				{
					force.Set(0, 0);
				}
			}

			//left map? close grapple
			if (this.get_Vec2f("grapple_pos").x < map.tilesize || this.get_Vec2f("grapple_pos").x > (map.tilemapwidth - 1)*map.tilesize)
			{
				if (canSend(this))
				{
					SyncGrapple(this);
					this.set_bool("grappling",false);
				}
			}
			else if (this.get_u16("grapple_id") == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(this.get_Vec2f("grapple_pos")) ? 0.7f : 0.90f;
				const Vec2f gravity(0, 1);

				archer.grapple_vel = (archer.grapple_vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = archer.grapple_pos + archer.grapple_vel;
				next -= offset;

				Vec2f dir = next - archer.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while (delta > 0 && !found) //fake raycast
				{
					if (delta > step)
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
			else //stuck -> pull towards pos
			{

				//wallrun/jump reset to make getting over things easier
				//at the top of grapple
				if (this.isOnWall()) //on wall
				{
					//close to the grapple point
					//not too far above
					//and moving downwards
					Vec2f dif = pos - archer.grapple_pos;
					if (this.getVelocity().y > 0 &&
					        dif.y > -10.0f &&
					        dif.Length() < 24.0f)
					{
						//need move vars
						RunnerMoveVars@ moveVars;
						if (this.get("moveVars", @moveVars))
						{
							moveVars.walljumped_side = Walljump::NONE;
							moveVars.wallrun_start = pos.y;
							moveVars.wallrun_current = pos.y;
						}
					}
				}

				CBlob@ b = null;
				if (archer.grapple_id != 0)
				{
					@b = getBlobByNetworkID(archer.grapple_id);
					if (b is null)
					{
						archer.grapple_id = 0;
					}
				}

				if (b !is null)
				{
					archer.grapple_pos = b.getPosition()+this.get_Vec2f("grapple_offset");
					if (b.isKeyJustPressed(key_action1) ||
					        b.isKeyJustPressed(key_action2) ||
					        this.isKeyPressed(key_use))
					{
						if (canSend(this))
						{
							SyncGrapple(this);
							archer.grappling = false;
						}
					}
				}
				else if (shouldReleaseGrapple(this, archer, map))
				{
					if (canSend(this))
					{
						SyncGrapple(this);
						archer.grappling = false;
					}
				}
	
				if (b !is null){
					float mod = b.getMass()/this.getMass();
					if(mod > 1)mod = 1;
					this.AddForce(force*mod);
				}else 
					this.AddForce(force);
				
				Vec2f target = (this.getPosition() + offset);
				if (!map.rayCastSolid(this.getPosition(), target))
				{
					this.setPosition(target);
				}

				if (b !is null){
					int mod = 2;
					if(b.getName() == "warboat" || b.getName() == "longboat")mod = 16;
					b.AddForce(-force*((b.getMass()/this.getMass())/mod));
				}

			}
		}

	}
}

bool checkGrappleStep(CBlob@ this, CMap@ map, const f32 dist)
{
	if (map.getSectorAtPosition(archer.grapple_pos, "barrier") !is null)  //red barrier
	{
		if (canSend(this))
		{
			archer.grappling = false;
			SyncGrapple(this);
		}
	}
	else if (grappleHitMap(archer, map, dist))
	{
		archer.grapple_id = 0;

		archer.grapple_ratio = Maths::Max(0.2, Maths::Min(archer.grapple_ratio, dist / archer_grapple_length));

		if (canSend(this)) SyncGrapple(this);

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(archer.grapple_pos);
		if (b !is null)
		{
			if (b is this)
			{
				//can't grapple self if not reeled in
				if (archer.grapple_ratio > 0.5f)
					return false;

				if (canSend(this))
				{
					archer.grappling = false;
					SyncGrapple(this);
				}

				return true;
			}
			else if (b.isCollidable() && !b.isAttached())// && b.getShape().isStatic())
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				archer.grapple_ratio = Maths::Max(0.2, Maths::Min(archer.grapple_ratio, b.getDistanceTo(this) / archer_grapple_length));

				archer.grapple_id = b.getNetworkID();
				this.set_Vec2f("grapple_offset",archer.grapple_pos-b.getPosition());
				
				if (canSend(this))
				{
					SyncGrapple(this);
				}

				return true;
			}
		}
	}

	return false;
}

bool grappleHitMap(CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(archer.grapple_pos + Vec2f(0, -3)) ||			//fake quad
	        map.isTileSolid(archer.grapple_pos + Vec2f(3, 0)) ||
	        map.isTileSolid(archer.grapple_pos + Vec2f(-3, 0)) ||
	        map.isTileSolid(archer.grapple_pos + Vec2f(0, 3)) ||
	        (dist > 10.0f && map.getSectorAtPosition(archer.grapple_pos, "tree") !is null);   //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, CMap@ map)
{
	return !grappleHitMap(archer, map) || this.isKeyPressed(key_use);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID(grapple_sync_cmd))
	{
		HandleGrapple(this, params, !canSend(this));
	}
}

void HandleGrapple(CBlob@ this, CBitStream@ bt, bool apply)
{

	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	grappling = bt.read_bool();

	if (grappling)
	{
		grapple_id = bt.read_u16();
		u8 temp = bt.read_u8();
		grapple_ratio = temp / 250.0f;
		grapple_pos = bt.read_Vec2f();
		grapple_vel = bt.read_Vec2f();
	}

	if (apply)
	{
		archer.grappling = grappling;
		if (archer.grappling)
		{
			archer.grapple_id = grapple_id;
			archer.grapple_ratio = grapple_ratio;
			archer.grapple_pos = grapple_pos;
			archer.grapple_vel = grapple_vel;
		}
	}
}