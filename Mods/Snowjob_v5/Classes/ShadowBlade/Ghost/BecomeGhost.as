void onDie(CBlob@ this){
	
	if(this.hasTag("switch class"))return;
	if(this.getPlayer() is null)return;
	
	
	
	server_CreateBlob("shadowbladegrave", this.getTeamNum(), this.getPosition());
	CBlob @newBlob = server_CreateBlob("shadowghost", this.getTeamNum(), this.getPosition());
	if (newBlob !is null)
	{
		if(this.getPlayer() !is null)this.set_string("username",this.getPlayer().getUsername());
		// plug the soul
		newBlob.server_SetPlayer(this.getPlayer());
		
		this.Tag("switch class");
		this.server_SetPlayer(null);
	}
	return;
}