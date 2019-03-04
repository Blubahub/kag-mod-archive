
void onInit(CBlob @ this){
	this.set_u16("cloning_progress", 0);
	
	this.set_u8("MaxLevel",3);
}


void onTick(CBlob @ this)
{
	bool HasDeadPlayers = false;
	
	for(int p = 0; p < getPlayersCount(); p+=1){
	
		CPlayer @ player = getPlayer(p);
		
		if(player !is null){
			if(player.hasTag("dead")){
				if(this.get_u16("cloning_progress") > 300*20){
					if(getNet().isServer()){
						CBlob @newBlob = server_CreateBlob("builder", 0, this.getPosition());
						newBlob.server_SetPlayer(player);
						this.set_u16("cloning_progress",0);
						player.Untag("dead");
					}
					this.getSprite().PlaySound("clone_done.ogg", 1, 1);
				} else {
					HasDeadPlayers = true;
				}
			}
		}
	
	}
	
	
	
	if(HasDeadPlayers)this.set_u16("cloning_progress", this.get_u16("cloning_progress")+this.get_f32("Power")*10.0);
	
}