
#include "Hitters.as";
#include "ModHitters.as";

bool isTwoHanded(CBlob @item){

	if(item is null)return false;

	if(item.hasTag("two_handed"))return true;
	
	return false;
}

CBlob@ getEquippedBlob(CBlob @this, string equip){

	CInventory @inv = this.getInventory();

	if(inv !is null)
	for(int i = 0;i < inv.getItemsCount();i++){
		CBlob @blob = inv.getItem(i);
		if(blob.hasTag(equip))return blob;
	}
	
	return null;
}

bool putInInventory(CBlob @this, CBlob @item){
	
	CInventory @inv = this.getInventory();

	if(inv !is null)
	for(int i = 0;i < inv.getItemsCount();i++){
		CBlob @blob = inv.getItem(i);
		if(blob !is null){
			CInventory @bag = blob.getInventory();
			if(bag !is null){
				if(getNet().isServer()){
					if(bag.canPutItem(item))
					if(blob.server_PutInInventory(item))return true;
				} else {
					if(bag.canPutItem(item))return true;
				}
			}
		}
	}
	
	return false;
}

bool hasSharpTool(CBlob @this){
	CBlob@ hold = this.getCarriedBlob();
	if(hold !is null)if(hold.hasTag("sharp"))return true;
	
	if(this.getName() == "humanoid"){
		CBlob@ item1 = getEquippedBlob(this,"main_arm");
		if(item1 !is null)if(item1.hasTag("sharp"))return true;
		
		CBlob@ item2 = getEquippedBlob(this,"sub_arm");
		if(item2 !is null)if(item2.hasTag("sharp"))return true;
	}
	
	return false;
}

int calculateDamage(int damage, int defense, u8 hitter){
	
	if(isBluntDamage(hitter))return damage;
	
	if(isSlashDamage(hitter))return Maths::Max(damage-defense,0);
	
	if(isPierceDamage(hitter))return Maths::Max(damage-Maths::Max(defense-XORRandom(Maths::Min(damage+1,defense+1)),0),0);
	
	return damage;
}

bool isSlashDamage(u8 hitter){
	if(hitter == Hitters::slash)return true;
	
	if(hitter == Hitters::sword)return true;
	if(hitter == Hitters::saw)return true;
	if(hitter == Hitters::axe)return true;
	
	return false;
}

bool isPierceDamage(u8 hitter){
	if(hitter == Hitters::pierce)return true;
	
	if(hitter == Hitters::bite)return true;
	if(hitter == Hitters::stab)return true;
	if(hitter == Hitters::arrow)return true;
	if(hitter == Hitters::ballista)return true;
	if(hitter == Hitters::spikes)return true;
	if(hitter == Hitters::drill)return true;
	if(hitter == Hitters::pick)return true;
	
	if(hitter == Hitters::bullet)return true;
	
	return false;
}

bool isBluntDamage(u8 hitter){
	if(hitter == Hitters::blunt)return true;
	
	if(hitter == Hitters::crush)return true;
	if(hitter == Hitters::fall)return true;
	if(hitter == Hitters::stomp)return true;
	if(hitter == Hitters::builder)return true;
	if(hitter == Hitters::shield)return true;
	if(hitter == Hitters::cata_boulder)return true;
	if(hitter == Hitters::boulder)return true;
	if(hitter == Hitters::ram)return true;
	if(hitter == Hitters::muscles)return true;
	
	return false;
}

bool isSharp(u8 hitter){
	return isPierceDamage(hitter) || isSlashDamage(hitter);
}