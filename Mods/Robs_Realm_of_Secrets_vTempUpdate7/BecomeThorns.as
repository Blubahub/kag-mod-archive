
void onTick(CBlob @this){

	if(!getNet().isServer())return;

	CBlob@[] Blobs;	   
	getBlobsByName("naturesgrave", @Blobs);
	if(Blobs.length > 0)if(XORRandom(100) == 0){
		
		server_CreateBlob("thorns", -1, this.getPosition());
		this.server_Die();
		
	}
}