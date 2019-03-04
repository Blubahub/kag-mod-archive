void ManageTool(CBlob @this, CBlob @item, bool holding, string type){

	this.set_string(type+"_tool_use","");

	if(item !is null){
		string script = item.get_string("equip_script");
		if(!this.hasScript(script)){
			this.AddScript(script);
		}
		CSprite @sprite = this.getSprite();
		if(sprite !is null){
			if(!sprite.hasScript(script)){
				sprite.AddScript(script);
			}
		}
		
		if(holding){
			this.set_string(type+"_tool_use",item.getName());
			this.set_u8(type+"_implement", 8);
		}
	}
}