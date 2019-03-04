

void onTick(CBlob@ this){

	if(this.getHealth() < 0.5){
		this.Tag("neardeath");
	} else {
		if(this.hasTag("neardeath")){
			this.set_s16("neardeaths",this.get_s16("neardeaths")+1);
			this.Untag("neardeath");
		}
	}

}



void onDie(CBlob@ this){
	if(!getNet().isServer())return;
	if(this.hasTag("switch class"))return;
	
	if(this.get_s16("neardeaths") >= 1){
		string name = "wraithknight";
		if(this.getName() == "builder" || this.getName() == "archer" || this.getName() == "priest")name = "wraitharcher";
		CBlob @newBlob = server_CreateBlob(name, this.getTeamNum(), this.getPosition());
		if (newBlob !is null)
		{
			// plug the soul
			newBlob.server_SetPlayer(this.getPlayer());
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
		}
		return;
	}
	
	
	if(this.getName() == "builder" || this.getName() == "archer" || this.getName() == "knight" || this.getName() == "priest" || this.getName() == "hero"){
		CBlob @newBlob = server_CreateBlob("ghost", -1, this.getPosition());
		if (newBlob !is null)
		{
			// plug the soul
			newBlob.server_SetPlayer(this.getPlayer());
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
		}
		return;
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
		return;
	}
	
}