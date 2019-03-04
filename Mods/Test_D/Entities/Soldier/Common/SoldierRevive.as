#include "SoldierCommon.as"
#include "GameColours.as"
#include "HoverMessage.as"

// synced!
void Revive(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);

	// REVIVE
	if (this.hasTag("dead"))
	{
		AddTopShape(this);
		this.Untag("dead");

		//AddMessage(this, "REVIVED!");
		this.getSprite().PlaySound("/Heal");
		this.getSprite().PlayRandomSound("MedkitRevive", 1.0f, data.pitch);	

		// stun a bit
		data.stunTime = 30;
	}
	else
	{
		//AddMessage(this, "HEALED!");	
	}

	this.server_SetHealth(this.getInitialHealth());
	this.getShape().getConsts().radius = 3.5f; // engine bug fix
	data.dead = false;
	data.healTime = 0;

	if (getNet().isServer())
	{
		this.SendCommand(Soldier::Commands::REVIVE);
	}
}

void AddTopShape(CBlob@ this)
{
	const f32 radius = 3.5f;
	const f32 radius2 = radius * 0.71f;
	{
		Vec2f[] shape = { Vec2f(-radius2, -8.0f),
		                  Vec2f(0,  -11.0f),
		                  Vec2f(radius2,  -8.0f),
		                  Vec2f(radius2,  -3.0f),
		                  Vec2f(-radius2, -3.0f)
		                };
		this.getShape().AddShape(shape);
	}
}
