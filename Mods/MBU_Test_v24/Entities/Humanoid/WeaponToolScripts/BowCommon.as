#include "Knocked.as";

void ManageBow(CBlob @this, bool charging){

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f vec = aimpos - pos;
	vec.Normalize();

	if(!charging && this.get_u16("bowcharge") > 20){
		
		if(getNet().isServer()){
			if(getEquippedBlob(this,"back") !is null)
			if(getEquippedBlob(this,"back").getInventory() !is null){
				CInventory @inv = getEquippedBlob(this,"back").getInventory();
			
				for(int i = 0; i < inv.getItemsCount();i++){
					CBlob @item = inv.getItem(i);
					if(item !is null){
						if(item.getName() == "arrow"){
							item.server_RemoveFromInventories();
							this.DropCarried();
							CBitStream params;
							params.write_Vec2f(this.getPosition());
							params.write_Vec2f(vec*(this.get_u16("bowcharge")/2.2f));
							item.server_setTeamNum(this.getTeamNum());
							item.SetDamageOwnerPlayer(this.getPlayer());
							item.SendCommand(item.getCommandID("fire_arrow"),params);
							
							break;
						}
					}
				}
			}
		}
		this.set_u16("bowcharge",0);
	}
	
	if(charging){
		if(this.getSprite() !is null)
		if(this.get_u16("bowcharge") == 0){
			this.getSprite().RewindEmitSound();
			this.getSprite().SetEmitSoundPaused(false);
		}
		if(this.get_u16("bowcharge") < 40)this.add_u16("bowcharge",1);
		else this.getSprite().SetEmitSoundPaused(true);
		
		this.Tag("shootingbow");
	} else {
		if(this.getSprite() !is null){
			this.getSprite().SetEmitSoundPaused(true);
			//this.getSprite().PlaySound("PopIn.ogg");
		}
		this.set_u16("bowcharge",0);
		if(this.hasTag("shootingbow"))this.Untag("shootingbow");
	}

}