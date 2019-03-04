 void onInit(CBlob @ this){
 
	this.Tag("tileplace");
	this.set_s16("placetile",48);
	
	this.maxQuantity = 100;
	if(getNet().isServer()){
		this.server_SetQuantity(1);
	}
 
 }
 
 void onTick(CBlob @this){
	if(getNet().isServer())
	if(this.getQuantity() <= 0)this.server_Die();
 }