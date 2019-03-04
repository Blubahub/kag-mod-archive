
void onInit(CBlob@ this)
{
	this.set_u8("race",0);
	this.set_u8("race_sprite",-1);
}

void onTick(CBlob@ this)
{
	int Race = this.get_u8("race");
	if(Race == 1){
		this.Tag("evil");
	}
	
	if(Race == 3){
		this.Tag("flying");
	}
}


void onTick(CSprite@ this)
{
	int Race = this.getBlob().get_u8("race");
	int RaceSpr = this.getBlob().get_u8("race_sprite");
	if(Race != RaceSpr){
		string modpath = "../Mods/Robs_Realm_of_Secrets_v1/Classes/Sprites/";
		
		string classname = "Builder";
		if(this.getBlob().getName() == "knight")classname = "Knight";
		if(this.getBlob().getName() == "archer")classname = "Archer";
		
		string racename = "Human";
		if(Race == 0)racename = "Human";
		if(Race == 1)racename = "Shadow";
		if(Race == 2)racename = "Risen";
		if(Race == 3)racename = "Faceless";
		
		string texname = modpath+racename+"_"+classname+".png";
		
		this.ReloadSprite(texname);
		
		CSpriteLayer@ head = this.getSpriteLayer("head");
		head.ReloadSprite(modpath+racename+"_Heads.png",16,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		
		if(this.getBlob().getName() == "archer"){
			if(this.getSpriteLayer("frontarm") !is null)
			this.getSpriteLayer("frontarm").ReloadSprite(modpath+racename+"_"+classname+".png",32,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("backarm") !is null)
			this.getSpriteLayer("backarm").ReloadSprite(modpath+racename+"_"+classname+".png",32,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("quiver") !is null)
			this.getSpriteLayer("quiver").ReloadSprite(modpath+racename+"_"+classname+".png",16,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("hook") !is null)
			this.getSpriteLayer("hook").ReloadSprite(modpath+racename+"_"+classname+".png",16,8,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("rope") !is null)
			this.getSpriteLayer("rope").ReloadSprite(modpath+racename+"_"+classname+".png",32,8,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		}
		
		if(this.getBlob().getName() == "knight"){
			if(this.getSpriteLayer("chop") !is null)
			this.getSpriteLayer("chop").ReloadSprite(modpath+racename+"_"+classname+".png",32,32,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		}
		
		if(Race == 3){
			this.RemoveSpriteLayer("cape");
			CSpriteLayer@ cape = this.addSpriteLayer("cape", modpath+racename+"_Cape.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			cape.SetRelativeZ(-1.0f);
		}
		
		this.getBlob().set_u8("race_sprite",Race);
	}
	

}
