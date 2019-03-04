


void onDie(CBlob@ this){
	if (!getNet().isServer())return;
	
	if(this.getName() == "necro"){
		CBlob @blob = server_CreateBlob("necrobook", -1, this.getPosition());
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
	
	if(this.getName() == "darkfollower"){
		CBlob @blob = server_CreateBlob("darkbook", -1, this.getPosition());
		if (blob !is null)
		{
			blob.set_string("owner",this.get_string("owner"));
		}
	}
	
	if(this.getName() == "darkbeing"){
		CBlob @blob = server_CreateBlob("darkorb", -1, this.getPosition());
	}
}