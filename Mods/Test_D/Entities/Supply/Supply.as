#include "SoldierCommon.as"
#include "SoldierRevive.as"
#include "HoverMessage.as"
#include "GameColours.as"
#include "Sparks.as"
#include "ExplosionParticles.as"
#include "Explosion.as"

namespace Supply
{
	enum type
	{
		AMMO = 0,
		MEDKIT,
		AMMO_MEDKIT,
		COUNT
	}
}

const f32 BLAST_RADIUS = 45.0f;
const f32 DAMAGE = 4.0f;

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(10.0f);
	const int type = this.get_u8("supply type");
	if (type == Supply::AMMO_MEDKIT)
	{
		sprite.SetFrameIndex(0);
	}
	else
	{
		sprite.SetFrameIndex((type + 1) % Supply::COUNT);
	}
	this.addCommandID("supply explode");
	this.addCommandID("supply revive");
}

void Explode(CBlob@ this)
{
	this.Tag("explosive");
	this.getSprite().PlaySound("DetonateBomb");
	this.setVelocity(Vec2f(0.0f, -4.0f));
	this.getShape().SetGravityScale(0.5f);
	this.server_SetTimeToDie(1.0f);
}

const bool allow_denies = true;

void Supply(CBlob@ this, CBlob@ blob)
{
	if (blob is null)
		return;

	const u8 type = this.get_u8("supply type");
	Soldier::Data@ data = Soldier::getData(blob);

	bool die = allow_denies && (this.getDamageOwnerPlayer() !is blob.getPlayer());
	string sound = "";
	string[] messages;

	bool healed = false;
	if (type == Supply::MEDKIT || type == Supply::AMMO_MEDKIT)
	{
		if (blob.getHealth() < blob.getInitialHealth())
		{
			messages.push_back("+health");
			if (data.dead)
			{
				sound = "MedkitRevive";
				data.dead = false;
			}
			else
			{
				sound = "MedkitHeal";
			}
			Revive(blob);
			die = true;
			healed = true;
		}

		if (messages.empty() && die)
		{
			messages.push_back("+medkit");
		}
	}

	//warning: the crate stuff checks this hardcoded name
	const string crate_prop = "crate count";
	if (type == Supply::AMMO || type == Supply::AMMO_MEDKIT)
	{
		if (data.grenades < data.initialGrenades || data.ammo < data.initialAmmo || data.bombs < data.initialBombs
		        || blob.exists(crate_prop) && blob.get_u8(crate_prop) < 8)
		{
			int nades = data.initialGrenades - data.grenades;
			int ammo = data.initialAmmo - data.ammo;
			int bombs = data.initialBombs - data.bombs;
			bool playsound = false;
			if (nades > 0 && data.secondaryName != "")
			{
				messages.push_back("+" + data.secondaryName);
				playsound = true;
			}
			if (ammo > 0 && data.primaryName != "")
			{
				messages.push_back("+" + data.primaryName);
				playsound = true;
			}
			if (bombs > 0 && data.primaryName != "")
			{
				messages.push_back("+" + data.primaryName);
				playsound = true;
			}
			//hack - engie crate ammo
			if (blob.exists(crate_prop))
			{
				int crates = 8 - blob.get_u8(crate_prop);
				if (crates > 0)
				{
					messages.push_back("+crates");
					blob.set_u8(crate_prop, 8);
					playsound = true;
				}
			}

			data.grenades = data.initialGrenades;
			data.ammo = data.initialAmmo;
			data.bombs = data.initialBombs;

			if (playsound)
			{
				sound = "PickupAmmo";
			}

			die = true;
		}

		if (messages.empty() && die)
		{
			messages.push_back("+ammo box");
		}
	}

	while (!messages.empty())
	{
		AddMessageAbove(blob, messages[messages.length - 1]);
		messages.pop_back();
	}

	if (die)
	{
		this.getSprite().PlayRandomSound("PickupAmmo");
		if (sound != "")
		{
			this.getSprite().PlayRandomSound(sound, 1.0f, data.pitch);
		}

		this.server_Die();
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("supply explode"))
	{
		Explode(this);
	}
	else if (cmd == this.getCommandID("supply revive"))
	{
		Supply(this, getBlobByNetworkID(params.read_netid()));
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (getNet().isServer() && blob !is null && blob.getName() == "soldier")
	{
		if (this.getTeamNum() != blob.getTeamNum() && this.hasTag("booby trapped") && !this.hasTag("explosive"))
		{
			// explode
			CBitStream params;
			this.SendCommand(this.getCommandID("supply explode"), params);
		}
		else
		{
			// revive
			CBitStream params;
			params.write_netid(blob.getNetworkID());
			this.SendCommand(this.getCommandID("supply revive"), params);
		}
	}
}

void onDie(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	Particles::Sparks(pos, 16, 16.0f, SColor(Colours::WHITE));
	Particles::Sparks(pos, 12, 8.0f, SColor(Colours::BLUE));
	Particles::Sparks(pos, 12, 8.0f, SColor(Colours::YELLOW));
}
