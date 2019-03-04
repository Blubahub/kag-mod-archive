#include "Ally.as";
#include "Knocked.as";
#include "HumanoidCommon.as";

void ManageShield(CBlob @this, CBlob @item, bool holding, string type){

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	if(holding){
		f32 angle = getAimAngle(this);
		
		if(angle > 45 && angle < 135){
			if(this.getVelocity().y > 0)this.getShape().SetGravityScale(this.getShape().getGravityScale()*0.2f);
		}
		if(angle > 270-45 && angle < 270+45)moveVars.jumpFactor *= 0.0f;
		else moveVars.jumpFactor *= 0.5f;
		this.Tag(type+"_shielding");
	} else {
		this.Untag(type+"_shielding");
	}
}

