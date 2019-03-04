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
			if(point.isKeyPressed(key_action1)){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && b.getTeamNum() == holder.getTeamNum())
						{
							b.set_s16("water_bubble",20);
							b.set_s16("nature_regen",4);
							b.set_s16("golden_shield",20);
						}
					}
				}
			}
			
			if(point.isKeyPressed(key_action2)){
				ControlElements(this.get_f32("power"),holder.getAimPos(),false,true,true,false,false,true,true,false,false,false,false);
			}
			
			if(this.get_u16("super_timer") < 300)this.set_u16("super_timer",this.get_u16("super_timer")+1);
			else
			if(point.isKeyPressed(key_action3)){
				for(uint i = 0; i < 10; i += 1){
					if(getNet().isServer()){
						CBlob @blob = server_CreateBlob("water_blob", holder.getTeamNum(), Vec2f(holder.getAimPos().x-40+i*8,0));
						if (blob !is null)
						{
							blob.setVelocity(Vec2f(0,XORRandom(5)));
							blob.SetDamageOwnerPlayer(holder.getPlayer());
							blob.set_u8("launch team", holder.getTeamNum());
						}
					}
				}
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(holder.getAimPos(), 64.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if((b.hasTag("flesh") || b.hasTag("plant")) && b.getTeamNum() == holder.getTeamNum())
						{
							b.set_s16("nature_regen",24);
							b.set_s16("golden_shield",150);
							b.set_s16("water_bubble",150);
						}
						if(b.get_s16("life") > 0 && b.getTeamNum() != holder.getTeamNum())
						{
							holder.set_s16("life",holder.get_s16("life")+b.get_s16("life"));
							b.set_s16("death",b.get_s16("life"));
							b.set_s16("life",0);
							this.server_Hit(b, b.getPosition(), Vec2f(0,0), 1.0f, Hitters::suddengib, false);
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