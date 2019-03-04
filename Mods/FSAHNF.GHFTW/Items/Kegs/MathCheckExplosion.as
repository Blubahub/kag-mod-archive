f32 CheckExplosion(CBlob @ this, f32 num){

	num = ((num/2.0f)/32.0f)*this.get_f32("explosive_radius");
	
	if(Maths::Round(this.get_f32("explosive_rads")) == Maths::Round(num))return num;
	else return 1/((num/num)-1);
	

}