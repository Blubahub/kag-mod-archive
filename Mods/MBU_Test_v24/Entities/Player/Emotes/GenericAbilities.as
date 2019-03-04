
void EatScript(CBlob @this){
	if(CheckCooldown(this,"eat_cd") == 0){
		if(isServer())this.SendCommand(this.getCommandID("eat_held"));
		StartCooldown(this,"eat_cd",30);
	}
}

string EatIcon(CBlob @this){
	if(this.getCarriedBlob() !is null)if(this.getCarriedBlob().hasTag("jar")){
		return "DrinkIcon.png";
	}
	if(CheckCooldown(this,"eat_cd") > 0){
		if(getGameTime() % 10 < 5)return "EatIcon.png";
		else return "EatClosedIcon.png";
	}
	return "EatIcon.png";
}

string EmoteIcon(CBlob @this){return "EmoteIcon.png";}