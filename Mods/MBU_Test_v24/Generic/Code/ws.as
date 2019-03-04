#include "la.as";

void onRestart( CRules@ this ){
	this.Untag("life_tree");
}

void onTick(CRules @this){
	
	if(getNet().isServer()){

		if(!this.hasTag("life_tree")){
			
			CBlob@[] l;
				
			getBlobsByName("tree_life", l);
			
			if(l.length <= 0){
				CBlob@[] t;
				getBlobsByName("tree_bushy", t);
				getBlobsByName("tree_pine", t);
				getBlobsByName("tree_large", t);
				if(t.length > 0){
					CBlob @ tt = t[XORRandom(t.length)];
					if(tt !is null){
						CBlob @lt = server_CreateBlobNoInit("tree_life");
						lt.Tag("startbig");
						lt.setPosition( tt.getPosition());
						lt.Init();
						tt.server_Die();
						
					}
				}
			} else {
				this.Tag("life_tree");
			}
			
		}

		CBlob@[] w;
				
		getBlobsByName("w", w);
		if(XORRandom(100) == 0){
			if(XORRandom(w.length*10) == 0){
				if(XORRandom(10) == 0){
					CBlob@[] t;
					getBlobsByName("tree_bushy", t);
					getBlobsByName("tree_pine", t);
					getBlobsByName("tree_large", t);
					if(t.length > 0){
						CBlob @ tt = t[XORRandom(t.length)];
						if(tt !is null){
							tt.set_s16("life_amount",51);
							summon_wisp(tt);
							tt.set_s16("life_amount",0);
						}
					}
				} else {
					CBlob@[] t;
					getBlobsByName("tree_life", t);
					if(t.length > 0){
						CBlob @ tt = t[XORRandom(t.length)];
						if(tt !is null && tt.hasTag("grown")){
							tt.set_s16("life_amount",51);
							summon_wisp(tt);
							tt.set_s16("life_amount",0);
						}
					}
				}
			}
		}
	}
}