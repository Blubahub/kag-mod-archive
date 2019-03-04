void onInit(CSprite@ this)
{
	this.getBlob().set_u8("sprite_colour", 20);
}


void onTick(CSprite@ this)
{
	if(this.getBlob().get_u8("sprite_colour") != this.getBlob().get_u8("colour")){
		uint col = uint(XORRandom(8));
		if (this.getBlob().exists("colour"))
			col = this.getBlob().get_u8("colour");
		else
			this.getBlob().set_u8("colour", col);

		this.getBlob().set_u8("sprite_colour", col);
		this.ReloadSprites(col, 0); //random colour
	}
}

void onInit(CBlob @this){
	this.set_f32("nutrition_starch",0);
	this.set_f32("nutrition_fat",0);
	this.set_f32("nutrition_protein",100);
}