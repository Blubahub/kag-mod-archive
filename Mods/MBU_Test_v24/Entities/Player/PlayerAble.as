
void onInit(CBlob @this){

	CSprite @spr = this.getSprite();
	
	if(spr !is null){
		spr.AddScript("AbilityHUD.as");
		spr.AddScript("PlayerHUD.as");
		spr.AddScript("SixthSense.as");
	}
	
	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob @this){
	if(!this.hasScript("LightTak.as"))this.AddScript("LifeTak.as");
	if(!this.hasScript("ltqt.as"))this.AddScript("ltqt.as");
	
	if(this.getPlayer() !is null){
		if(!this.hasScript("StandardControls.as"))this.AddScript("StandardControls.as");
		if(!this.hasScript("AbilityInventory.as"))this.AddScript("AbilityInventory.as");
		if(!this.hasScript("EmoteBubble.as"))this.AddScript("EmoteBubble.as");
		if(!this.hasScript("EmoteHotkeys.as"))this.AddScript("EmoteHotkeys.as");
		
		if(!this.hasTag("emote_ability")){
			this.addCommandID("use_ability");
			this.addCommandID("set_hotbar_slot");
			this.addCommandID("set_hotbar");
			this.set_u8("slot_setting",0);
			
			this.Tag("emote_ability");
		}
		
		if(!this.hasScript("LightTak.as"))this.AddScript("LightTak.as");
		if(!this.hasScript("DeathTak.as"))this.AddScript("DeathTak.as");
		
		if(this.hasTag("flesh")){
			if(!this.hasScript("BloodTak.as"))this.AddScript("BloodTak.as");
			if(!this.hasScript("bs.as"))this.AddScript("bs.as");
		}
		
		if(!this.hasScript("ew.as"))this.AddScript("ew.as");
		if(!this.hasScript("DarkTak.as"))this.AddScript("DarkTak.as");
		if(!this.hasScript("FireTak.as"))this.AddScript("FireTak.as");
		if(!this.hasScript("ftqt.as"))this.AddScript("ftqt.as");
		if(!this.hasScript("draqt.as"))this.AddScript("draqt.as");
	}
}