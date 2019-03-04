#include "ItemsCommon.as";

f32 DamageMultiplier(CBlob @this){
	f32 Dmg = 1;
	
	Dmg *= SwordDamageMultiplier(this);
	
	if(this.get_s16("weakend") > 0)Dmg *= 0.5;
	
	if(this.get_s16("blood_strength") > 0)Dmg *= 1.5;
	
	return Dmg;
}