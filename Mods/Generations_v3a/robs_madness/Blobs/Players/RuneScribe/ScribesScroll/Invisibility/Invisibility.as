

void onTick(CBlob @this){

	if(!this.hasTag("Invisible")){
	
		this.Tag("Invisible");
	
		this.set_u32("invis_timer",getGameTime()+(30*30));
		
		if(getNet().isServer())this.Sync("Barrier",true);
	}
	
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		bool isvisible = false;
		if(getLocalPlayerBlob() !is null)if(getLocalPlayerBlob().getTeamNum() == this.getTeamNum())isvisible = true;
		
		if(this.get_u32("invis_timer") < getGameTime())isvisible = true;
		
		this.SetVisible(isvisible);
		sprite.setRenderStyle(RenderStyle::additive);
		
		for(int i = 0; i < sprite.getSpriteLayerCount(); i++){
			CSpriteLayer @sl = sprite.getSpriteLayer(i);
			if(sl !is null){
				this.SetVisible(isvisible);
				sprite.setRenderStyle(RenderStyle::additive);
			}
		}
	}

	if(this.get_u32("invis_timer") < getGameTime() || this.hasTag("RuneNullify")){
		this.Untag("Invisible");
		if(getNet().isServer())this.Sync("Invisible",true);
		
		this.RemoveScript("Invisibility.as");
	}

}