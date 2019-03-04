
bool checkEInterface(CBlob @this, Vec2f pos, int radius, int power){

	return true;

}

f32 getPowerMod(CBlob @this, string elem){

	if(this is null)return 1.0f;

	float power = 1.0f;

	if(elem == "fire"){
		int burnt_eyes = this.get_u8("burnt_eyes");
		if(burnt_eyes == 0)power *= 0.5;
		else power *= f32(burnt_eyes);
	}
	
	if(elem == "blood"){
		power += f32(this.get_s16("blood_amount")-100)/1000.0f;
	}
	
	if(elem == "light"){
		if(this.getName() == "goldenbeing"){
			power *= 5.0f;
		}
	}

	return power;
}