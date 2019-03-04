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
	
	return MaxHP;
}

f32 Health(CBlob @this){
	return this.getHealth()*2;
}

void SetHealth(CBlob @this, f32 amount){
	this.server_SetHealth(amount/2);
}

f32 Defense(CBlob @this){
	f32 Def = 1; //This is a percentage (so, 1 == 100% damage taken, 0.5 == 50% damage taken)
	
	return Def;
}