#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.getShape().SetGravityScale(0.0f);
	
	this.set_u32("create_time",getGameTime());
	
	this.Tag("can_dispell");
	
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 0, 255, 255));
	
	this.set_u16("teleportal_id",0);
}

void onTick(CBlob@ this)
{
	if(!this.hasTag("cemented"))
	if(this.get_u32("create_time") < getGameTime() - 120){
		this.getShape().SetStatic(true);
		this.Tag("cemented");
	}
	
	CSprite @sprite = this.getSprite();
	if(sprite !is null){
		sprite.SetZ(1000);
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(!blob.hasTag("dead"))
	if(blob.hasTag("flesh") && blob.getName() != "migrant" && !blob.hasTag("RuneNullify"))
	if(blob.get_u32("last_teleport") < getGameTime() - 60){
		CBlob@[] portals;
		getBlobsByName("teleportal", @portals);
		
		if(portals.length > 1){
		
			CBlob@ portal = portals[XORRandom(portals.length)];
			
			int fails = 0;
			while((portal is this || portal.get_u16("teleportal_id") != this.get_u16("teleportal_id")) && fails < 50 ){
				@portal = portals[XORRandom(portals.length)];
				fails++;
			}
			
			if(portal !is null && portal !is this && portal.get_u16("teleportal_id") == this.get_u16("teleportal_id")){
				blob.setPosition(portal.getPosition());
				blob.set_u32("last_teleport",getGameTime());
				
				if (blob.isMyPlayer())
				{
					SetScreenFlash(255, 255, 255, 255);
					Sound::Play("WC3_Recall");
				}
			}
		}
	}
	
}