#include "GetAttached.as"
#include "WeakwizardCommon.as";

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
				CBlob@ attached = getAttached(this, "PICKUP");
				if (attached !is null && (attached.hasTag("heavy weight") || attached.hasTag("medium weight")))
					this.server_DetachAll();
				Teleport(this, this.getAimPos());
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
		}
	}
}

void Teleport( CBlob@ blob, Vec2f pos){
	AttachmentPoint@[] ap;
	blob.getAttachmentPoints(ap);
	for (uint i = 0; i < ap.length; i++){
		if(!ap[i].socket && ap[i].getOccupied() !is null){
			@blob = ap[i].getOccupied();
			break;
		}
	}
	CBlob@ smok = server_CreateBlob("teamcoloredlargesmoke", blob.getTeamNum(), blob.getPosition());
	blob.setPosition( pos );
	blob.setVelocity( Vec2f_zero );
	CBlob@ smoke = server_CreateBlob("teamcoloredlargesmoke", blob.getTeamNum(), blob.getPosition());		
	blob.getSprite().PlaySound("/Respawn.ogg");
}