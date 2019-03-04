
#include "WizardCommon.as";
#include "OrbCommon.as";

void onInit( CBlob@ this )
{
	this.set_u32("last magic fire", 0 );
	this.set_u8("magic fire count", 0 );
}

void onTick( CBlob@ this )
{
	// if (getNet().isServer() && this.isKeyPressed( key_action1 ))
	// {
	u8 count = this.get_u8("magic fire count");
	const u32 gametime = getGameTime();
		
	if(count < ORB_LIMIT){
		if(this.isKeyPressed( key_action1 )) {
			u32 lastFireTime = this.get_u32("last magic fire");
			int diff = gametime - (lastFireTime + FIRE_FREQUENCY);
			if (diff > 0)
			{
				Vec2f pos = this.getPosition();
				Vec2f aim = this.getAimPos();
				
				u16 targetID = 0xffff;
				CMap@ map = this.getMap();
				if(map !is null)
				{
					CBlob@[] targets;
					if(map.getBlobsInRadius( aim, 32.0f, @targets ))
					{
						for(uint i = 0; i < targets.length; i++)
						{
							CBlob@ b = targets[i];
							if (b !is null && isEnemy(this, b))
							{
								targetID = b.getNetworkID();
							}
						}
					}
				}
				
				this.set_u32("last magic fire", gametime);
				this.set_u8("magic fire count", ++count );
				
				Vec2f norm = aim - pos;
				norm.Normalize();
				
				CBlob@ orb; 
				if(getNet().isServer()){
					@orb = server_CreateBlob( "wizard_orb", this.getTeamNum(), pos + norm*this.getRadius()); 
				}
				
				if (orb !is null)
				{
					// print("norm: ("+norm.x+";"+norm.y+")");
					// print("aim: ("+aim.x+";"+aim.y+")");
					// print("pos: ("+pos.x+";"+pos.y+")");
					// print("");
					
					orb.SetDamageOwnerPlayer( this.getPlayer() );
					orb.setVelocity( norm * (diff <= FIRE_FREQUENCY/3 ? ORB_SPEED/2.0f : ORB_SPEED) );
					
					if(targetID != 0xffff)
					{
						//orb.set_u16("target", targetID);
					}
				}
			}
		} else if(false && this.isKeyPressed( key_action3 ) && count != 0){
			this.set_u32("last magic fire", gametime);
			this.set_u8("magic fire count", ORB_LIMIT );
		}
	} else {
			u32 lastFireTime = this.get_u32("last magic fire");
			int diff = gametime - (lastFireTime + ORB_BURST_COOLDOWN);
			
			if(this.isKeyJustPressed( key_action1 ) && this.isMyPlayer()){ 
				Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
			}
			
			if (diff > 0)
			{
				this.set_u8("magic fire count", 0 );
				this.getSprite().PlaySound((XORRandom(2) == 1) ? "/EvilLaughShort2.ogg" : "/EvilLaugh.ogg"); 
			}
	}
		
	// }   
}
