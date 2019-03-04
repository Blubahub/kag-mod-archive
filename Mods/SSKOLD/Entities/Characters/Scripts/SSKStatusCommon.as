#include "SSKExplosion.as";
#include "SSKMovesetCommon.as"

// Status Common

const f32 MAX_DAMAGE = 1000.0f;
const f32 MAX_KNOCKBACK_SPEED = 25.0f;

const int MIN_GRABBEDTIME = 60;

shared class SSKStatusVars
{
	f32 damageStatus;  // accumulated damage

	bool inMoveAnimation;
	MoveAnimation currMoveAnimation;
	bool hitThisFrame;
	bool isAttackingLeft;

	u8 hitstunTime;
	bool isHitstunned;

	u16 grabbedTime;

	u16 dazeTime;

	Vec2f knockbackForce;

	u16 tumbleTime;
	bool isTumbling;
	Vec2f tumbleVec;

	bool fallSpecial;

	bool fastFalling;
};

void server_customHit(CBlob@ hitterBlob, CBlob@ victimBlob, Vec2f hitPos, Vec2f velocity, f32 damage, u8 customData, bool teamKill, CustomHitData@ customHitData)
{
	if (victimBlob.hasTag("invincible")) //pass through if invince
	{
		return;
	}

	SSKStatusVars@ victimStatusVars;
	if (victimBlob.get("statusVars", @victimStatusVars))
	{
		// add to player damage status
		bool attackBlocked = victimBlob.hasTag("shielded") && canBlockThisType(customData) && blockAttack(victimBlob, velocity, 0.0f);
		if ( !attackBlocked )
		{
			if (getNet().isServer())
			{
				victimStatusVars.damageStatus += damage;
				SyncDamageStatus(victimBlob);
			}
		}

		f32 x_side = 0.0f;
		f32 y_side = 0.0f;
		//if (hitterBlob !is null)
		{
			//Vec2f dif = hitterBlob.getPosition() - victimBlob.getPosition();
			if (velocity.x > 0.7)
			{
				x_side = 1.0f;
			}
			else if (velocity.x < -0.7)
			{
				x_side = -1.0f;
			}

			if (velocity.y > 0.5)
			{
				y_side = 1.0f;
			}
			else
			{
				y_side = -1.0f;
			}
		}

		f32 victimDamageStatus = victimStatusVars.damageStatus;

		bool force = victimBlob.hasTag("force_knock");
		if (force)
		{
			victimBlob.Untag("force_knock");
		}

		if (damage == 0 || force)
		{
			//get sponge
			CBlob@ sponge = null;
			//find the sponge with lowest absorbed
			CInventory@ inv = victimBlob.getInventory();
			if (inv !is null) 
			{
				u8 lowest_absorbed = 100;
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ invitem = inv.getItem(i);
					if(invitem.getName() == "sponge")
					{
						if(invitem.get_u8("absorbed") < lowest_absorbed)
						{
							lowest_absorbed = invitem.get_u8("absorbed");
							@sponge = invitem;
						}
					}
				}
			}
		}

		if (customHitData.dazeTime > 0)
		{
			u16 currDazeTime = victimStatusVars.dazeTime;
			victimStatusVars.dazeTime = Maths::Max(customHitData.dazeTime, currDazeTime);

			if (getNet().isServer())
			{
				SyncDazeTime(victimBlob);
			}
		}

		Vec2f knockbackVec(x_side, y_side);
		f32 knockbackSpeed = Maths::Min(customHitData.minKnockback + customHitData.scalingKnockback*victimDamageStatus, MAX_KNOCKBACK_SPEED);
		u16 tumbleTime = knockbackSpeed*6.0f;

		victimStatusVars.hitstunTime = customHitData.hitstunTime;
		victimStatusVars.isHitstunned = true;
		if (getNet().isServer())
		{
			u16 currTumbleTime = victimStatusVars.tumbleTime;

			CBitStream params;
			params.write_u8( customHitData.hitstunTime );
			params.write_u16( Maths::Max(tumbleTime, currTumbleTime) );	
			params.write_Vec2f( knockbackVec*knockbackSpeed );	
			victimBlob.SendCommand(victimBlob.getCommandID("sync knockback"), params);		
		}

		SSKStatusVars@ hitterStatusVars;
		if (hitterBlob.get("statusVars", @hitterStatusVars))
		{
			hitterStatusVars.hitstunTime = customHitData.hitstunTime;
			hitterStatusVars.isHitstunned = true;
			if (getNet().isServer())
			{
				hitterStatusVars.hitstunTime = customHitData.hitstunTime;
				SyncHitstun(hitterBlob);				
			}
		}

		// kill player if damage exceeds the max
		if (victimStatusVars.damageStatus >= MAX_DAMAGE)
		{
			victimBlob.getSprite().Gib();
			victimBlob.server_Die();
		}
	}

	hitterBlob.server_Hit(victimBlob, hitPos, velocity, damage, customData, teamKill);
}

// keep damage status synced wwith server
void SyncDamageStatus(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	CBitStream bt;
	bt.write_f32( statusVars.damageStatus );

	this.SendCommand(this.getCommandID("sync damage"), bt);
}

void HandleDamageStatus(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	f32 damageStatus = bt.read_f32();

	if (apply)
	{
		statusVars.damageStatus = damageStatus;
	}
}

// grab timer
void SyncGrabEvent(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	CBitStream bt;
	bt.write_u16( statusVars.grabbedTime );

	this.SendCommand(this.getCommandID("sync grab event"), bt);
}

// being dazed
void SyncDazeTime(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	CBitStream bt;
	bt.write_u16( statusVars.dazeTime );	

	this.SendCommand(this.getCommandID("sync daze time"), bt);
}

// tumbling through the air after being hit
void SyncTumbling(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	CBitStream bt;
	bt.write_bool( statusVars.isTumbling );
	bt.write_u16( statusVars.tumbleTime );	

	this.SendCommand(this.getCommandID("sync tumbling"), bt);
}

void HandleTumbling(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	bool isTumbling = bt.read_bool();
	u16 tumbleTime = bt.read_u16();

	if (apply)
	{
		statusVars.isTumbling = isTumbling;
		statusVars.tumbleTime = tumbleTime;
	}

	// play launch sound
	if (isTumbling)
	{
		CSprite@ thisSprite = this.getSprite();
		f32 tumbleVecLen = statusVars.tumbleVec.getLength();
		if ( tumbleVecLen >= 5.0f && tumbleVecLen < 10.0f )
		{
			thisSprite.PlaySound("launch1.ogg", 0.5f);
		}
		else if ( tumbleVecLen >= 10.0f && tumbleVecLen < 15.0f )
		{
			thisSprite.PlaySound("launch2.ogg", 0.5f);
		}
		else if ( tumbleVecLen >= 15.0f && tumbleVecLen < 20.0f )
		{
			thisSprite.PlaySound("launch3.ogg", 0.5f);
		}
		else if ( tumbleVecLen >= 20.0f )
		{
			thisSprite.PlaySound("launch3.ogg");
			thisSprite.PlaySound("homerun1.ogg");
		}
	}
}

// hitstun
void SyncHitstun(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	CBitStream bt;
	bt.write_u8( statusVars.hitstunTime );
	bt.write_bool( statusVars.isHitstunned );

	this.SendCommand(this.getCommandID("sync hitstun"), bt);
}

void HandleHitstun(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	u8 hitstunTime = bt.read_u8();
	bool isHitstunned = bt.read_bool();

	if (apply)
	{
		statusVars.hitstunTime = hitstunTime;
		statusVars.isHitstunned = isHitstunned;

		statusVars.fastFalling = false;
	}
}

void HandleKnockback(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	u8 hitstunTime = bt.read_u8();
	u16 tumbleTime = bt.read_u16();
	Vec2f tumbleVec = bt.read_Vec2f();

	if (apply)
	{
		statusVars.hitstunTime = hitstunTime;
		statusVars.isHitstunned = true;
		statusVars.tumbleTime = tumbleTime;
		statusVars.tumbleVec = tumbleVec;

		statusVars.isTumbling = false;
		statusVars.fastFalling = false;
	}
}

// hitting walls
void HandleBounce(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	u8 hitstunTime = bt.read_u8();
	bool isHitstunned = bt.read_bool();
	Vec2f tumbleVec = bt.read_Vec2f();
	f32 effectAngle = bt.read_f32();

	if (apply)
	{
		statusVars.hitstunTime = hitstunTime;
		statusVars.isHitstunned = isHitstunned;
		statusVars.tumbleVec = tumbleVec;
		statusVars.isTumbling = false;

		statusVars.fastFalling = false;

		// make some craters!!!
		f32 tumbleVecLen = tumbleVec.getLength();
		if (tumbleVecLen >= 15.0f)
			Explode(this, 16.0f, 2.0f);	
		else if (tumbleVecLen >= 12.0f)	
			Explode(this, 16.0f, 1.0f);		

		Vec2f effectOffset = Vec2f(0.0f, -22.0f).RotateBy(effectAngle);
		CParticle@ p = ParticleAnimated("impact1.png", this.getPosition() + effectOffset, Vec2f(0, 0), effectAngle, 1.0f, 2, 0.0f, true);
		if (p !is null)
		{
			p.Z = 1000.0f;
		}

		this.getSprite().PlaySound("slam" + (XORRandom(3)+1) + ".ogg");
	}
}

// tumble and hitstun functions

void DoTumblingUpdate(CBlob@ this)
{
	if (this.hasTag("invincible"))
	{
		
	}

	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	u16 tumbleTime = statusVars.tumbleTime;
	if (!statusVars.isHitstunned && tumbleTime > 0)
	{
		statusVars.tumbleTime--;
		if (tumbleTime < 2)
		{
			if (this.isOnGround())
			{
				this.AddForce(this.getVelocity() * -10.0f);
			}
		}
	}
}

void DoHitstunnedUpdate(CBlob@ this) 
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars))
	{
		return;
	}

	u8 hitstunned = statusVars.hitstunTime;
	if (hitstunned > 0)
	{
		statusVars.hitstunTime--;
		if (hitstunned < 2)
		{
			if (this.isOnGround())
			{
				this.AddForce(this.getVelocity() * -10.0f);
			}
		}
	}
	else if (statusVars.isHitstunned)
	{
		statusVars.isHitstunned = false;
		if (getNet().isServer())
		{
			SyncHitstun(this);
		}
	}
}

void DoGrabUpdate(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	u16 grabbedTime = statusVars.grabbedTime;
	if (this.isAttached())
	{
		if (grabbedTime < MIN_GRABBEDTIME + statusVars.damageStatus*0.5f)
		{
			grabbedTime++;

			statusVars.grabbedTime = grabbedTime;
		}
		else
		{
			this.server_DetachAll();

			statusVars.grabbedTime = 0;
		}
	}
}

void DoDazedUpdate(CBlob@ this)
{
	SSKStatusVars@ statusVars;
	if (!this.get("statusVars", @statusVars)) { return; }

	u16 dazeTime = statusVars.dazeTime;
	if (dazeTime > 0)
	{
		dazeTime--;

		statusVars.dazeTime = dazeTime;
	}
}
