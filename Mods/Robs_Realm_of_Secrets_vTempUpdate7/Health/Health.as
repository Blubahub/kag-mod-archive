void Heal(CBlob @this, f32 amount){
	if(getNet().isServer()){
		if(Health(this) < MaxHealth(this)){
			SetHealth(this,Health(this)+amount);
			if(Health(this) > MaxHealth(this))SetHealth(this,MaxHealth(this));
		}
	}
}

void OverHeal(CBlob @this, f32 amount){
	if(getNet().isServer()){
		SetHealth(this,Health(this)+amount);
	}
}

f32 MaxHealth(CBlob @this){
	f32 MaxHP = this.getInitialHealth()*2;
	
	if(this.getTeamNum() < 20)MaxHP = this.getInitialHealth()*4;
	
	if(this.get_u8("race") == 2){
		MaxHP = MaxHP-1;
	}
	
	if(this.get_u8("race") == 3){
		MaxHP = MaxHP*1.5;
	}
	
	if(this.get_u8("race") == 6){
		MaxHP = MaxHP*5;
	}
	
	if(this.get_u8("race") == 7){
		MaxHP = MaxHP+1;
	}
	
	if(this.get_u8("race") == 8){
		MaxHP = MaxHP-2;
	}
	
	if(this.get_u8("race") == 9){
		MaxHP = 0;
	}
	
	return MaxHP;
}

f32 Health(CBlob @this){
	return this.getHealth()*2;
}

void SetHealth(CBlob @this, f32 amount){
	this.server_SetHealth(amount/2);
}

f32 Defense(CBlob @this){
	f32 Def = 1;
	
	if(this.get_s16("golden_shield") > 0)Def *= 0.5;
	if(this.get_s16("water_bubble") > 0)Def *= 0.75;
	
	if(this.get_u8("race") == 8)Def *= 0.5;
	
	if(this.get_s16("blood_strength") > 0)Def *= 0.5;
	
	return Def;
}