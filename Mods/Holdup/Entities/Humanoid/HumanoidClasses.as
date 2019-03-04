
#include "HumanoidCommon.as";

void equipCloth(CBlob @this){
	if(this.getSexNum() == 1)equipItemTemp(this, server_CreateBlob("cloth_shirt",this.get_u8("cloth_colour"),this.getPosition()), "torso");
	equipItemTemp(this, server_CreateBlob("cloth_pants",this.get_u8("cloth_colour"),this.getPosition()), "legs");
}

void equipFlax(CBlob @this){
	equipItemTemp(this, server_CreateBlob("flax_shirt",-1,this.getPosition()), "torso");
	equipItemTemp(this, server_CreateBlob("flax_pants",-1,this.getPosition()), "legs");
}

void equipBreastplateAndCloth(CBlob @this){
	equipItemTemp(this, server_CreateBlob("metal_shirt",-1,this.getPosition()), "torso");
	equipItemTemp(this, server_CreateBlob("cloth_pants",this.get_u8("cloth_colour"),this.getPosition()), "legs");
}

void equipNomad(CBlob @this){
	if(!getNet().isServer())return;
	equipItemTemp(this, server_CreateBlob("sack",-1,this.getPosition()), "back");
	equipItemTemp(this, server_CreateBlob("pick_axe",-1,this.getPosition()), "sub_arm");
	equipFlax(this);
}

void equipBuilder(CBlob @this){
	if(!getNet().isServer())return;
	equipItemTemp(this, server_CreateBlob("pick_axe",-1,this.getPosition()), "sub_arm");
	equipCloth(this);
}

void equipArcher(CBlob @this){
	if(!getNet().isServer())return;
	equipItemTemp(this, server_CreateBlob("bow",-1,this.getPosition()), "main_arm");
	equipItemTemp(this, server_CreateBlob("grapple",-1,this.getPosition()), "sub_arm");
	equipCloth(this);
}

void equipKnight(CBlob @this){
	if(!getNet().isServer())return;
	equipItemTemp(this, server_CreateBlob("metal_sword",-1,this.getPosition()), "main_arm");
	equipItemTemp(this, server_CreateBlob("shield",-1,this.getPosition()), "sub_arm");
	equipBreastplateAndCloth(this);
}