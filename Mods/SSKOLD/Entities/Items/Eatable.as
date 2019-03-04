
#include "SSKStatusCommon.as"

const string heal_id = "heal command";

void onInit(CBlob@ this)
{
	if (!this.exists("eat sound"))
	{
		this.set_string("eat sound", "/Eat.ogg");
	}

	this.addCommandID(heal_id);
}

void Heal(CBlob@ this, CBlob@ blob)
{
	bool exists = getBlobByNetworkID(this.getNetworkID()) !is null;

	SSKStatusVars@ statusVars;
	if (!blob.get("statusVars", @statusVars))
	{
		return;
	}

	if (getNet().isServer() && blob.hasTag("player") && statusVars.damageStatus > 0.0f && !this.hasTag("healed") && exists)
	{
		CBitStream params;
		params.write_u16(blob.getNetworkID());

		u8 heal_amount = 20; //in quarter hearts, 255 means full hp

		if (this.getName() == "heart")	    // HACK
		{
			heal_amount = 15;
		}
		else if (this.getName() == "food")
		{
			heal_amount = 30;
		}
		else if (this.getName() == "steak")
		{
			heal_amount = 60;
		}

		params.write_u8(heal_amount);

		this.SendCommand(this.getCommandID(heal_id), params);

		this.Tag("healed");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID(heal_id))
	{
		this.getSprite().PlaySound(this.get_string("eat sound"));
		this.getSprite().PlaySound("heal1.ogg");

		makeSparks(this.getPosition(), 20);

		if (getNet().isServer())
		{
			u16 blob_id;
			if (!params.saferead_u16(blob_id)) return;

			CBlob@ theBlob = getBlobByNetworkID(blob_id);
			if (theBlob !is null)
			{
				u8 heal_amount;
				if (!params.saferead_u8(heal_amount)) return;

				if (heal_amount == 255)
				{
					theBlob.server_SetHealth(theBlob.getInitialHealth());
				}
				else
				{
					theBlob.server_Heal(f32(heal_amount) * 0.25f);
				}


				SSKStatusVars@ statusVars;
				if (theBlob.get("statusVars", @statusVars))
				{
					statusVars.damageStatus = Maths::Max(statusVars.damageStatus - heal_amount, 0.0f);
					SyncDamageStatus(theBlob);
				}
			}

			this.server_Die();
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	if (getNet().isServer() && !blob.hasTag("dead"))
	{
		Heal(this, blob);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (getNet().isServer())
	{
		Heal(this, attached);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	if (getNet().isServer())
	{
		Heal(this, detached);
	}
}

Random _sprk_r();
void makeSparks(Vec2f pos, int amount)
{
	if ( !getNet().isClient() )
		return;
		
	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 1.5f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        CParticle@ p = ParticlePixel( pos, vel, SColor( 100+_sprk_r.NextRanged(155), 100+_sprk_r.NextRanged(100), 255, 100+_sprk_r.NextRanged(100)), true );
        if(p is null) return; //bail if we stop getting particles
		
		p.gravity = Vec2f(0.0f,-0.08f);
        p.timeout = 20 + _sprk_r.NextRanged(20);
        p.scale = 1.0f + _sprk_r.NextFloat();
        p.damping = 0.90f;
    }
}