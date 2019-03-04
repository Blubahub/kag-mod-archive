// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";

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
	this.set_f32("gib health", 0.0f);
	this.set_u32("nextAttack", 0);
	this.set_u32("nextAttackReal", 0);
	this.set_u32("nextBomb", 0);
	this.set_u8("reactionTime",20);
	this.set_u8("attackDelay", 0);

	this.Tag("can open door");
	this.Tag("combat chicken");
	this.Tag("npc");
	this.Tag("flesh");
	
	// this.getCurrentScript().removeIfTag = "dead";
	
	if (getNet().isServer())
	{
		this.set_u16("stolen coins", 250);
	
		this.server_setTeamNum(-1);
			
		string gun_config;
		string ammo_config;
		
		switch(XORRandom(11))
		{
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
				gun_config = "revolver";
				ammo_config = "mat_pistolammo";
				this.set_u8("attackDelay", 5);
				break;
			
			case 5:
			case 6:
				gun_config = "rifle";
				ammo_config = "mat_rifleammo";
				this.set_u8("attackDelay", 30);
				break;
			
			case 7:
			case 8:
				gun_config = "shotgun";
				ammo_config = "mat_shotgunammo";
				this.set_u8("attackDelay", 30);
				break;
			
			case 10:
				gun_config = "bazooka";
				ammo_config = "mat_smallrocket";
				this.set_u8("attackDelay", 100);
				break;
				
			default:
				gun_config = "revolver";
				ammo_config = "mat_pistolammo";
				this.set_u8("attackDelay", 5);
				break;
		}
		
		for (int i = 0; i < 4; i++)
		{
			CBlob@ ammo = server_CreateBlob(ammo_config, this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(ammo);
		}
		
		CBlob@ gun = server_CreateBlob(gun_config, this.getTeamNum(), this.getPosition());
		this.server_Pickup(gun);
		
		CBitStream stream;
		gun.SendCommand(gun.getCommandID("cmd_gunReload"), stream);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	if (this.getHealth() < 3.0 && !this.hasTag("dead"))
	{
		this.Tag("dead");
		this.getSprite().PlaySound("Wilhelm.ogg", 1.8f, 1.8f);
		
		if (getNet().isServer())
		{
			server_DropCoins(this.getPosition(), Maths::Max(0, Maths::Min(this.get_u16("stolen coins"), 5000)));
			CBlob@ carried = this.getCarriedBlob();
			
			if (carried !is null)
			{
				carried.server_DetachFrom(this);
			}
			
			if (XORRandom(100) < 5) server_CreateBlob("phone", -1, this.getPosition());
		}
		
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}

	if (getNet().isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			// this.getSprite().PlaySound("scoutchicken_vo_perish.ogg", 0.8f, 1.5f);
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
}

void onTick( CBrain@ this )
{
	if (!getNet().isServer()) return;

	CBlob @blob = this.getBlob();
	
	if (blob.getPlayer() !is null) return;
	
	SearchTarget(this, false, true);
	CBlob @target = this.getTarget();
	
	this.getCurrentScript().tickFrequency = 1;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;

		const f32 distance = (target.getPosition() - blob.getPosition()).getLength();
		f32 visibleDistance;
		const bool visibleTarget = isVisible( blob, target, visibleDistance);
		
		if (target.hasTag("dead") || distance > 400.0f) 
		{
			CPlayer@ targetPlayer = target.getPlayer();
			
			if (targetPlayer !is null)
			{
				if (target.hasTag("dead")){
					blob.set_u16("stolen coins", blob.get_u16("stolen coins") + (targetPlayer.getCoins() * 0.9f));
				}
			}
		
			if (target.hasTag("dead")){
				blob.getSprite().PlaySound("scoutchicken_vo_victory.ogg");
			}
			this.SetTarget(null);
			return;
		}
		else if (visibleTarget && visibleDistance < 25.0f) 
		{
			DefaultRetreatBlob( blob, target );
		}	
		else if (target.isOnGround())
		{
			DefaultChaseBlob(blob, target);
		}

		if(visibleTarget && distance < 350.0f)
		{
			if(blob.get_u32("nextAttack")<getGameTime())
			{
				AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
				if(point !is null) {
					CBlob@ gun = point.getOccupied();
					if(gun !is null) {
						u32 nextAttackReal=blob.get_u32("nextAttackReal");
						if(nextAttackReal==-1){
							Vec2f randomness = Vec2f((100 - XORRandom(200)) * 0.1f, (100 - XORRandom(200)) * 0.1f);
							blob.setAimPos(target.getPosition()+randomness);
							blob.set_u32("nextAttackReal",getGameTime()+blob.get_u8("reactionTime"));
						}else if(nextAttackReal<getGameTime()){
							blob.setKeyPressed(key_action1,true);
							blob.set_u32("nextAttack",getGameTime()+blob.get_u8("attackDelay"));
							blob.set_u32("nextAttackReal",-1);
						}
					}
				}
			}
			// else if (blob.get_u32("nextBomb") < getGameTime())
			// {
				// if (XORRandom(100) < 2)
				// {
					// CBlob@ bomb = server_CreateBlob("bomb", blob.getTeamNum(), blob.getPosition());
					// if (bomb !is null)
					// {
						// Vec2f dir = blob.getAimPos() - blob.getPosition();
						// f32 dist = dir.Length();
						
						// dir.Normalize();
						
						// bomb.setVelocity((dir * (dist * 0.1f)) + Vec2f(0, -5));
						// blob.set_u32("nextBomb", getGameTime() + 600);
					// }
				// }
			// }
		}
		
		LoseTarget(this, target);
	}
	else
	{
		if (XORRandom(100) < 50) RandomTurn(blob);		
	}

	FloatInWater( blob ); 
} 

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (getNet().isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("scoutchicken_vo_hit" + (1 + XORRandom(3)) + ".ogg");
			this.set_u32("next sound", getGameTime() + 60);
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