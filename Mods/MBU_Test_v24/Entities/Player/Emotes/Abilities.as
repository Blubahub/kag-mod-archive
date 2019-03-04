
#include "AbilityCommon.as"

void UseAbilityClient(CBlob @this, int abilityID){
	if(getNet().isClient()){
		CBitStream params;
		params.write_u8(abilityID);
		this.SendCommand(this.getCommandID("use_ability"),params);
	}
}

void UseAbility(CBlob @this, int abilityID){
	//Ability[] @abilities;
	//getRules().get("abilities", @abilities);
	if(abilityID < abilities.length){
		Ability ability = abilities[abilityID];
		
		
		ability.script(this);
	}
}


