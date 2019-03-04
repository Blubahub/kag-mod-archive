
CBlob@ CookedResult(CBlob @Item){
	
	if(Item is null)return null;

	string Name = Item.getName();

	if(Name == "fishy"){
		CBlob @food = server_CreateBlob("cooked_fish", -1, Item.getPosition());
		food.set_u8("colour", Item.get_u8("colour"));
		return food;
	}
	if(Name == "steak"){
		return server_CreateBlob("cooked_steak", -1, Item.getPosition());
	}
	
	return null;
}

bool canBeCooked(CBlob @ Item){

	if(Item is null)return false;
	
	string Name = Item.getName();
	
	if(Name == "fishy")return true;
	if(Name == "steak")return true;
	
	return false;
}