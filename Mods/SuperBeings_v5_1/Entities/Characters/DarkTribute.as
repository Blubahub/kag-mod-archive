void Tribute(CBlob@ this, int kills){
	CBlob@[] fg;
	getBlobsByName("darkbeing", @fg);
	for(uint i = 0; i < fg.length; i++)
	{
		if(fg[i].getPlayer() !is null)
		if(fg[i].getPlayer().getUsername() == this.get_string("owner")){
			fg[i].set_s16("power",fg[i].get_s16("power")+kills*10);
			fg[i].SyncToPlayer("power", fg[i].getPlayer());
		}
	}
}