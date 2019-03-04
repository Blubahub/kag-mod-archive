
#include "EquipCommon.as";

void ReloadEquipment(CSprite @this, CBlob @blob){

	if(blob is null)return;

	ReloadBack(this, blob);

}


void ReloadBack(CSprite @this, CBlob @blob){

	this.RemoveSpriteLayer("back");
	
	string name = "";
	
	if(getEquippedBlob(blob, "back") !is null)
	name = getEquippedBlob(blob, "back").getName();
	
	if(name == "sack"){
		CSpriteLayer@ layer = this.addSpriteLayer("back", "CharacterSack.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(Vec2f(0,0));
			layer.SetRelativeZ(2.5f);
			layer.SetFacingLeft(this.isFacingLeft());
		}
	}
	
	if(name == "barrel"){
		CSpriteLayer@ layer = this.addSpriteLayer("back", "CharacterBarrel.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			layer.SetOffset(Vec2f(0,0));
			layer.SetRelativeZ(-3.5f);
			layer.SetFacingLeft(this.isFacingLeft());
		}
	}

}