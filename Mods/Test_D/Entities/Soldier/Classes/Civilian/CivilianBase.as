#include "SoldierCommon.as"
#include "SoldierCrosshair.as"
#include "Skins.as"
//TODO: maybe put this somewhere more sensible? :/
#include "BackendCommon.as"

float MAX_THROW = 8.0f;
float USE_DISTANCE = 30.0f;

int _useLock = 0;

void onInit(CBlob@ this)
{
	//this.getCurrentScript().runFlags |= Script::tick_ininventory | Script::tick_not_ininventory;
}

void onTick(CBlob@ this)
{
	Soldier::Data@ data = Soldier::getData(this);

	//hack
	data.lockCrouch = 0;

	if (data.dead)
		return;

	// get out of truck
	if (data.attached && getNet().isServer())
	{
		CBlob@ truck = this.getAttachments().getAttachedBlob("PASSENGER");
		if (this.isKeyPressed(key_action2) && truck !is null
		        && !truck.hasTag("riding away")
		        && truck.get_u8("leave_secs") > 3
		   )
		{
			this.server_DetachFromAll();
		}
	}

	// ball

	CBlob@ ball = this.getCarriedBlob();
	if (ball !is null)
	{
		if (data.local)
		{
			if (this.isKeyJustPressed(key_action2))
			{
				f32 drop_speed = 1.5f;
				Vec2f vel = data.vel * 1.5f + Vec2f(data.facingLeft ? -0.5f : 0.5f, -1.0f) * drop_speed;
				Throw(this, ball, vel);
			}
			else if (!data.crosshair && this.isKeyPressed(key_action1) && ball.hasTag("throwable"))
			{
				Soldier::StartCrosshair(this, data);
			}
			else if (data.crosshair)
			{
				if (this.isKeyJustPressed(key_action1) || (data.crosshairTime >= data.crosshairMinTime && this.isKeyJustReleased(key_action1)))
				{
					Vec2f vel = data.crosshairOffset * 0.1f;
					f32 len = vel.Normalize();
					vel *= Maths::Min(len, Soldier::maxThrow) * ball.get_f32("throw_modifier");
					Throw(this, ball, vel);
				}
			}
		}
	}
	else
	{
		Soldier::EndCrosshair(this, data);
	}

	Soldier::TickCrosshair(this, data);

	if (data.local && _useLock == 0 && ball is null)
	{
		// use

		if (this.isKeyJustPressed(key_action1))
		{
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), USE_DISTANCE, @blobsInRadius))
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					if (b !is this && this.getDistanceTo(b) < b.getRadius() && b.hasCommandID("use"))
					{
						Use(this, b);
						break;
					}
				}
			}
		}
	}

	if (this.hasTag("smoking") && this.isMyPlayer())
	{
		//cig expired?
		if (this.exists("smoke_end_time") && this.get_u32("smoke_end_time") <= getGameTime())
		{
			this.Untag("smoking");

			CBitStream params;
			params.write_bool(false);
			this.SendCommand(Soldier::Commands::CIVILIAN_CIGAR, params);
		}
	}

	// use lock
	if (data.local)
	{
		if (getRules().get_s16("in menu") == 0)
		{
			_useLock = 0;
		}
		else
		{
			_useLock = 1;
		}
	}
}


void Throw(CBlob@ this, CBlob@ ball, Vec2f vel)
{
	CBitStream params;
	params.write_netid(ball.getNetworkID());
	params.write_Vec2f(ball.getPosition());
	params.write_Vec2f(vel);
	this.SendCommand(Soldier::Commands::THROWBALL, params);
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	Soldier::Data@ data = Soldier::getData(this);

	if (cmd == Soldier::Commands::THROWBALL)
	{
		CBlob@ ball = getBlobByNetworkID(params.read_netid());
		Vec2f pos = params.read_Vec2f();
		Vec2f velocity = params.read_Vec2f();

		if (getNet().isServer())
		{
			ball.server_DetachFromAll();
		}

		ball.setPosition(pos);
		ball.setVelocity(velocity);
		ball.SetDamageOwnerPlayer( this.getPlayer() );
	}
	else if (cmd == Soldier::Commands::CIVILIAN_CIGAR)
	{
		bool disable = !params.read_bool();
		if (disable)
		{
			this.Untag("smoking");
			this.getSprite().PlayRandomSound("Cough");
		}
		else
		{
			this.Tag("smoking");
			this.set_u32("smoke_end_time", getGameTime() + 30 * 30); //30s smoke time
			this.getSprite().PlaySound("LightCigarette");
		}
	}
	else if (cmd == Soldier::Commands::CIVILIAN_DRINK)
	{
		bool wine = params.read_bool();
		if(wine)
		{
			this.set_u8("drink_contents", 1);
		}
		else
		{
			this.set_u8("drink_contents", 0);
		}
		this.Tag("drinking");
		this.getSprite().PlayRandomSound("Gulp");

		u8 drunk_amount = 0;
		if(this.exists("drunk_amount"))
		{
			drunk_amount = this.get_u8("drunk_amount");
		}
		drunk_amount = Maths::Min(20, drunk_amount + 1);
		this.set_u8("drunk_amount", drunk_amount);

		if(getNet().isServer() && getRules().hasTag("use_backend"))
		{
			Backend::SetPlayerDrunk(this.getPlayer(), drunk_amount);
		}
	}
	else if (cmd == Soldier::Commands::CIVILIAN_COFFEE)
	{
		this.set_u8("drink_contents", 2);
		this.Tag("drinking");
		this.getSprite().PlayRandomSound("Gulp");

		s32 drunk_amount = 0;
		if(this.exists("drunk_amount"))
		{
			drunk_amount = this.get_u8("drunk_amount");
		}
		drunk_amount = Maths::Max(0, drunk_amount * 0.5f);
		this.set_u8("drunk_amount", drunk_amount);

		if(getNet().isServer() && getRules().hasTag("use_backend"))
		{
			Backend::SetPlayerDrunk(this.getPlayer(), drunk_amount);
		}
	}
	else if (cmd == Soldier::Commands::CIVILIAN_LOADSKIN)
	{
		this.set_u8("skin", params.read_u8());
		LoadSkin(this.getSprite());
	}
}

void Use(CBlob@ this, CBlob@ other)
{
	CBitStream params;
	params.write_netid(this.getNetworkID());
	other.SendCommand(other.getCommandID("use"), params);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	this.getSprite().PlaySound("Pickup");
}
