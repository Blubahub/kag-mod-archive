
#include "AbilityCommon.as"

void onInit(CBlob @this){

	if(!this.exists("life_amount"))this.set_s16("life_amount", 0);
	
	this.Tag("life_tak");
	
	this.getCurrentScript().tickFrequency = 300;

}

void onTick(CBlob @this){

	int LifeAmount = this.get_s16("life_amount");

	
	if(LifeAmount >= this.get_s16("death_amount") && !this.hasTag("death_seed"))
	if(this.hasTag("alive")){
		if(LifeAmount < this.getInitialHealth()*10.0f)LifeAmount += 1;
	}
	
	if(this.hasTag("death_seed")){
		this.add_s16("death_amount",3);
		
		if(LifeAmount < this.get_s16("death_amount"))LifeAmount -= 1;
	}
	
	this.set_s16("life_amount", LifeAmount);
	if(getNet().isServer()){
		this.Sync("life_amount",true);
	}
	
	

	this.Untag("death_seed");
}
