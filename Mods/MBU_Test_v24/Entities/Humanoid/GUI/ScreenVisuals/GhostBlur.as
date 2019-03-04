
#include "HumanoidCommon.as";
#include "DrawOverlay.as";

void onRender(CSprite@ this)
{

	CBlob@ blob = this.getBlob();

	if(getLocalPlayer() !is blob.getPlayer())return;

	if(blob.get_s8("head_type") == BodyType::Ghost || blob.get_s8("head_type") == BodyType::Wraith){
		DrawOverlay("GhostBlur.png");
	}
	
}
