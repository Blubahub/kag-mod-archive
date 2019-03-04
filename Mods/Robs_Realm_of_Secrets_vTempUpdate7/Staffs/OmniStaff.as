#include "ElementalControl.as";
#include "Hitters.as";
#include "ChangeClass.as";

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
						if(b.hasTag("player") && b.getTeamNum() != holder.getTeamNum())
						{
							b.set_s16("poison",20);
						}
					}
				}
				holder.Tag("flying");
			}
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
				for(int i = -1; i < 2; i += 1){
					CBlob @blob = server_CreateBlob("darkbolt", holder.getTeamNum(), this.getPosition()+Vec2f(XORRandom(8)-4,XORRandom(8)-4));
					if (blob !is null)
					{
						Vec2f shootVel = (holder.getAimPos()+Vec2f(XORRandom(8)-4,XORRandom(8)-4))-blob.getPosition();
						shootVel.Normalize();
						blob.setVelocity(shootVel*8);
						blob.SetDamageOwnerPlayer(holder.getPlayer());
					}
				}
				this.set_u16("timer",0);
			}
			
			if(point.isKeyPressed(key_action2)){
				ControlElements(this.get_f32("power"),holder.getAimPos(),true,true,true,true,true,true,true,true,true,true,false);
			}
			
			if(this.get_u16("super_timer") < 300)this.set_u16("super_timer",this.get_u16("super_timer")+1);
			else
			if(point.isKeyPressed(key_action3))if(getNet().isServer()){
				for(uint i = 0; i < 10; i += 1){
					CBlob @blob = server_CreateBlob("water_blob", holder.getTeamNum(), Vec2f(holder.getAimPos().x-40+i*8,0));
					if (blob !is null)
					{
						blob.setVelocity(Vec2f(0,XORRandom(5)));
						blob.SetDamageOwnerPlayer(holder.getPlayer());
					}
				}
				server_CreateBlob("derangedwisp", -1, holder.getAimPos());
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
						if(b.hasTag("player") && b.getTeamNum() != holder.getTeamNum())
						{
							b.set_s16("poison",200);
						}
						if(b.get_s16("life") > 0 && b.getTeamNum() != holder.getTeamNum())
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
				CBlob@[] blobsInRadius1;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius1.length; i++)
					{
						CBlob@ b = blobsInRadius1[i];
						if(b.getName() == "ghost")
						{
							ChangeClass(b,"wraithknight",b.getPosition(),holder.getTeamNum());
						}
						if(b.hasTag("dead"))
						{
							CBlob @newBlob = server_CreateBlob("zombie", this.getTeamNum(), b.getPosition());
							for(uint j = 0; j < 5; j += 1)server_CreateBlob("heart", -1, b.getPosition()+Vec2f(XORRandom(10)-5,0));
							b.server_Die();
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
			if(!playerblob.hasTag("ghost"))playerblob.server_Die();
		}
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