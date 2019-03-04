
void onTick(CBlob @this){

	int Floatyness = this.getBlobCount("mat_gold")-this.getBlobCount("mat_metal")-this.getBlobCount("mat_stone")+this.getBlobCount("floater")*20;
	
	if(Floatyness < 0)Floatyness = 0;
	
	f32 Max = 250.0+250.0*(this.getMass()/4000.0);
	
	int MapHeight = getMap().tilemapheight*getMap().tilesize;
	
	f32 line = (MapHeight*1.2)*(1.0-(Floatyness/Max));
	
	if(line < this.getPosition().y){
		this.AddForce(Vec2f(0, -(this.getMass()/2)));
	} else {
	
		f32 result = (this.getPosition().y-(line-(MapHeight/4)))/(MapHeight/4);
	
		result -= 0;
	
		if(result < 0)result = 0;
	
		this.AddForce(Vec2f(0, -(this.getMass()/2*result)));
	}

	//this.AddForce(Vec2f(0, -Floatyness));
}