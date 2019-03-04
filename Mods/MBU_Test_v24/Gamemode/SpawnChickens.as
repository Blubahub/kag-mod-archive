
void onTick(CRules @this){
	if(getNet().isServer()){
		CBlob@[] chickens;
				
		getBlobsByName("chicken", chickens);
				
		if(chickens.length < 20){
			server_CreateBlob("chicken",-1,Vec2f(XORRandom(getMap().tilemapwidth*8),0));
		}
	}
}