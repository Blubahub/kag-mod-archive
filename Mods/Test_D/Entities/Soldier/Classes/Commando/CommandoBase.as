#include "SoldierCommon.as"
#include "HoverMessage.as"
#include "Sparks.as"
#include "GameColours.as"
#include "ExplosionParticles.as"
#include "MapCommon.as"

const f32 RUSH_SPEED = 5.0f;
const f32 RUSH_DMG_DISTANCE = 32.0f;
const s32 RUSH_CHARGE_TIME = 15;
const s32 RUSH_FORCE_TIME = RUSH_CHARGE_TIME * 2;
const s32 RUSH_CHARGE_COOLDOWN = 30;

const f32 WALK_MODIFIER = 1.25f;
const f32 STABBING_MODIFIER_MAXIMUM = 0.5f;
const f32 STABBING_RECOVERY_TIME = 1.0f;
const f32 STAB_RADIUS = 8.0f;
const f32 STAB_DAMAGE = 1.5f;
const f32 RUSH_DAMAGE = 3.0f;
const f32 WALLJUMP_X = 1.5f;
const f32 WALLJUMP_Y = 4.5f;
const int FLASHBANGS = 1;

const f32 GRENADE_TIMEOUT = 9.0f;

namespace Soldier
{
	void Stab(CBlob@ this, Data@ data, const bool left)
	{
		CBitStream params;
		params.write_netid(this.getNetworkID());
		params.write_Vec2f(this.getPosition());
		params.write_bool(left);
		this.SendCommand(Soldier::Commands::COMMANDO_STAB, params);
	}

	void StabHit(CBlob@ this, Data@ data, Vec2f pos, const bool left)
	{
		//step towards it each stab (progressively slow)
		data.walkSpeedModifier = (data.walkSpeedModifier + STABBING_MODIFIER_MAXIMUM) * 0.5f;

		CMap@ map = getMap();
		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(pos, STAB_RADIUS, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (b !is this)
				{
					const u8 hitter = 0;
					if (b.getTeamNum() != this.getTeamNum() && (b.getName() == "soldier" || b.getName() == "bullet" || b.hasTag("explosive")))
					{
						this.server_Hit(b, pos,
						                Vec2f(left ? -1.0f : 1.0f, 0.0f) * 3.0f,
						                STAB_DAMAGE,
						                hitter, true);
						break; // one at a time
					}
				}
			}
		}
	}

	void Rush(CBlob@ this, Data@ data)
	{
		CBitStream params;
		params.write_netid(this.getNetworkID());
		params.write_Vec2f(this.getPosition());

		bool anypressed = data.left || data.right || data.up || data.down;

		if(anypressed)
		{
			params.write_bool(data.left);
			params.write_bool(data.right);

			params.write_bool(data.up);
			params.write_bool(data.down);
		}
		else
		{
			params.write_bool(data.facingLeft);
			params.write_bool(!data.facingLeft);

			params.write_bool(false);
			params.write_bool(false);
		}

		this.SendCommand(Soldier::Commands::COMMANDO_RUSH, params);
	}

	Vec2f RushHit(CBlob@ this, Data@ data, Vec2f pos, const bool left, const bool right, const bool up, const bool down)
	{
		CMap@ map = getMap();
		HitInfo@[] hitInfos;

		Vec2f direction = Vec2f( (left ? -1 : 0) + (right ? 1 : 0), (up ? -1 : 0) + (down ? 1 : 0) );
		direction.Normalize();

		Vec2f buffer = direction * this.getRadius();

		direction *= RUSH_DMG_DISTANCE;

		if (!getMap().getHitInfosFromRay(pos, -direction.Angle(), RUSH_DMG_DISTANCE, this, @hitInfos))
			return direction - buffer;

		for (uint i = 0; i < hitInfos.length; i++)
		{
			CBlob @b = hitInfos[i].blob;
			if (b !is null && b !is this)
			{
				const u8 hitter = 0;
				if (b.getTeamNum() != this.getTeamNum() && b.getName() == "soldier" || b.getName() == "bullet")
				{
					this.server_Hit(b, pos,
					                Vec2f(left ? -1.0f : 1.0f, 0.0f) * 3.0f,
					                RUSH_DAMAGE,
					                hitter, true);
				}
			}
			if (b is null) //hit wall
			{
				return (hitInfos[i].hitpos - data.pos) - buffer;
			}
		}

		return direction - buffer;

	}

}

bool willCommandoFitAt(Vec2f pos)
{
	CMap@ map = getMap();
	pos = TWMap::getNearestTileCentrePos(map, pos);
	u8 tile = map.getTile(TWMap::offsetAt(map, pos)).type;
	u8 above = map.getTile(TWMap::offsetAt(map, pos + Vec2f(0, -map.tilesize))).type;
	return !TWMap::isTileTypeSolid(tile) && !TWMap::isTileTypeSolid(above);
}

void onInit(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);
	data.walkSpeedModifier = WALK_MODIFIER;
	data.grenades = data.initialGrenades = FLASHBANGS;
	data.grenadeTimeout = getTicksASecond() * GRENADE_TIMEOUT;
	data.grenadeType = Soldier::FLASHBANG;
}

void onTick(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (data.dead || data.inMenu || data.stunned || getRules().isWarmup())
		return;

	if (data.walkSpeedModifier < WALK_MODIFIER)
	{
		if (data.shotTime >= 0)
		{
			f32 recovery_rate = (WALK_MODIFIER - STABBING_MODIFIER_MAXIMUM) / STABBING_RECOVERY_TIME / 30.0f;
			data.walkSpeedModifier = Maths::Min(data.walkSpeedModifier + recovery_rate, WALK_MODIFIER);
		}
	}

	//todo: consider syncing shottime for proper anim?
	if (data.local)
	{
		//knife logic
		if (data.fire)
		{
			//holding button - charge up
			if (data.shotTime >= RUSH_FORCE_TIME)
			{
				Soldier::Rush(this, data);
				data.shotTime = -RUSH_CHARGE_COOLDOWN;
			}
			else
			{
				data.shotTime++;
			}
		}
		else
		{
			if (this.isKeyJustReleased(key_action1) && data.shotTime >= 0)
			{
				if (data.shotTime < RUSH_CHARGE_TIME)
				{
					Soldier::Stab(this, data, data.facingLeft);
				}
				else if (data.shotTime >= RUSH_CHARGE_TIME)
				{
					Soldier::Rush(this, data);
					data.shotTime = -RUSH_CHARGE_COOLDOWN;
				}
			}
			else
			{
				data.shotTime = Maths::Min(data.shotTime + 1, 0);
			}
		}
	}

	// grab wall

	bool fore_rayHead = false;
	bool fore_rayFoot = false;
	bool back_rayHead = false;
	bool back_rayFoot = false;
	bool rayBelow = false;

	const s32 airtime_limit = 10;

	const f32 face_disp = -data.radius * 0.8f;
	const f32 foot_disp = 1.0f;
	const f32 below_disp = 10.0f;

	f32 fa_sign = (data.facingLeft ? -1 : 1);
	f32 offset = fa_sign * data.map.tilesize * 1.1f;

	fore_rayHead = data.map.rayCastSolid(data.pos + Vec2f(0, face_disp), data.pos + Vec2f(offset, face_disp));
	fore_rayFoot = data.map.rayCastSolid(data.pos + Vec2f(0, foot_disp), data.pos + Vec2f(offset, foot_disp));
	back_rayHead = data.map.rayCastSolid(data.pos + Vec2f(0, face_disp), data.pos + Vec2f(-offset, face_disp));
	back_rayFoot = data.map.rayCastSolid(data.pos + Vec2f(0, foot_disp), data.pos + Vec2f(-offset, foot_disp));
	rayBelow = data.map.rayCastSolid(data.pos + Vec2f(0, foot_disp), data.pos + Vec2f(0, below_disp));
	bool rayTop = data.map.rayCastSolid(data.pos, data.pos + Vec2f(0, data.radius * -2.0f));

	data.oldWallGrab = data.wallGrab;

	bool wallgrab_proto = !data.onGround && !data.onLadder && data.airTime > airtime_limit &&
	                      data.vel.y < 5.0f &&
	                      (data.left && data.facingLeft || data.right && !data.facingLeft);
	bool wall_grab_fore = fore_rayHead && fore_rayFoot && !rayBelow;
	bool wall_grab_back = back_rayHead && back_rayFoot && !rayBelow;
	data.wallGrab = wallgrab_proto && wall_grab_fore && ! wall_grab_back;

	bool walljump = (data.oldWallGrab && (!data.wallGrab && data.up ||
	                                      (this.isKeyJustPressed(key_left) && !data.facingLeft ||
	                                       this.isKeyJustPressed(key_right) &&  data.facingLeft)));

	if (data.wallGrab)
	{
		f32 climb_speed = 2.0f;
		f32 still_speed = -0.44f;

		if (!data.oldWallGrab)
		{
			data.sprite.PlaySound("GrabWall");
		}

		//allow walljumping if tapping back off the wall
		if (!data.down && (this.isKeyJustPressed(key_left) && !data.facingLeft ||
		                   this.isKeyJustPressed(key_right) &&  data.facingLeft))
		{
			walljump = true;
		}
		//allow sliding up or down if pressing them
		else if (data.up == data.down)
		{
			data.vel = Vec2f(fa_sign, still_speed);
		}
		else if (data.down)
		{
			data.vel = Vec2f(fa_sign, climb_speed + still_speed);
		}
		else if (data.up)
		{
			data.vel = Vec2f(fa_sign, -climb_speed);
		}

		data.airTime = airtime_limit + 1; //ensure we keep grabbing
		this.setVelocity(data.vel);
	}

	if (walljump)
	{
		if (data.oldWallGrab)
		{
			data.sprite.PlaySound("GrabWall");
		}

		data.vel = Vec2f(fa_sign * -WALLJUMP_X, -WALLJUMP_Y);
		data.airTime = 0;
		this.setVelocity(data.vel);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (cmd == Soldier::Commands::COMMANDO_STAB)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		Vec2f pos = params.read_Vec2f();
		const bool left = params.read_bool();

		if (getNet().isServer())
		{
			Soldier::StabHit(this, data, pos, left);
		}

		// client-effects
		CSprite@ sprite = this.getSprite();
		sprite.PlaySound("Stab");

		data.specialAnim = true;
		sprite.SetAnimation("stab");
		Animation@ anim = sprite.getAnimation("stab");
		if (anim !is null){
			anim.frame = 0;
			anim.timer = 0;
		}
	}
	else if (cmd == Soldier::Commands::COMMANDO_RUSH)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		Vec2f pos = params.read_Vec2f();
		const bool left = params.read_bool();
		const bool right = params.read_bool();
		const bool up = params.read_bool();
		const bool down = params.read_bool();

		if (getNet().isServer() || caller.isMyPlayer())
		{
			Vec2f offset = Soldier::RushHit(this, data, pos, left, right, up, down);

			//find new pos that fits
			Vec2f newpos = data.pos + offset;
			u32 limit = 10;
			while(!willCommandoFitAt(newpos) && limit-- > 0)
			{
				newpos = (newpos + data.pos) * 0.5f;
			}

			//did we hit limit?
			if(limit != 0)
			{
				data.pos = TWMap::getNearestTileCentrePos(getMap(), newpos);
				this.setPosition(data.pos);
			}

			//null out velocity
			data.vel = Vec2f( (left ? -1 : 0) + (right ? 1 : 0), (up ? -1 : 0) + (down ? 1 : 0) );
			data.vel.Normalize();
			data.vel *= RUSH_SPEED;
			this.setVelocity(data.vel);

			Soldier::StabHit(this, data, data.pos, left);
		}

		//TODO: particles!

		// client-effects
		CSprite@ sprite = this.getSprite();
		sprite.PlaySound("Stab");

		data.specialAnim = true;
		sprite.SetAnimation("stab");
		sprite.getAnimation("stab").frame = 0;
		sprite.getAnimation("stab").timer = 0;
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (damage > 0.0f)
	{
		CSprite@ sprite = this.getSprite();
		if (hitBlob.getName() == "soldier")
		{
			sprite.PlaySound("StabHit");
		}
		else
		{
			sprite.PlayRandomSound("RicochetOut");
			Particles::Sparks(worldPoint, 4, velocity.getLength() * 0.4f, SColor(Colours::YELLOW));
		}
	}
}
