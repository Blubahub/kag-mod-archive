const f32 grapple_grapple_length = 100.0f;
const f32 grapple_grapple_slack = 24.0f;
const f32 grapple_grapple_throw_speed = 20.0f;

const f32 grapple_grapple_force = 2.0f;
const f32 grapple_grapple_accel_limit = 1.5f;
const f32 grapple_grapple_stiffness = 0.1f;

shared class GrappleInfo
{
	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	f32 cache_angle;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	GrappleInfo()
	{
		grappling = false;
	}
};


const string grapple_sync_cmd = "grapple sync";

void SyncGrapple(CBlob@ this)
{
	GrappleInfo@ grapple;
	if (!this.get("GrappleInfo", @grapple)) { return; }

	CBitStream bt;
	bt.write_bool(grapple.grappling);

	if (grapple.grappling)
	{
		bt.write_u16(grapple.grapple_id);
		bt.write_u8(u8(grapple.grapple_ratio * 250));
		bt.write_Vec2f(grapple.grapple_pos);
		bt.write_Vec2f(grapple.grapple_vel);
	}

	this.SendCommand(this.getCommandID(grapple_sync_cmd), bt);
}

//TODO: saferead
void HandleGrapple(CBlob@ this, CBitStream@ bt, bool apply)
{
	GrappleInfo@ grapple;
	if (!this.get("GrappleInfo", @grapple)) { return; }

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
		grapple.grappling = grappling;
		if (grapple.grappling)
		{
			grapple.grapple_id = grapple_id;
			grapple.grapple_ratio = grapple_ratio;
			grapple.grapple_pos = grapple_pos;
			grapple.grapple_vel = grapple_vel;
		}
	}
}

void doRopeUpdate(CSprite@ this, CBlob@ blob, GrappleInfo@ grapple)
{
	CSpriteLayer@ rope = this.getSpriteLayer("rope");
	CSpriteLayer@ hook = this.getSpriteLayer("hook");

	bool visible = grapple !is null && grapple.grappling;

	rope.SetVisible(visible);
	hook.SetVisible(visible);
	if (!visible)
	{
		return;
	}

	Vec2f off = grapple.grapple_pos - blob.getPosition();

	f32 ropelen = Maths::Max(0.1f, off.Length() / 32.0f);
	if (ropelen > 200.0f)
	{
		rope.SetVisible(false);
		hook.SetVisible(false);
		return;
	}

	rope.ResetTransform();
	rope.ScaleBy(Vec2f(ropelen, 1.0f));

	rope.TranslateBy(Vec2f(ropelen * 16.0f, 0.0f));

	rope.RotateBy(-off.Angle() , Vec2f());

	hook.ResetTransform();
	if (grapple.grapple_id == 0xffff) //still in air
	{
		grapple.cache_angle = -grapple.grapple_vel.Angle();
	}
	hook.RotateBy(grapple.cache_angle , Vec2f());

	hook.TranslateBy(off);
	hook.SetFacingLeft(false);

	//GUI::DrawLine(blob.getPosition(), grapple.grapple_pos, SColor(255,255,255,255));
}

void ManageGrapple(CBlob@ this, GrappleInfo@ grapple, bool using, bool useclick)
{
	CSprite@ sprite = this.getSprite();
	Vec2f pos = this.getPosition();

	if (useclick)
	{
		if (canSend(this)) //otherwise grapple
		{
			grapple.grappling = true;
			grapple.grapple_id = 0xffff;
			grapple.grapple_pos = pos;

			grapple.grapple_ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			//aim in direction of cursor
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{
				grapple.grapple_vel = direction * grapple_grapple_throw_speed;
			}
			else
			{
				grapple.grapple_vel = Vec2f_zero;
			}

			SyncGrapple(this);
		}
	}

	if (grapple.grappling)
	{
		//update grapple
		//TODO move to its own script?

		if (!using)
		{
			if (canSend(this))
			{
				grapple.grappling = false;
				SyncGrapple(this);
			}
		}
		else
		{
			const f32 grapple_grapple_range = grapple_grapple_length * grapple.grapple_ratio;
			const f32 grapple_grapple_force_limit = this.getMass() * grapple_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if (grapple.grapple_ratio > 0.2f)
				grapple.grapple_ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = grapple.grapple_pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - grapple_grapple_range;
				if (offdist > 0)
				{
					offset = force * Maths::Min(8.0f, offdist * grapple_grapple_stiffness);
					force *= Maths::Min(grapple_grapple_force_limit, Maths::Max(0.0f, offdist + grapple_grapple_slack) * grapple_grapple_force);
				}
				else
				{
					force.Set(0, 0);
				}
			}

			//left map? close grapple
			if (grapple.grapple_pos.x < map.tilesize || grapple.grapple_pos.x > (map.tilemapwidth - 1)*map.tilesize)
			{
				if (canSend(this))
				{
					SyncGrapple(this);
					grapple.grappling = false;
				}
			}
			else if (grapple.grapple_id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(grapple.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0, 1);

				grapple.grapple_vel = (grapple.grapple_vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = grapple.grapple_pos + grapple.grapple_vel;
				next -= offset;

				Vec2f dir = next - grapple.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while (delta > 0 && !found) //fake raycast
				{
					if (delta > step)
					{
						grapple.grapple_pos += dir * step;
					}
					else
					{
						grapple.grapple_pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, grapple, map, dist);
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
					Vec2f dif = pos - grapple.grapple_pos;
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
				if (grapple.grapple_id != 0)
				{
					@b = getBlobByNetworkID(grapple.grapple_id);
					if (b is null)
					{
						grapple.grapple_id = 0;
					}
				}

				if (b !is null)
				{
					grapple.grapple_pos = b.getPosition()+this.get_Vec2f("grapple_offset");
				}
				else if (shouldReleaseGrapple(this, grapple, map))
				{
					if (canSend(this))
					{
						grapple.grappling = false;
						SyncGrapple(this);
					}
				}
	
				if (b !is null && b.getMass() < this.getMass()){
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

				if (b !is null && b.getMass() < this.getMass()){
					int mod = 2;
					if(b.getName() == "warboat" || b.getName() == "longboat")mod = 16;
					b.AddForce(-force*((b.getMass()/this.getMass())/mod));
				}

			}
		}

	}
}

bool checkGrappleStep(CBlob@ this, GrappleInfo@ grapple, CMap@ map, const f32 dist)
{
	if (map.getSectorAtPosition(grapple.grapple_pos, "barrier") !is null)  //red barrier
	{
		if (canSend(this))
		{
			grapple.grappling = false;
			SyncGrapple(this);
		}
	}
	else if (grappleHitMap(grapple, map, dist))
	{
		grapple.grapple_id = 0;

		grapple.grapple_ratio = Maths::Max(0.2, Maths::Min(grapple.grapple_ratio, dist / grapple_grapple_length));

		if (canSend(this)) SyncGrapple(this);

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(grapple.grapple_pos);
		if (b !is null)
		{
			if (b is this)
			{
				//can't grapple self if not reeled in
				if (grapple.grapple_ratio > 0.5f)
					return false;

				if (canSend(this))
				{
					grapple.grappling = false;
					SyncGrapple(this);
				}

				return true;
			}
			else if (b.isCollidable() && !b.isAttached())// && b.getShape().isStatic())
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				grapple.grapple_ratio = Maths::Max(0.2, Maths::Min(grapple.grapple_ratio, b.getDistanceTo(this) / grapple_grapple_length));

				grapple.grapple_id = b.getNetworkID();
				this.set_Vec2f("grapple_offset",grapple.grapple_pos-b.getPosition());
				
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

bool grappleHitMap(GrappleInfo@ grapple, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(grapple.grapple_pos + Vec2f(0, -3)) ||			//fake quad
	        map.isTileSolid(grapple.grapple_pos + Vec2f(3, 0)) ||
	        map.isTileSolid(grapple.grapple_pos + Vec2f(-3, 0)) ||
	        map.isTileSolid(grapple.grapple_pos + Vec2f(0, 3)) ||
	        (dist > 10.0f && map.getSectorAtPosition(grapple.grapple_pos, "tree") !is null);   //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, GrappleInfo@ grapple, CMap@ map)
{
	return !grappleHitMap(grapple, map) || this.isKeyPressed(key_use);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}
