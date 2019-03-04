const f32 grapple_grapple_length = 72.0f;
const f32 grapple_grapple_slack = 16.0f;
const f32 grapple_grapple_throw_speed = 20.0f;

const f32 grapple_grapple_force = 2.0f;
const f32 grapple_grapple_accel_limit = 1.5f;
const f32 grapple_grapple_stiffness = 0.1f;

const string grapple_sync_cmd = "grapple sync";

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

void onInit(CSprite@ this)
{
	string texname = "Entities/Characters/Archer/ArcherMale.png";
	//grapple
	this.RemoveSpriteLayer("hook");
	CSpriteLayer@ hook = this.addSpriteLayer("hook", texname , 16, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (hook !is null)
	{
		Animation@ anim = hook.addAnimation("default", 0, false);
		anim.AddFrame(178);
		hook.SetRelativeZ(2.0f);
		hook.SetVisible(false);
	}

	this.RemoveSpriteLayer("rope");
	CSpriteLayer@ rope = this.addSpriteLayer("rope", texname , 32, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rope !is null)
	{
		Animation@ anim = rope.addAnimation("default", 0, false);
		anim.AddFrame(81);
		rope.SetRelativeZ(-1.5f);
		rope.SetVisible(false);
		rope.SetOffset(Vec2f(0,4));
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	GrappleInfo@ grapple;
	if (!blob.get("GrappleInfo", @grapple))
	{
		return;
	}
	
	if(doRopeUpdate(this, blob, grapple)){
		this.SetFrame(1);
	} else {
		this.SetFrame(0);
	}
}

bool doRopeUpdate(CSprite@ this, CBlob@ blob, GrappleInfo@ grapple)
{
	CSpriteLayer@ rope = this.getSpriteLayer("rope");
	CSpriteLayer@ hook = this.getSpriteLayer("hook");

	bool visible = grapple !is null && grapple.grappling;

	rope.SetVisible(visible);
	hook.SetVisible(visible);
	if (!visible)
	{
		return visible;
	}

	Vec2f off = grapple.grapple_pos - blob.getPosition();

	f32 ropelen = Maths::Max(0.1f, off.Length() / 32.0f);
	if (ropelen > 200.0f)
	{
		rope.SetVisible(false);
		hook.SetVisible(false);
		return visible;
	}

	rope.ResetTransform();
	rope.ScaleBy(Vec2f(ropelen, 1.0f));

	rope.TranslateBy(Vec2f(ropelen * 16.0f, 0.0f));

	rope.RotateBy(-(off+Vec2f(0,-4)).Angle() , Vec2f());

	hook.ResetTransform();
	if (grapple.grapple_id == 0xffff) //still in air
	{
		grapple.cache_angle = -grapple.grapple_vel.Angle();
	}
	hook.RotateBy(grapple.cache_angle , Vec2f());

	hook.TranslateBy(off);
	hook.SetFacingLeft(false);

	return visible;
	//GUI::DrawLine(blob.getPosition(), grapple.grapple_pos, SColor(255,255,255,255));
}

void onInit(CBlob@ this)
{
	this.set_Vec2f("grapple_offset",Vec2f(0,0));

	GrappleInfo grapple;
	this.set("GrappleInfo", @grapple);
	
	this.addCommandID(grapple_sync_cmd);
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action2);
	}
}

void onTick(CBlob@ this)
{

	GrappleInfo@ grapple;
	if (!this.get("GrappleInfo", @grapple))
	{
		return;
	}

	ManageGrapple(this, grapple);
}

void ManageGrapple(CBlob@ this, GrappleInfo@ grapple)
{
	CSprite@ sprite = this.getSprite();
	Vec2f pos = this.getPosition();

	bool right_click = false;
	bool right_press = false;
	
	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder !is null){
			//right_click = holder.isKeyJustPressed(key_action2);
			//right_press = holder.isKeyPressed(key_action2);
			
			right_press = point.isKeyPressed(key_action2);
			right_click = point.isKeyJustPressed(key_action2);
		}
	
		if (right_click)
		{
			print("gothere");
			if (canSend(this))
			{
				grapple.grappling = true;
				grapple.grapple_id = 0xffff;
				grapple.grapple_pos = pos;

				grapple.grapple_ratio = 1.0f; //allow fully extended

				Vec2f direction = this.getAimPos() - pos;
				if (holder !is null)direction = holder.getAimPos() - pos;

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

			if (!right_press)
			{
				if (canSend(this))
				{
					grapple.grappling = false;
					SyncGrapple(this);
				}
			}
			else
			{
				if(holder is null)return;
				
				const f32 grapple_grapple_range = grapple_grapple_length * grapple.grapple_ratio;
				const f32 grapple_grapple_force_limit = holder.getMass() * grapple_grapple_accel_limit;

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

					grapple.grapple_vel = (grapple.grapple_vel * drag) + gravity - (force * (2 / holder.getMass()));

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
						if (b.isKeyJustPressed(key_action1) ||
								b.isKeyJustPressed(key_action2) ||
								holder.isKeyPressed(key_use))
						{
							if (canSend(this))
							{
								SyncGrapple(this);
								grapple.grappling = false;
							}
						}
					}
					else if (shouldReleaseGrapple(this, grapple, map))
					{
						if (canSend(this))
						{
							SyncGrapple(this);
							grapple.grappling = false;
						}
					}
		
					if (b !is null){
						float mod = b.getMass()/holder.getMass();
						if(mod > 1)mod = 1;
						holder.AddForce(force*mod);
					}else 
						holder.AddForce(force);
					
					/*
					Vec2f target = (holder.getPosition() + offset);
					if (!map.rayCastSolid(holder.getPosition(), target))
					{
						holder.setPosition(target);
					}*/

					if (b !is null)if(b.getName() != "buoy"){
						int mod = 2;
						if(b.getName() == "warboat" || b.getName() == "longboat")mod = 16;
						b.AddForce(-force*((b.getMass()/holder.getMass())/mod));
					}

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
			else if (b.isCollidable() && !b.isAttached() && b.getCarriedBlob() !is this)
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

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID(grapple_sync_cmd))
	{
		HandleGrapple(this, params, !canSend(this));
	}
}

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

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}