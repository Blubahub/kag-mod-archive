

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
	
	
	if(this.get_s16("neardeaths") >= 2){
		string name = "wraithknight";
		if(this.getName() == "archer")name = "wraitharcher";
		if(this.getName() == "builder" && XORRandom(2) == 0)name = "wraitharcher";
		CBlob @newBlob = server_CreateBlob(name, this.getTeamNum(), this.getPosition());
		if (newBlob !is null)
		{
			// plug the soul
			newBlob.server_SetPlayer(this.getPlayer());
			
			int time = this.get_s16("kills")*5+10;
			if(time > 300 || this.hasTag("evil"))time = 300;
			newBlob.set_s16("corruption",time);
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
		}
		return;
	}
	
	CBlob @newBlob = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
	if (newBlob !is null)
	{
		if(this.getPlayer() !is null)this.set_string("username",this.getPlayer().getUsername());
		// plug the soul
		newBlob.server_SetPlayer(this.getPlayer());
		
		int time = this.get_s16("kills")*5+10;
		if(time > 300 || this.hasTag("evil"))time = 300;
		
		if(this.getName() == "wraithknight" || this.getName() == "wraitharcher")time = this.get_s16("corruption");
		
		newBlob.server_SetTimeToDie(time);
		newBlob.set_s16("corruption",time);
		
		this.Tag("switch class");
		this.server_SetPlayer(null);
	}
	return;
}