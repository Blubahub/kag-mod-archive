


void onDie(CBlob@ this){
	if(!getNet().isServer())return;
	if(this.hasTag("switch class"))return;
	
	if(this.getName() == "builder" || this.getName() == "archer" || this.getName() == "knight" || this.getName() == "priest" || this.getName() == "hero"){
		CBlob @newBlob = server_CreateBlob("ghost", -1, this.getPosition());
		if (newBlob !is null)
		{
			// plug the soul
			newBlob.server_SetPlayer(this.getPlayer());
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
		}
	}
	
	if(this.getName() == "necro" || this.getName() == "darkfollower" || this.getName() == "darkknight" || this.getName() == "darkbeing"){
		CBlob @newBlob = server_CreateBlob("taintedghost", -1, this.getPosition());
		if (newBlob !is null)
		{
			// plug the soul
			newBlob.server_SetPlayer(this.getPlayer());
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
		}
	}
	
}