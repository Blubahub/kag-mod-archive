// Bed

#include "Help.as"
#include "RunnerHead.as";
#include "Health.as";

const f32 heal_ammount = 0.25f;
const u8 heal_rate = 30;
const f32 over_heal_ammount = 2.0f;

void onInit( CBlob@ this )
{		 	
	this.getShape().getConsts().mapCollisions = false;	
	
	this.Tag("dead head");
	
	this.Tag("building");
	
	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null)
	{
		bed.SetKeysToTake(key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3 | key_pickup | key_inventory);
		bed.SetMouseTaken(true);
	}
	
	this.addCommandID("rest");
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
	
	this.Tag("builder always hit");
}

void onTick( CBlob@ this )
{
	if (XORRandom(14) == 0 && this.get_u8("migrants count") > 0) {
		this.getSprite().PlaySound("/MigrantSleep");
	}
	
	bool isServer = getNet().isServer();
	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null)
	{
		CBlob@ patient = bed.getOccupied();
		if (patient !is null)
		{
			if (bed.isKeyJustPressed(key_up))
			{
				if (isServer)
				{
					patient.server_DetachFrom(this);
				}
			}
			else if (getGameTime() % heal_rate == 0)
			{
				if (requiresTreatment(patient))
				{
					if (patient.isMyPlayer())
					{
						Sound::Play("Heart.ogg", patient.getPosition());
					}
					if (isServer)
					{
						OverHeal(patient,heal_ammount);
					}
				}
				else
				{
					if (isServer)
					{
						patient.server_DetachFrom(this);
					}
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// TODO: fix GetButtonsFor Overlapping, when detached this.isOverlapping(caller) returns false until you leave collision box and re-enter
	Vec2f tl, br, c_tl, c_br;
	this.getShape().getBoundingRect(tl, br);
	caller.getShape().getBoundingRect(c_tl, c_br);
	bool isOverlapping = br.x - c_tl.x > 0.0f && br.y - c_tl.y > 0.0f && tl.x - c_br.x < 0.0f && tl.y - c_br.y < 0.0f;

	AddIconToken("$rest$", "InteractionIcons.png", Vec2f(32, 32), 29);
	
	if(isOverlapping && bedAvailable(this) && requiresTreatment(caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$rest$", Vec2f(0, 0), this, this.getCommandID("rest"), "Rest", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = (getNet().isServer());
	if (cmd == this.getCommandID("rest"))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller !is null)
		{
			AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
			if (bed !is null && bedAvailable(this))
			{
				CBlob@ carried = caller.getCarriedBlob();
				if (isServer)
				{
					if (carried !is null)
					{
						if (!caller.server_PutInInventory(carried))
						{
							carried.server_DetachFrom(caller);
						}
					}
					this.server_AttachTo(caller, "BED");
				}
			}
		}
	}
}

const string default_head_path = "Entities/Characters/Sprites/Heads.png";

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	attached.getShape().getConsts().collidable = false;
	attached.SetFacingLeft(true);
	attached.AddScript("WakeOnHit.as");

	string texName = default_head_path;
	CSprite@ attached_sprite = attached.getSprite();
	if (attached_sprite !is null && getNet().isClient())
	{
		attached_sprite.SetVisible(false);
		attached_sprite.PlaySound("GetInVehicle.ogg");
		CSpriteLayer@ head = attached_sprite.getSpriteLayer("head");
		if (head !is null)
		{
			texName = head.getFilename();
		}
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		updateLayer(sprite, "zzz", 0, true, false);

		sprite.SetEmitSoundPaused(false);
		sprite.RewindEmitSound();

		if (getNet().isClient())
		{
			CSpriteLayer@ bed_head = sprite.addSpriteLayer("bed head", texName, 16, 16, attached.getTeamNum(), attached.getSkinNum());
			if (bed_head !is null)
			{
				Animation@ anim = bed_head.addAnimation("default", 0, false);

				if (texName == default_head_path)
				{
					anim.AddFrame(getHeadFrame(attached, attached.getHeadNum()) + 2);
				}
				else
				{
					anim.AddFrame(2);
				}

				bed_head.SetAnimation(anim);
				bed_head.SetFacingLeft(true);
				bed_head.RotateBy(80, Vec2f_zero);
				bed_head.SetRelativeZ(2);
				bed_head.SetOffset(Vec2f(8, -2));
				bed_head.SetVisible(true);
			}
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	detached.getShape().getConsts().collidable = true;
	detached.AddForce(Vec2f(0, -20));
	detached.RemoveScript("WakeOnHit.as");

	CSprite@ detached_sprite = detached.getSprite();
	if (detached_sprite !is null)
	{
		detached_sprite.SetVisible(true);
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		updateLayer(sprite, "bed", 0, true, false);
		updateLayer(sprite, "zzz", 0, false, false);
		updateLayer(sprite, "bed head", 0, false, true);
		updateLayer(sprite, "backpack", 0, false, false);

		sprite.SetEmitSoundPaused(true);
	}
}

void updateLayer(CSprite@ sprite, string name, int index, bool visible, bool remove)
{
	if (sprite !is null)
	{
		CSpriteLayer@ layer = sprite.getSpriteLayer(name);
		if (layer !is null)
		{
			if (remove == true)
			{
				sprite.RemoveSpriteLayer(name);
				return;
			}
			else
			{
				layer.SetFrameIndex(index);
				layer.SetVisible(visible);
			}
		}
	}
}

bool bedAvailable(CBlob@ this)
{
	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null)
	{
		CBlob@ patient = bed.getOccupied();
		if (patient !is null)
		{
			return false;
		}
	}
	return true;
}

bool requiresTreatment(CBlob@ caller)
{
	return Health(caller) < MaxHealth(caller)+over_heal_ammount;
}

																																												
// SPRITE

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background
	this.SetFrame(0);

	CSpriteLayer@ zzz = this.addSpriteLayer( "zzz", 8,8 );		 
	if (zzz !is null)
	{
		zzz.addAnimation("default",3,true);
		int[] frames = {7,14,15};
		zzz.animation.AddFrames(frames);
		zzz.SetOffset(Vec2f(-7 * (this.getBlob().isFacingLeft() ? -1.0f : 1.0f),-7));
		zzz.SetVisible( false );
		zzz.SetLighting( false );
		zzz.SetHUD( true );
	}
}
