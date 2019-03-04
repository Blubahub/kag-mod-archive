#include "Hitters.as";
#include "Explosion.as";

// const u32 fuel_timer_max = 30 * 600;
const f32 SPEED_MAX = 70;
const Vec2f gun_offset = Vec2f(-30, 8.5);

const u32 shootDelay = 3; // Ticks
const f32 damage = 2.0f;

//ICONS
//AddIconToken("$bf109$", "Bf109.png", Vec2f(40, 32), 0);


string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

string[] smokes = 
{
	"LargeSmoke.png",
	"SmallSmoke1.png",
	"SmallSmoke2.png"
};

void onInit(CBlob@ this)
{
	this.set_f32("velocity", 0.0f);
	
	this.set_string("custom_explosion_sound", "bigbomb_explosion.ogg");
	this.set_bool("map_damage_raycast", true);
	this.Tag("map_damage_dirt");
	
	this.Tag("vehicle");
	this.Tag("aerial");
	this.Tag("wooden");
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Aircraft_Loop.ogg");
	sprite.SetEmitSoundSpeed(0.0f);
	sprite.SetEmitSoundPaused(false);

	this.getShape().SetRotationsAllowed(true);
	this.set_Vec2f("direction", Vec2f(0, 0));
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("tracer");
	CSpriteLayer@ tracer = this.addSpriteLayer("tracer", "GatlingGun_Tracer.png", 32, 1, this.getBlob().getTeamNum(), 0);

	if (tracer !is null)
	{
		Animation@ anim = tracer.addAnimation("default", 0, false);
		anim.AddFrame(0);
		
		tracer.SetOffset(gun_offset);
		tracer.SetRelativeZ(-1.0f);
		tracer.SetVisible(false);
		tracer.setRenderStyle(RenderStyle::additive);
	}
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ ap_pilot = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap_pilot !is null)
	{
		CBlob@ pilot = ap_pilot.getOccupied();
		
		if (pilot !is null && this.getHealth() > 10.00f)
		{
			Vec2f dir = pilot.getPosition() - pilot.getAimPos();
			const f32 len = dir.Length();
			dir.Normalize();
		
			// this.SetFacingLeft(dir.x > 0);
			this.SetFacingLeft(this.getVelocity().x < -0.1f);
			// const f32 ang = this.isFacingLeft() ? 0 : 180;
			// this.setAngleDegrees(ang - dir.Angle());
		
			bool pressed_w = ap_pilot.isKeyPressed(key_up);
			bool pressed_s = ap_pilot.isKeyPressed(key_down);
			bool pressed_lm = ap_pilot.isKeyPressed(key_action1);
			
			if (pressed_lm)
			{
				Shoot(this);
			}
			
			// bool pressed_s = ap_pilot.isKeyPressed(key_down);
		
			if (pressed_w) 
			{
				this.set_f32("velocity", Maths::Min(SPEED_MAX, this.get_f32("velocity") + 2.5f));
			}
			
			if (pressed_s) 
			{
				this.set_f32("velocity", Maths::Min(SPEED_MAX, this.get_f32("velocity") - 0.50f));
			}
			
			this.set_Vec2f("direction", dir);
			
			if (!this.hasTag("disable bomber drop") && ap_pilot.isKeyPressed(key_action3) && this.get_u32("lastDropTime") < getGameTime()) 
			{
				CInventory@ inv = this.getInventory();
				if (inv !is null) 
				{
					u32 itemCount = inv.getItemsCount();
					
					if (getNet().isClient()) 
					{
						if (itemCount > 0)
						{ 
							this.getSprite().PlaySound("bridge_open", 1.0f, 1.0f);
						}
						else if (pilot.isMyPlayer())
						{
							Sound::Play("NoAmmo");
						}
					}
					
					if (itemCount > 0) 
					{
						if (getNet().isServer()) 
						{
							CBlob@ item = inv.getItem(0);
							u32 quantity = item.getQuantity();

							if (item.maxQuantity>8)
							{ 
								// To prevent spamming 
								this.server_PutOutInventory(item);
								item.setPosition(this.getPosition());
							}
							else
							{
								CBlob@ dropped = server_CreateBlob(item.getName(), this.getTeamNum(), this.getPosition());
								dropped.server_SetQuantity(1);
								dropped.SetDamageOwnerPlayer(pilot.getPlayer());
								dropped.Tag("no pickup");
								
								if (quantity > 0)
								{
									item.server_SetQuantity(quantity - 1);
								}
								if (item.getQuantity() == 0) 
								{
									item.server_Die();
								}
							}
						}
					}
					
					this.set_u32("lastDropTime",getGameTime() + 30);
				}
			}
		}		
	}
	else
	{
		this.set_f32("velocity", Maths::Max(0, this.get_f32("velocity") - 1.00f));
	}

	const f32 hmod = this.getHealth() / this.getInitialHealth();
	const f32 v = this.get_f32("velocity");
	Vec2f d = this.get_Vec2f("direction");
	// Vec2f grav = Vec2f(0, 1) * 4 * (SPEED_MAX - v);
	
	this.AddForce(-d * v * hmod);

	if (this.getVelocity().Length() > 1.50f && v > 0.25f) this.setAngleDegrees((this.isFacingLeft() ? 180 : 0) - this.getVelocity().Angle());
	else this.setAngleDegrees(0);
	
	if (getNet().isClient())
	{
		this.getSprite().SetEmitSoundSpeed(0.5f + (this.get_f32("velocity") / SPEED_MAX * 0.4f) * (this.getVelocity().Length() * 0.15f));
		
		if (hmod < 0.7 && u32(getGameTime() % 20 * hmod) == 0) ParticleAnimated(CFileMatcher(smokes[XORRandom(smokes.length)]).getFirst(), this.getPosition(), Vec2f(0, 0), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 3 + XORRandom(4), XORRandom(100) * -0.001f, true);
	}
}

void Shoot(CBlob@ this)
{
	if (getGameTime() < this.get_u32("fireDelay")) return;

	f32 sign = (this.isFacingLeft() ? -1 : 1);
	f32 angleOffset = (10 * sign);
	f32 angle = this.getAngleDegrees() + ((XORRandom(200) - 100) / 100.0f) + angleOffset;
		
	Vec2f dir = Vec2f(sign, 0.0f).RotateBy(angle);
	
	Vec2f offset = gun_offset;
	offset.x *= -sign;
	
	Vec2f startPos = this.getPosition() + offset.RotateBy(angle);
	Vec2f endPos = startPos + dir * 500;
	Vec2f hitPos;
	
	bool flip = this.isFacingLeft();		
	HitInfo@[] hitInfos;
	
	bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
	f32 length = (hitPos - startPos).Length();
	
	bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);
		
	if (getNet().isClient())
	{
		DrawLine(this.getSprite(), startPos, length / 32, angleOffset, this.isFacingLeft());
		this.getSprite().PlaySound("AssaultFire.ogg", 1.00f, 1.00f);
		
		// Vec2f mousePos = getControls().getMouseScreenPos();
		// getControls().setMousePosition(Vec2f(mousePos.x, mousePos.y - 10));
	}
	
	if (getNet().isServer())
	{
		if (blobHit)
		{
			f32 falloff = 1;
			for (u32 i = 0; i < hitInfos.length; i++)
			{
				if (hitInfos[i].blob !is null)
				{	
					CBlob@ blob = hitInfos[i].blob;
					
					if ((blob.isCollidable() || blob.hasTag("flesh")) && blob.getTeamNum() != this.getTeamNum())
					{
						// print("Hit " + blob.getName() + " for " + damage * falloff);
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage * Maths::Max(0.1, falloff), Hitters::arrow);
						falloff = falloff * 0.5f;			
					}
				}
			}
		}
		
		if (mapHit)
		{
			CMap@ map = getMap();
			TileType tile =	map.getTile(hitPos).type;
			
			if (!map.isTileBedrock(tile) && tile != CMap::tile_ground_d0 && tile != CMap::tile_stone_d0)
			{
				map.server_DestroyTile(hitPos, damage * 0.125f);
			}
		}
	}
	
	this.set_u32("fireDelay", getGameTime() + shootDelay);
}

void DrawLine(CSprite@ this, Vec2f startPos, f32 length, f32 angle, bool flip)
{
	CSpriteLayer@ tracer = this.getSpriteLayer("tracer");
	
	tracer.SetVisible(true);
	
	tracer.ResetTransform();
	tracer.ScaleBy(Vec2f(length, 1.0f));
	tracer.TranslateBy(Vec2f(length * 16.0f, 0.0f));
	tracer.RotateBy(angle + (flip ? 180 : 0), Vec2f());
}

void onTick(CSprite@ this)
{
	if ((this.getBlob().get_u32("fireDelay") - (shootDelay - 1)) < getGameTime()) this.getSpriteLayer("tracer").SetVisible(false);
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onCollision(CBlob@ this,CBlob@ blob,bool solid)
{
	float power = this.getOldVelocity().getLength();
	if (power > 5.0f && blob == null)
	{
		if (getNet().isClient())
		{
			Sound::Play("WoodHeavyHit1.ogg", this.getPosition(), 1.0f);
		}

		this.server_Hit(this, this.getPosition(), Vec2f(0, 0), (this.getAttachments().getAttachmentPointByName("FLYER") is null || this.getHealth() < 10.0f) ? power * 2.5f : power * 0.0050f, 0, true);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (point is null) return true;
		
	CBlob@ holder = point.getOccupied();
	if (holder is null) return true;
	else return false;
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("exploded")) return;

	f32 random = XORRandom(40);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (80.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.50f);
	
	Explode(this, 40.0f + random, 25.0f);
	
	for (int i = 0; i < 10 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();
		
		LinearExplosion(this, dir, 16.0f + XORRandom(16) + (modifier * 8), 16 + XORRandom(24), 3, 2.00f, Hitters::explosion);
	}
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	for (int i = 0; i < 35; i++)
	{
		MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(220) * 0.01f, 90), particles[XORRandom(particles.length)]);
	}
	
	this.Tag("exploded");
	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}

void onAttach(CBlob@ this,CBlob@ attached,AttachmentPoint @attachedPoint)
{
	if (attached.hasTag("bomber")) return;

	attached.Tag("invincible");
	attached.Tag("invincibilityByVehicle");
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("invincible");
	detached.Untag("invincibilityByVehicle");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	AttachmentPoint@ ap_pilot = this.getAttachments().getAttachmentPointByName("PILOT");
	
	if (ap_pilot !is null)
	{
		return ap_pilot.getOccupied() == null;
	}
	else return true;
}
			