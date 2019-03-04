


int getEnergy(CBlob @ this){
	int energy = this.get_u8("Energy");
	return energy;
}

void addEnergy(CBlob @ this, int energy){
	if(getNet().isServer()){
		if(this.get_u8("Energy")+energy >= 0)this.set_u8("Energy", this.get_u8("Energy")+energy);
		else this.set_u8("Energy", 0);

		this.Sync("Energy",true);
	}
}

void setEnergy(CBlob @ this, int energy){
	if(getNet().isServer()){
		this.set_u8("Energy", energy);
		this.Sync("Energy",true);
	}
}

int getMaxEnergy(string name){

	//Smartest - 20 energy
	if(name == "runescribe")return 20;
	if(name == "runemaster")return 15;
	
	//Smart - 10 energy
	if(name == "priest")return 10;
	if(name == "necro")return 10;
	if(name == "mindman")return 10;
	if(name == "brainswitcher")return 10;
	
	//Average - 5 energy
	if(name == "archer")return 5;
	if(name == "builder")return 5;
	if(name == "crossbow")return 5;
	if(name == "waterman")return 5;
	if(name == "paladin")return 5;
	
	
	
	//Dumb - 3 energy
	if(name == "knight")return 3;
	if(name == "ninja")return 3;
	if(name == "samurai")return 3;
	if(name == "sapper")return 3;
	
	//Shadow master is here for balance reasons, they could just hide and cast scrolls while in dirt under the enemy. They had 5 energy previously
	if(name == "shadowman")return 3;
	if(name == "mansshadow")return 3;
	
	//Stupid - 2 energy
	return 2;
}