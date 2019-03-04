#include "EquipCommon.as";

class Fabric
{
	//General info
	string name;
	string prefix;
	string tag;
	string blob_name;
	
	//Statistics
	f32 weight = 1.0f; //The heavier a metal, the slower it swings, however, this is really good for blunt damage
	f32 hardness = 1.0f; //How hard the metal is. Softer metal bends, harder metal snaps. Equivalent to IRL brittleness/plasticity
	f32 strength = 1.0f; //How much the metal can withstand before bending/breaking/chipping. Equivalent to IRL durability/stiffness

	//Speed is calculated as base_speed-weight (minimum 1)
	//Blunt damage is base_damage*weight
	//Pierce damage is base_damage*hardness*(0.5+0.5*strength)
	//Slash damage is base_damage*strength*hardness*(0.5+0.5*weight)
	
	Fabric(string name, string prefix, string tag, string blob_name, f32 weight, f32 hardness, f32 strength)
	{
		this.name = name;
		this.prefix = prefix;
		this.tag = tag;
		this.blob_name = blob_name;
		
		this.weight = weight;
		this.hardness = hardness;
		this.strength = strength;
	}
}

Fabric[] Fabrics = {
	Fabric("Nothing", "", "none", "none", 1.0f, 1.0f, 1.0f), //Just an empty material
	Fabric("Stone", "Stone", "stone", "none", 1.0f, 2.0f, 0.5f), //Stone is a pretty basic fabric, the standard weight, pretty hard, but easy to break.
	Fabric("Metal", "Metal", "metal", "metal_bar", 2.0f, 1.0f, 1.0f), //Metal is used as the standard for hardness and strength. irl, iron is 3 times heavier than stone, that's a bit much considering the damage and speed calculations
	Fabric("Duram", "Duram", "duram", "duram_bar", 2.0f, 2.0f, 1.0f), //Based on the old 'hardened metal', which pretty much lives up to it's name, just metal but harder.
	Fabric("Gold", "Golden", "gold", "gold_bar", 4.0f, 0.5f, 0.5f), //Gold, the uselessly heavy soft metal. Makes for good bling and hammers, and that's about it.
	Fabric("Lecit", "Lecite", "lecit", "lecit_bar", 3.0f, 0.75f, 0.75f), //Lecit, the first alloy. As a mix of metal and gold, it's almost more useless than gold. It's primary use is electronics.
	Fabric("Slag", "Dirty", "slag", "metal_drop_dirty", 0.5f, 3.0f, 0.5f), //Slag, also known as dirtied metal, is sort of a dirt, stone and metal alloy. Would be near useless being so brittle and light, however it's unusually hard.
	Fabric("Floating Gold", "Floating Gold", "gold", "none", 4.0f, 0.5f, 0.5f), //Floating gold. A significantly improve version of normal gold. Has 0 effect on speed, making it the fastest metal. Actually DECREASES the weight of the character.
	Fabric("Wood", "Wooden", "wooden", "log", 0.5f, 0.25f, 0.5f), //The worst material, surpassing even gold in uselessness. Good for sparring maybe? This mostly exists as a joke/easter egg.
	Fabric("Darkness", "Dark", "darkened", "co", 0.5f, 2.0f, 2.0f), //Insanely good material
};

enum FabricID {

	Stone = 1,
	Metal,
	Duram,
	Gold,
	Lecit,
	Slag,
	FloatingGold,
	Wood,
	Dark,
	Amount,

};

void InitFabric(CBlob @this, int f_index){

	if(f_index == 0)return;
	
	Fabric @fabric = Fabrics[f_index];
	
	this.Tag(fabric.tag);
	
	if(!getNet().isServer())return;

	this.setInventoryName(fabric.prefix+" "+this.getInventoryName());
	
	f32 speed_weight = fabric.weight;
	f32 mass_weight = fabric.weight;
	
	if(f_index == FabricID::FloatingGold)speed_weight = -1.0f;
	
	f32 speed = 1.0f - this.get_f32("speed_modifier");
	speed *= speed_weight;
	this.set_f32("speed_modifier",1.0f-speed);
	
	f32 damage = this.get_f32("damage");
	
	if(this.exists("hitter")){
	
		int hitter = this.get_u8("hitter");
		
		if(isSlashDamage(hitter))damage = damage*fabric.strength*fabric.hardness*(0.5+0.5*mass_weight);
		if(isPierceDamage(hitter))damage = damage*fabric.hardness*(0.5+0.5*fabric.strength);
		if(isBluntDamage(hitter))damage = damage*mass_weight;
	
	} else {
		print("Warning: hitter not set for blob type: "+this.getName()+". Fabric damage modifiers cannot be applied. Contact Pirate-Rob to report this if necessary.");
	}
	
	this.set_f32("damage", damage);
	
	this.set_u8("speed",Maths::Max(1,this.get_u8("speed")-speed_weight));
	
	
	if(getNet().isServer()){
		this.Sync("damage",true);
		this.Sync("speed_modifier",true);
		this.Sync("speed",true);
	}
}

bool isValidFabric(string blob_name){
	for(int i = 1;i < FabricID::Amount;i++){
		if(Fabrics[i].blob_name == blob_name)return true;
	}
	return false;
}

int fabricIDFromBlobName(string blob_name){
	for(int i = 0;i < FabricID::Amount;i++){
		if(Fabrics[i].blob_name == blob_name)return i;
	}
	return 0;
}