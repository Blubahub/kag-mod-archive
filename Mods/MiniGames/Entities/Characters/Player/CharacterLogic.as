// Character logic


#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "PlacementCommon.as";
#include "CharacterCommon.as";

s32 curent_frame = 0;
const s32 hit_frame = 23;
const f32 hit_damage = 0.5f;

const string send_hit = "send hit";

void onInit(CBlob@ this)
{
	this.addCommandID(send_hit);
	
	this.set_f32("gib health", 0.0f);

	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_s16("hit_cooldown",0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 5, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(!getNet().isClient())
		return;
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	
	if(ismyplayer)
	{
		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried !is null)
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
	
	if(this.isKeyPressed(key_action1))
	{
		RunnerMoveVars@ moveVars;
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor = 0.5f;
			moveVars.jumpFactor = 0.5f;
		}
	}
	if(this.get_s16("hit_cooldown") > 0)
		this.set_s16("hit_cooldown",this.get_s16("hit_cooldown")-1);
	
	curent_frame = this.getSprite().getFrame();
	
	CPlayer@ p = this.getPlayer();
	if(p !is null && this.get_s16("hit_cooldown") <= 0 && curent_frame == hit_frame)
	{
		CBitStream params;
		params.write_u16(p.getNetworkID());
		this.SendCommand(this.getCommandID(send_hit), params);
		this.set_s16("hit_cooldown",12);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (!getNet().isServer())
		return;

    if (cmd == this.getCommandID(send_hit))
	{
	    CPlayer@ p = ResolvePlayer(params);
		CBlob@ blob = p.getBlob();
		if (blob !is null)
		{
			Vec2f aimpos = blob.getAimPos();
			Vec2f pos = blob.getPosition();
			Vec2f aim_vec = (pos - aimpos);
			aim_vec.Normalize();
			f32 mouseAngle = aim_vec.getAngleDegrees() * -1.0f + 180;
			DoAttack(blob, hit_damage, mouseAngle, 18.0f, Hitters::builder, 16.0f);
		}
	}
}

CPlayer@ ResolvePlayer( CBitStream@ data )
{
    u16 playerNetID;
	if(!data.saferead_u16(playerNetID))
		return null;
	
	return getPlayerByNetworkId(playerNetID);
}
	
void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, f32 attack_distance)
{
	if (!getNet().isServer())
		return;
	
	if (aimangle < 0.0f)
		aimangle += 360.0f;

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	const bool jab = false;

	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore)
			{
				if (b.hasTag("ignore sword")) continue;

				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					
					float final_damage = damage;
					
					if(getGameTime() <= this.get_u16("transform_timestamp")+10)
						final_damage = 2.0f;
					
					this.server_Hit(b, hi.hitpos, velocity, final_damage, type, true);

					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else
				if (!dontHitMoreMap)
				{
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					if (ground || wood || dirt_stone || gold)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);

						int check_x = -(offset.x > 0 ? -1 : 1);
						int check_y = -(offset.y > 0 ? -1 : 1);
						if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
						        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
							continue;

						bool canhit = true;

						canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

						dontHitMoreMap = true;
						if (canhit)
						{
							map.server_DestroyTile(hi.hitpos, 0.1f, this);
						}
					}
				}
		}
	}

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f))
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

bool canHit(CBlob@ this, CBlob@ b)
{
	if (b.hasTag("invincible"))
		return false;

	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;
	if (b.getTeamNum() == this.getTeamNum() && b.hasTag("player"))
		return false;

	return true;
}