
//Types:
//0 - none/fist
//1 - stick
//2 - pick
//3 - sword
//4 - bow
//5 - shield
//6 - grapple
//7 - axe
//8 - stabber
//9 - Pickaxe

bool isTwoHanded(CBlob @item){

	if(item is null)return false;

	if(item.hasTag("two_handed"))return true;
	
	return false;
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

string getSpritePrefix(string name){

	if(name == "flax_shirt")return "flax";
	if(name == "flax_pants")return "flax";

	if(name == "leather_shirt")return "leather";
	if(name == "leather_pants")return "leather";
	
	if(name == "cloth_shirt")return "cloth";
	if(name == "cloth_pants")return "cloth";
	
	if(name == "metal_shirt")return "metal";
	if(name == "metal_pants")return "metal";
	
	return "";
}
