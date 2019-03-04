
#include "DrawOverlay.as";
#include "EquipCommon.as";

void onInit(CBlob @this){
	this.set_u8("eyes",2);
}

void onRender(CSprite@ this)
{

	CBlob@ blob = this.getBlob();

	if(getLocalPlayer() !is blob.getPlayer())return;
	
	int eyes = blob.get_u8("eyes");
	
	CBlob @helmet = getEquippedBlob(blob, "head");
	if(helmet !is null){
		if(helmet.hasTag("full_helmet"))if(eyes > 1)eyes = 1;
	}

	if(eyes == 1){
		DrawOverlay("OneEyeBlind.png");
	}
	
	if(eyes == 0){
		DrawOverlay("TwoEyesBlind.png");
	}
}
