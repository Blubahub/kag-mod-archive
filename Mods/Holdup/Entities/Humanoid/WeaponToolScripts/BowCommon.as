
void ManageBow(CBlob @this, bool charging){

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f vec = aimpos - pos;
	vec.Normalize();

	if(!charging && this.get_u16("bowcharge") > 20){
	
		if(getEquippedBlob(this,"back") !is null)
		if(getEquippedBlob(this,"back").getInventory() !is null){
			CInventory @inv = getEquippedBlob(this,"back").getInventory();
		
			for(int i = 0; i < inv.getItemsCount();i++){
				CBlob @item = inv.getItem(i);
				if(item !is null){
					if(item.getName() == "arrow"){
						item.server_RemoveFromInventories();
						this.DropCarried();
						CreateArrow(this,this.getPosition(),vec*(this.get_u16("bowcharge")/2.2f),0,item);
						break;
					}
				}
			}
		}
	
		//CreateArrow(this,this.getPosition(),vec*(this.get_u16("bowcharge")/2.2f),0);
		this.set_u16("bowcharge",0);
	}
	
	if(charging){
		if(this.getSprite() !is null)
		if(this.get_u16("bowcharge") == 0){
			this.getSprite().RewindEmitSound();
			this.getSprite().SetEmitSoundPaused(false);
		}
		if(this.get_u16("bowcharge") < 40)this.set_u16("bowcharge",this.get_u16("bowcharge")+1);
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


CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType, CBlob @item)
{
	if(item is null){
		if(getNet().isServer()){
			CBlob@ arrow = server_CreateBlobNoInit("arrow");
			if (arrow !is null)
			{
				arrow.SetDamageOwnerPlayer(this.getPlayer());
				arrow.Init();

				arrow.IgnoreCollisionWhileOverlapped(this);
				arrow.server_setTeamNum(this.getTeamNum());
				arrow.setPosition(arrowPos);
				arrow.setVelocity(arrowVel);
			}
			
			return arrow;
		}
	} else {
		item.IgnoreCollisionWhileOverlapped(this);
		item.server_setTeamNum(this.getTeamNum());
		item.setPosition(arrowPos);
		item.setVelocity(arrowVel);
		
		if(getNet().isClient()){
			item.Tag("shot");
			item.set_Vec2f("shot_pos",arrowPos);
			item.set_Vec2f("shot_vel",arrowVel);
		}
		
		return item;
	}
	return null;
}