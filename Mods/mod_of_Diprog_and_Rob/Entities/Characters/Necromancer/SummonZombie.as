
#include "WizardCommon.as";

void onInit( CBlob@ this )
{
	this.set_u32("last teleport", 0 );
	this.set_bool("teleport ready", true );
}


void onTick( CBlob@ this ) 
{	
	bool ready = this.get_bool("teleport ready");
	const u32 gametime = getGameTime();
	
	if(ready) {
		if(this.isKeyJustPressed( key_action2 )) {
			Vec2f delta = this.getPosition() - this.getAimPos();
			if(delta.Length() < TELEPORT_DISTANCE){
				this.set_u32("last teleport", gametime);
				this.set_bool("teleport ready", false );
				SummonZombie(this, this.getAimPos());
			} else if(this.isMyPlayer()) {
				Sound::Play("option.ogg");
			}
		}
	} else {		
		u32 lastTeleport = this.get_u32("last teleport");
		int diff = gametime - (lastTeleport + TELEPORT_FREQUENCY);
		
		if(this.isKeyJustPressed( key_action2 ) && this.isMyPlayer()){
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("teleport ready", true );
			this.getSprite().PlaySound("/EvilNotice.ogg"); 
		}
	}
}

void SummonZombie( CBlob@ blob, Vec2f pos){	
	CMap@ map = getMap();	
	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius( pos, blob.getRadius()*1.0f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is null && b.hasTag("dead"))
			{	
				Vec2f bpos = b.getPosition();
				string name = b.getConfig();
				if (name == "knight" || name == "builder" || name == "crossbowman" || name == "heavyknight"){
					CBlob@ zombie = server_CreateBlob("zombie", blob.getTeamNum(), bpos);
				}
				if (b.getConfig() == "archer"){
					CBlob@ skeleton = server_CreateBlob("skeleton", blob.getTeamNum(), bpos);
				}
				ParticleZombieLightning(bpos);	
				ParticleZombieLightning(blob.getPosition());	
				b.getSprite().Gib();
				b.server_Die();
			}
		}
	}
}
