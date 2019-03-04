
void copy(CBlob @this, CBlob @target, bool abilities_power, bool food, bool soul, bool emotes, bool z, bool a, bool b, bool c){

	if(abilities_power){
		target.add_s16("death_amount", this.get_s16("death_amount"));
		target.add_s16("life_amount", this.get_s16("life_amount"));
		target.add_s16("fire_amount", this.get_s16("fire_amount"));
		target.add_s16("nature_amount", this.get_s16("nature_amount"));
		target.add_s16("blood_amount", this.get_s16("blood_amount"));
		target.add_s16("light_amount", this.get_s16("light_amount"));
		target.add_s16("dark_amount", this.get_s16("dark_amount"));
	}
	
	if(food){
		target.set_u8("food_starch",this.get_u8("food_starch"));
		target.set_u8("food_meat",this.get_u8("food_meat"));
		target.set_u8("food_plant",this.get_u8("food_plant"));
		target.set_u8("food_blood",this.get_u8("food_blood"));
	}
	
	if(soul){
		this.Untag("soul");
		target.Tag("soul");
		target.server_SetPlayer(this.getPlayer());
	}

	if(emotes){
		for(int i = 1;i <= 9;i++){
			target.set_u8("slot_"+i,this.get_u8("slot_"+i));
			if(isServer())target.Sync("slot_"+i,true);
		}
	}
}