#include "ElementalControl.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
	
	this.set_u16("timer",0);
	this.set_u16("super_timer",300);
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 220, 151));
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onTick(CBlob@ this)
{

	if(this.isInWater()){
		if(getNet().isServer()){
			CBlob @staff = server_CreateBlob("staff", this.getTeamNum(), this.getPosition());
			staff.set_u8("staffbase",this.get_u8("staffbase"));
			this.server_Die();
			return;
		}
		if(getNet().isClient()){
			this.getSprite().PlaySound("Steam.ogg");
			
			makeSteamParticle(this, Vec2f(), "MediumSteam");
			for (int i = 0; i < 10; i++)
			{
				f32 randomness = (XORRandom(32) + 32) * 0.015625f * 0.5f + 0.75f;
				Vec2f vel = getRandomVelocity(-90, randomness, 360.0f);
				makeSteamParticle(this, vel);
			}
		}
	}

	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder is null){
			@point = this.getAttachments().getAttachmentPointByName("STAFF");
			@holder = point.getOccupied();
			AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("STAFF");
			if (ap !is null)
			{
				ap.SetKeysToTake(key_action1 | key_action3);
			}
		}
		
		if (holder is null) return;

		this.getSprite().SetOffset(Vec2f(7,1));
		
		this.getShape().SetRotationsAllowed(false);

		if (holder.get_u8("knocked") <= 0)
		{
			if(this.get_u16("timer") < 15)this.set_u16("timer",this.get_u16("timer")+1);
			else
			if(point.isKeyPressed(key_action1))if(getNet().isServer()){
				CBlob @blob = server_CreateBlob("firebloodbolt", holder.getTeamNum(), this.getPosition());
				if (blob !is null)
				{
					Vec2f shootVel = holder.getAimPos()-this.getPosition();
					shootVel.Normalize();
					blob.setVelocity(shootVel*8);
					blob.SetDamageOwnerPlayer(holder.getPlayer());
				}
				this.set_u16("timer",0);
			}
			
			if(point.isKeyPressed(key_action2)){
				ControlElements(this.get_f32("power"),holder.getAimPos(),true,false,false,false,true,false,false,false,false,false,false);
			}
			
			if(this.get_u16("super_timer") < 300)this.set_u16("super_timer",this.get_u16("super_timer")+1);
			else
			if(point.isKeyPressed(key_action3)){
				if (getNet().isServer()){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b.hasTag("dead"))
							{
								for(uint j = 0; j < 5; j += 1)server_CreateBlob("heart", -1, b.getPosition()+Vec2f(XORRandom(10)-5,0));
								this.server_Hit(b, b.getPosition(), Vec2f(0,0), 10.0f, Hitters::suddengib, false);
								CBlob @blob = server_CreateBlob("fire_blob", holder.getTeamNum(), Vec2f(b.getPosition().x,0));
								if (blob !is null)
								{
									blob.setVelocity(Vec2f(0,50));
									blob.SetDamageOwnerPlayer(holder.getPlayer());
									blob.set_u16("size", 150);
								}
							}
						}
					}
				}
				this.set_u16("super_timer",0);
			}
		}
	}
	else
	{
		this.getSprite().SetOffset(Vec2f(0,0));
		this.getShape().SetRotationsAllowed(true);
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}