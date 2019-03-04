#include "ElementalControl.as";
#include "ChangeClass.as";

void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
	
	this.set_u16("timer",15);
	this.set_u16("super_timer",0);
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
			if(this.get_u16("timer") < 15)this.set_u16("timer",this.get_u16("timer")+1);
			else
			if(point.isKeyPressed(key_action1)){
				CPlayer@ player = getPlayerByUsername(this.get_string("ghost"));
				if(player !is null){
					CBlob@ playerblob = player.getBlob();
					if(playerblob !is null){
						playerblob.setPosition(holder.getAimPos());
					}
				}
				this.set_u16("timer",0);
			}

			if(point.isKeyPressed(key_action2)){
				for(uint i = 0; i < 10; i += 1)ControlElements(this.get_f32("power"),holder.getAimPos(),false,false,false,false,false,false,false,true,false,false,false);
			}
			
			if(this.get_u16("super_timer") < 30*60)this.set_u16("super_timer",this.get_u16("super_timer")+1);
			else
			if(point.isKeyPressed(key_action3)){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getName() == "ghost")
						{
							ChangeClass(b,"wraithknight",b.getPosition(),holder.getTeamNum());
							break;
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
	
	CPlayer@ player = getPlayerByUsername(this.get_string("ghost"));
	if(player !is null){
		CBlob@ playerblob = player.getBlob();
		if(playerblob !is null){
			if(!playerblob.hasTag("ghost")){
				playerblob.setPosition(this.getPosition());
				playerblob.server_Die();
			} else {
				playerblob.set_s16("invisible",0);
			}
		}
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}