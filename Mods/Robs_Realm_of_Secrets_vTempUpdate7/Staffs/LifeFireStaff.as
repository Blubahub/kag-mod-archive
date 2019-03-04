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
	this.SetLightColor(SColor(11, 213, 255, 171));
	this.SetLightRadius(16.0f);
}

void onTick(CBlob@ this)
{

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
			if(this.get_u16("timer") < 30)this.set_u16("timer",this.get_u16("timer")+1);
			else
			if(point.isKeyPressed(key_action1))if(getNet().isServer()){
				CBlob @blob = server_CreateBlob("lifebolt", holder.getTeamNum(), this.getPosition());
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
				ControlElements(this.get_f32("power"),holder.getAimPos(),true,false,false,false,false,false,true,false,false,false,false);
			}
			
			if(this.get_u16("super_timer") < 600)this.set_u16("super_timer",this.get_u16("super_timer")+1);
			else
			if(point.isKeyPressed(key_action3)){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b !is holder && b.get_s16("life") > 0 && b.getTeamNum() != holder.getTeamNum())
						{
							int Amount = Maths::Min(b.get_s16("life"),5);
							holder.set_s16("life",holder.get_s16("life")+Amount);
							holder.set_s16("death",holder.get_s16("death")-Amount);
							if(holder.get_s16("death") < 0)holder.set_s16("death",0);
							b.set_s16("death",b.get_s16("death")+Amount);
							b.set_s16("life",b.get_s16("life")-Amount);
							this.server_Hit(b, b.getPosition(), Vec2f(0,0), 0.5f, Hitters::suddengib, false);
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

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue
}