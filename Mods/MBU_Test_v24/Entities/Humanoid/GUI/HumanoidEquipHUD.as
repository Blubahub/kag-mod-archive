
#include "HumanoidCommon.as";
#include "EquipCommon.as";
#include "EquipAnim.as";

const f32 Scale = 1.0f;
const f32 PosScale = Scale*2.0f;

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	if(getLocalPlayer() !is player)return;

}
