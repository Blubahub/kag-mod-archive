// Princess brain

#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";

const f32 radius = 128.0f;
const f32 maxDistance = 256.00f;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.set_f32("pickup_priority", 16.00f);
	this.getShape().SetRotationsAllowed(false);
	
	this.getCurrentScript().tickFrequency = 1;
	// this.getCurrentScript().runFlags |= Script::tick_not_ininventory | Script::tick_not_attached;
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("fieldgenerator_loop.ogg");
	this.SetEmitSoundVolume(0.0f);
	this.SetEmitSoundSpeed(0.0f);
	
	this.SetEmitSoundPaused(false);
					
	CSpriteLayer@ shield = this.addSpriteLayer("shield", "Shield.png" , 16, 64, this.getBlob().getTeamNum(), 0);

	if (shield !is null)
	{
		Animation@ anim = shield.addAnimation("default", 3, false);
		
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		anim.AddFrame(6);
		anim.AddFrame(7);
		
		shield.SetRelativeZ(-1.0f);
		shield.SetVisible(false);
		shield.setRenderStyle(RenderStyle::outline_front);
		shield.SetIgnoreParentFacing(true);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && GetFuel(this) == 0;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CBlob@ carried = forBlob.getCarriedBlob();
	return (carried is null ? true : carried.getConfig() == "mat_mithril");
}

u8 GetFuel(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) return inv.getItem(0).getQuantity();
	}
	
	return 0;
}

void SetFuel(CBlob@ this, u8 amount)
{
	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) inv.getItem(0).server_SetQuantity(amount);
	}
}

void onTick(CBlob@ this)
{
	u8 fuel = GetFuel(this);
	f32 modifier = f32(fuel) / 250.0f;
	
	this.getSprite().SetEmitSoundVolume(0.20f + modifier * 0.2f);
	this.getSprite().SetEmitSoundSpeed(0.75f + modifier * 0.35f);
	
	// if (fuel == 0) return;
	
	Vec2f pos = this.getPosition();
	// f32 gravity = 0.36; // / 30.00f;
	f32 gravity = 2.00; // / 30.00f;
	// print("" + gravity);
	
	CBlob@[] blobs;
	if (this.getMap().getBlobsInRadius(this.getPosition(), maxDistance, @blobs))
	{
		for (u32 i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (blob !is null && blob !is this)
			{
				Vec2f dir = blob.getPosition() - pos;
				f32 len = dir.getLength();
				
				// print("" + len);
				
				// if (len < 8)
				// {
					// blob.server_Die();
				// }
				
				dir.Normalize();
				
				f32 mod = 1.00f - Maths::Pow((len / maxDistance), 2);//  -x^i+1
				// f32 mod = Maths::Pow(dmod, 4.00f);
				
				// if (mod < 0.02f) continue;
				
				// print("" + mod);
				
				// blob.setVelocity(blob.getVelocity() * (0.50f + mod));
				blob.AddForce(dir * gravity * blob.getMass() * mod);
			}
		}
	}
}