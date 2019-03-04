


void onDie(CBlob@ this){
	if (!getNet().isServer())return;
	
	if(this.getName() == "necro"){
		CBlob @blob = server_CreateBlob("necrostaff", -1, this.getPosition());
		if (blob !is null)
		{
			blob.set_string("owner",this.get_string("owner"));
		}
	}
	
	if(this.getName() == "hero"){
		CBlob @blob = server_CreateBlob("herosword", -1, this.getPosition());
		if (blob !is null)
		{
			blob.set_string("owner",this.get_string("owner"));
		}
	}
	
	if(this.getName() == "darkknight"){
		CBlob @blob = server_CreateBlob("soulblade", -1, this.getPosition());
		if (blob !is null)
		{
			blob.set_string("owner",this.get_string("owner"));
		}
	}
	/*
	if(this.getName() == "darkfollower"){
		CBlob @blob = server_CreateBlob("shadowblade", -1, this.getPosition());
		if (blob !is null)
		{
			blob.set_string("owner",this.get_string("owner"));
		}
	}*/
	
	if(this.getName() == "darkbeing"){
		CBlob @blob = server_CreateBlob("darkorb", -1, this.getPosition());
	}
	
	if(this.getName() == "wraithmaster" || this.getName() == "wraith"){
		if(!this.hasTag("shadowchange"))server_CreateBlob("wraithcloak", -1, this.getPosition());
	}
}