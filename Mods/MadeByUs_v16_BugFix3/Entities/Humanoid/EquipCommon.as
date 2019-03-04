
int getEquipedHandType(CBlob @this, string name){
	//Types:
	//0 - none/fist
	//1 - stick
	//2 - pick
	//3 - sword
	//4 - bow
	//5 - shield
	//6 - grapple
	//7 - axe
	
	if(name == "shield")return 5;
	
	if(name == "grapple")return 6;
	
	if(name == "bow")return 4;
	
	if(name == "stick")return 1;
	
	if(name == "pick")return 2;
	
	if(name == "hammer")return 2;
	
	if(name == "axe")return 7;
	
	if(name == "hachet")return 7;
	
	return 0;
}

bool isTwoHanded(string name){

	if(name == "shield")return true;
	
	if(name == "bow")return true;
	
	return false;
}

//This doesn't do anything anymore and shoul;dn't be used or updated
int getEquipedType(string name){
	//-1 - none
	//0 - head
	//1 - torso
	//2 - legs
	//3 - arms
	//4 - back

	//Torso
	if(name == "flaxshirt")return 1;
	
	
	//Arms
	if(name == "shield")return 3;
	if(name == "grapple")return 3;
	if(name == "bow")return 3;
	if(name == "stick")return 3;
	if(name == "pick")return 3;
	if(name == "hammer")return 3;
	if(name == "axe")return 3;
	if(name == "hachet")return 3;
	
	//Back
	if(name == "sack")return 4;
	if(name == "barrel")return 4;
	if(name == "backpack")return 4;
	
	return -1;
}

float getItemDamage(CBlob @ item){

	if(item is null)return 0.0f;
	
	string name = item.getName();

	float Damage = 0.0f;
	
	if(name == "pick")Damage = 3.0f;
	if(name == "hammer")Damage = 2.0f;
	if(name == "axe")Damage = 4.0f;
	if(name == "hachet")Damage = 2.0f;
	if(name == "stick")Damage = 2.0f;
	
	
	
	return Damage;
}

CBlob@ getEquippedBlob(CBlob @this, string equip){

	CBlob @ result = null;

	if(this.getInventory() !is null)
	for(int i = 0;i < this.getInventory().getItemsCount();i += 1){
		CBlob @blob = this.getInventory().getItem(i);
		if(blob !is null){
			if(blob.hasTag(equip)){
				@result = blob;
			}
		}
	}

	
	return result;
}