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
		this.server_SetActive(true);
	}
}

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("npc");
	
	this.addCommandID("automat_give");
	this.inventoryButtonPos = Vec2f(0, 16);
	
	// if (getNet().isServer())
	// {
		// this.server_setTeamNum(-1);
	// }
	
	
	this.getCurrentScript().tickFrequency = 30;
	this.getCurrentScript().runFlags |= Script::tick_not_ininventory;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && this.getAttachments().getAttachmentPointByName("PICKUP").getOccupied() == null;
}

void onTick(CBlob@ this)
{
	CBrain@ brain = this.getBrain();
	
	if (getNet().isServer())
	{
		SearchTarget(brain, false, true, true, true);
		CBlob @target = brain.getTarget();
		
		if (target !is null)
		{			
			const f32 distance = (target.getPosition() - this.getPosition()).Length();
			f32 visibleDistance;
			const bool visibleTarget = isVisible(this, target, visibleDistance);
			
			if (visibleTarget && distance < 200.0f && !target.hasTag("dead") && target.getTeamNum() != this.getTeamNum())
			{
				// print("found");
			
				AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
				
				if (point !is null)
				{
					CBlob@ item = point.getOccupied();
				
					if (item !is null)
					{						
						// Vec2f randomness = Vec2f((100 - XORRandom(200)) * 0.1f, (100 - XORRandom(200)) * 0.1f);
						// this.setAimPos(target.getPosition() + randomness);
						this.setAimPos(target.getPosition());
						this.setKeyPressed(key_action1, true);
					}
				}
			
				this.getCurrentScript().tickFrequency = 1;
			}
			else
			{
				brain.SetTarget(null);
				this.getCurrentScript().tickFrequency = 30;
			}
		}
	}
	
	// if (getNet().isClient())
	// {
		// this.getSprite().PlaySound("Automat_Ping.ogg", 0.25f, 1.0f);
	// }
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getTeamNum() == this.getTeamNum();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;
	
	// if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	if ((caller.getPosition() - this.getPosition()).Length() < 24.0f)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this,  this.getCommandID("automat_give"), "Attach Item", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("automat_give"))
	{
		if (getNet().isServer())
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			
			if (caller !is null)
			{
				CBlob@ carried_caller = caller.getCarriedBlob();
				
				if (carried_caller !is null)
				{
					// print("carried: " + carried_caller.getName());
					this.server_Pickup(carried_caller);
					// carried_caller.server_AttachTo(this, "GUN");
				}
				else
				{
					CBlob@ carried_me = this.getCarriedBlob();
					
					if (carried_me !is null)
					{
						carried_me.server_DetachFrom(this);
					}
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
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