
#include "AbilityData.as";

funcdef void AbilityScript(CBlob @this);
funcdef string IconScript(CBlob @this);

class Ability
{
	string name;
	AbilityScript @script;
	IconScript @image_script;
	string tag;
	string cooldown;
	string hover_text;
	bool humanoid_only;

	Ability(string name, AbilityScript @Script, IconScript @image_script, string tag, string cooldown, bool humanoid_only, string hover_text)
	{
		this.name = name;
		this.script = Script;
		this.image_script = image_script;
		this.tag = tag;
		this.cooldown = cooldown;
		this.hover_text = hover_text;
		this.humanoid_only = humanoid_only;
	}
}

void StartCooldown(CBlob @this, string CDName, int amount){
	if(CDName == "" || amount == 0)return;
	if(getNet().isServer()){
		this.set_u16(CDName,getGameTime()+amount);
		this.Sync(CDName,true);
	}
}

int CheckCooldown(CBlob @this, string CDName){
	if(CDName == "" || !this.exists(CDName))return 0;
	if(getNet().isServer()){
		this.Sync(CDName,true);
	}
	return Maths::Max(f32(this.get_u16(CDName))-f32(getGameTime()),0);
}

bool hasAbility(CBlob @this, string ability){
	if(this.hasTag(ability))return true;
	
	if(this.getPlayer() !is null)return this.getPlayer().hasTag(ability);
	
	return false;
}

void giveAbility(CBlob @this, string ability, string group = ""){
	if(!this.hasTag(ability)){
		this.Tag(ability);
		if(group != "")this.Tag(group+"_ability");
	}
	if(this.getPlayer() !is null)if(!this.getPlayer().hasTag(ability))this.getPlayer().Tag(ability);
}

void removeAbilities(CPlayer @player){
	for(int i = 0;i < abilities.length();i++){
		player.Untag(abilities[i].tag);
		if(getNet().isServer())player.Sync(abilities[i].tag,true);
	}
}