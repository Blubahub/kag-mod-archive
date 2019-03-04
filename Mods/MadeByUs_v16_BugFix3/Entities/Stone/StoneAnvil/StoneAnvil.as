#include "/Entities/Common/Attacks/Hitters.as";
#include "/Entities/Common/Attacks/LimitedAttacks.as";
#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";

const int pierce_amount = 8;

const f32 hit_amount_ground = 0.5f;
const f32 hit_amount_air = 1.0f;
const f32 hit_amount_air_fast = 3.0f;
const f32 hit_amount_cata = 10.0f;

void onInit(CBlob @ this)
{
	this.set_u8("launch team", 255);
	//this.server_setTeamNum(-1);
	this.Tag("medium weight");
	
	LimitedAttack_setup(this);

	this.set_u8("blocks_pierced", 0);
	u32[] tileOffsets;
	this.set("tileOffsets", tileOffsets);

	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 3));
	this.set_string("shop description", "Make-shift Anvil");
	this.set_u8("shop icon", 15);
	
	
	////Inherited from stone crafting
	AddIconToken("$hachethead_icon$", "HachetHead.png", Vec2f(6, 6), 0);
	{
		ShopItem@ s = addShopItem(this, "Hatchet Head", "$hachethead_icon$", "hachethead", "A crude axe head, can be placed on a stick to make a hatchet.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}
	AddIconToken("$hammer_icon$", "HammerHead.png", Vec2f(10, 5), 0);
	{
		ShopItem@ s = addShopItem(this, "Hammer Head", "$hammer_icon$", "hammerhead", "A hammer head, can be placed on a stick to make a hammer.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 40);
	}
	AddIconToken("$blade_icon$", "StoneBlade.png", Vec2f(4, 7), 0);
	{
		ShopItem@ s = addShopItem(this, "Stone Blade", "$blade_icon$", "stone_blade", "A small sharp blade, can be attached to a stick to make a knife.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}

	
	/////Unqiue to stone anvil
	AddIconToken("$pickhead_icon$", "PickHead.png", Vec2f(13, 4), 0);
	{
		ShopItem@ s = addShopItem(this, "Pick Head", "$pickhead_icon$", "pickhead", "Can be placed on a stick to make a Pickaxe.", false);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 2);
	}
	AddIconToken("$axehead_icon$", "AxeHead.png", Vec2f(6, 6), 0);
	{
		ShopItem@ s = addShopItem(this, "Axe Head", "$axehead_icon$", "axehead", "Can be placed on a stick to make an Axe.", false);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 2);
	}
	AddIconToken("$shield_icon$", "Shield.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Shield", "$shield_icon$", "shield", "A Shield for protection against the unsavoury types.", false);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 2);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 20);
	}
	AddIconToken("$lockset_icon$", "SimpleLockSet.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Simple lock set", "$lockset_icon$", "lockset", "A matching lock and key.\nLocks can be attached to doors.\nYou can open a locked door as long as you have the appropiate key in your inventory or held.\nMetal bars can be used on keys to clone them.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 2);
	}
	AddIconToken("$lock_icon$", "SimpleLock.png", Vec2f(7, 8), 0);
	{
		ShopItem@ s = addShopItem(this, "Simple lock", "$lock_icon$", "simplelock", "A simple lock without key.\nA key can be used on the lock to make the lock match the key.", false);
		AddRequirement(s.requirements, "blob", "metal_bar", "Metal Bar", 1);
	}
}
void onInit(CSprite @ this)
{
	this.animation.frame = XORRandom(2);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		if(isServer){
			if(name == "lockset"){
			
				int pass = XORRandom(10);
				CBlob@ slock = server_CreateBlob("simplelock",-1,this.getPosition());
				CBlob@ skey = server_CreateBlob("simplekey",-1,this.getPosition());
				
				slock.set_s16("password",pass);
				slock.Sync("password",true);
				skey.set_s16("password",pass);
				skey.Sync("password",true);
			}
		}
	}
}

void onTick(CBlob@ this)
{
	//rock and roll mode
	if (!this.getShape().getConsts().collidable)
	{
		Vec2f vel = this.getVelocity();
		f32 angle = vel.Angle();
		Slam(this, angle, vel, this.getShape().vellen * 1.5f);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob){
	//if (blob.hasTag("player") && this.getTeamNum() == blob.getTeamNum())return false;
	return true;
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached.getName() == "catapult") // rock n' roll baby
	{
		this.getShape().getConsts().mapCollisions = false;
		this.getShape().getConsts().collidable = false;
		this.getCurrentScript().tickFrequency = 3;
	}
	this.set_u8("launch team", detached.getTeamNum());
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached.getName() != "catapult") // end of rock and roll
	{
		this.getShape().getConsts().mapCollisions = true;
		this.getShape().getConsts().collidable = true;
		this.getCurrentScript().tickFrequency = 1;
	}
	this.set_u8("launch team", attached.getTeamNum());
}

void Slam(CBlob @this, f32 angle, Vec2f vel, f32 vellen)
{
	if (vellen < 0.1f)
		return;

	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	HitInfo@[] hitInfos;
	u8 team = this.get_u8("launch team");

	if (map.getHitInfosFromArc(pos, -angle, 30, vellen, this, false, @hitInfos))
	{
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			f32 dmg = 2.0f;

			if (hi.blob is null) // map
			{
				if (BoulderHitMap(this, hi.hitpos, hi.tileOffset, vel, dmg, Hitters::cata_boulder))
					return;
			}
			else if (team != u8(hi.blob.getTeamNum()))
			{
				this.server_Hit(hi.blob, pos, vel, dmg, Hitters::cata_boulder, true);
				this.setVelocity(vel * 0.9f); //damp

				// die when hit something large
				if (hi.blob.getRadius() > 32.0f)
				{
					this.server_Hit(this, pos, vel, 10, Hitters::cata_boulder, true);
				}
			}
		}
	}

	// chew through backwalls

	Tile tile = map.getTile(pos);
	if (map.isTileBackgroundNonEmpty(tile))
	{
		if (map.getSectorAtPosition(pos, "no build") !is null)
		{
			return;
		}
		map.server_DestroyTile(pos + Vec2f(7.0f, 7.0f), 10.0f, this);
		map.server_DestroyTile(pos - Vec2f(7.0f, 7.0f), 10.0f, this);
	}
}

bool BoulderHitMap(CBlob@ this, Vec2f worldPoint, int tileOffset, Vec2f velocity, f32 damage, u8 customData)
{
	//check if we've already hit this tile
	u32[]@ offsets;
	this.get("tileOffsets", @offsets);

	if (offsets.find(tileOffset) >= 0) { return false; }

	this.getSprite().PlaySound("ArrowHitGroundFast.ogg");
	f32 angle = velocity.Angle();
	CMap@ map = getMap();
	TileType t = map.getTile(tileOffset).type;
	u8 blocks_pierced = this.get_u8("blocks_pierced");
	bool stuck = false;

	if (map.isTileCastle(t) || map.isTileWood(t))
	{
		Vec2f tpos = this.getMap().getTileWorldPosition(tileOffset);
		if (map.getSectorAtPosition(tpos, "no build") !is null)
		{
			return false;
		}

		//make a shower of gibs here

		map.server_DestroyTile(tpos, 100.0f, this);
		Vec2f vel = this.getVelocity();
		this.setVelocity(vel * 0.8f); //damp
		this.push("tileOffsets", tileOffset);

		if (blocks_pierced < pierce_amount)
		{
			blocks_pierced++;
			this.set_u8("blocks_pierced", blocks_pierced);
		}
		else
		{
			stuck = true;
		}
	}
	else
	{
		stuck = true;
	}

	if (velocity.LengthSquared() < 5)
		stuck = true;

	if (stuck)
	{
		this.server_Hit(this, worldPoint, velocity, 10, Hitters::crush, true);
	}

	return stuck;
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid && blob !is null)
	{
		Vec2f hitvel = this.getOldVelocity();
		Vec2f hitvec = point1 - this.getPosition();
		f32 coef = hitvec * hitvel;

		if (coef < 0.706f) // check we were flying at it
		{
			return;
		}

		f32 vellen = hitvel.Length();

		//fast enough
		if (vellen < 1.0f)
		{
			return;
		}

		u8 tteam = this.get_u8("launch team");
		CPlayer@ damageowner = this.getDamageOwnerPlayer();

		//not teamkilling (except self)
		if (damageowner is null || damageowner !is blob.getPlayer())
		{
			if (
			    (blob.getName() != this.getName() &&
			     (blob.getTeamNum() == this.getTeamNum() || blob.getTeamNum() == tteam))
			)
			{
				return;
			}
		}

		//not hitting static stuff
		if (blob.getShape() !is null && blob.getShape().isStatic())
		{
			return;
		}

		//hitting less or similar mass
		if (this.getMass() < blob.getMass() - 1.0f)
		{
			return;
		}

		//get the dmg required
		hitvel.Normalize();
		f32 dmg = vellen > 8.0f ? 5.0f : (vellen > 4.0f ? 1.5f : 0.5f);

		//bounce off if not gibbed
		if(dmg < 4.0f)
		{
			this.setVelocity(blob.getOldVelocity() + hitvec * -Maths::Min(dmg * 0.33f, 1.0f));
		}

		//hurt
		this.server_Hit(blob, point1, hitvel, dmg, Hitters::boulder, true);

		return;

	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return damage *= 0.5f;
	}

	return damage;
}