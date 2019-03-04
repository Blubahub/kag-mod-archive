// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";

void onInit( CBrain@ this )
{
	if (getNet().isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

void onInit(CBlob@ this)
{
	this.Tag("npc");
	this.Tag("flesh");
	this.Tag("dangerous");
	this.Tag("map_damage_dirt");
	
	this.set_f32("map_damage_ratio", 0.3f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_bool("map_damage_raycast", true);
	
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));
	
	this.set_f32("voice pitch", 0.50f);
	
	this.server_setTeamNum(230);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 0.40f;
		moveVars.jumpFactor *= 0.75f;
	}

	// if (this.getHealth() < 1.0 && !this.hasTag("dead"))
	// {
		// this.Tag("dead");
		// this.getSprite().PlaySound("MithrilGuy_Scream2.ogg", 1.0f, 1.0f);
		
		// // Explode(this, 92.0f, 24.0f);
			
		// // for (int i = 0; i < 6; i++)
		// // {
			// // CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			
			// // if (blob !is null)
			// // {
				// // blob.server_SetQuantity(45 + XORRandom(50));
				// // blob.setVelocity(Vec2f(4 - XORRandom(2), -2 - XORRandom(4)));
			// // }
		// // }
		
		// if (getNet().isServer() && this.getPlayer() !is null) 
		// {
			// this.server_SetPlayer(null);
			// this.server_Die();
		// }
		// // this.getCurrentScript().runFlags |= Script::remove_after_this;
	// }

	if (getNet().isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			this.getSprite().PlaySound("MithrilGuy_Scream_" + XORRandom(5) + ".ogg", 0.7f, 0.5f);
			this.set_u32("next sound", getGameTime() + 350);
		}
	}
	
	if (getNet().isServer())
	{
		if (XORRandom(100) == 0)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(10 + XORRandom(20));
			
			this.server_Hit(this, this.getPosition(), Vec2f(), 0.125f, Hitters::stab, true);
		}
	}
	
	if (XORRandom(8) == 0) 
	{	
		if (getNet().isServer())
		{
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), 96, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if (!blob.hasTag("flesh") || blob.hasTag("dead")) continue;
					
					f32 distMod = Maths::Max(0, (1.00f - ((this.getPosition() - blob.getPosition()).Length() / 64)));
					if (XORRandom(100) < 100.0f * distMod) 
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.25f, HittersTC::radiation, true);
						
						if (blob.hasTag("human") && !blob.hasTag("transformed") && blob.getHealth() <= 0.25f && XORRandom(3) == 0)
						{
							CBlob@ man = server_CreateBlob("mithrilman", blob.getTeamNum(), blob.getPosition());
							if (blob.getPlayer() !is null) man.server_SetPlayer(blob.getPlayer());
							blob.Tag("transformed");
							blob.server_Die();
						}
					}
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	Explode(this, 96.0f, 24.0f);
		
	for (int i = 0; i < 8; i++)
	{
		CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
		
		if (blob !is null)
		{
			blob.server_SetQuantity(10 + XORRandom(40));
			blob.setVelocity(Vec2f(4 - XORRandom(2), -2 - XORRandom(4)));
		}
	}

	// if (getNet().isServer())
	// {
		// CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		// boom.setPosition(this.getPosition());
		// boom.set_u8("boom_start", 0);
		// boom.set_u8("boom_end", 2);
		// boom.set_f32("mithril_amount", 100);
		// boom.set_f32("flash_distance", 32);
		// boom.set_u32("boom_delay", 0);
		// boom.set_u32("flash_delay", 0);
		// boom.Tag("no fallout");
		// boom.Tag("no flash");
		// boom.Init();
	// }
}

void onTick(CBrain@ this)
{
	if (!getNet().isServer()) return;

	CBlob @blob = this.getBlob();
	
	if (blob.getPlayer() !is null) return;
	
	SearchTarget(this, false, true);
	CBlob @target = this.getTarget();
	
	this.getCurrentScript().tickFrequency = 30;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;

		const f32 distance = (target.getPosition() - blob.getPosition()).getLength();
		f32 visibleDistance;
		const bool visibleTarget = isVisible( blob, target, visibleDistance);
		
		if (target.hasTag("dead") || distance > 200.0f) 
		{
			CPlayer@ targetPlayer = target.getPlayer();
			
			this.SetTarget(null);
			return;
		}
		else if (target.isOnGround())
		{
			DefaultChaseBlob(blob, target);
		}
		
		LoseTarget(this, target);
	}
	else
	{
		if (XORRandom(100) < 50) RandomTurn(blob);		
	}

	FloatInWater(blob); 
} 

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::radiation:
			return 0;
			break;
		
		// Kill it with fire
		case Hitters::fire:
		case Hitters::burn:
			damage *= 4.00f;
			break;			
	}

	if (getNet().isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 25)
		{
			this.getSprite().PlaySound("MithrilGuy_Scream_" + (1 + XORRandom(2)) + ".ogg", 1, 0.8f);
			this.set_u32("next sound", getGameTime() + 300);
		}
	}
	
	if (getNet().isServer())
	{
		CBrain@ brain = this.getBrain();
		
		if (brain !is null && hitterBlob !is null)
		{
			if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
		}
	}
		
	return damage;
}