
#include "Health.as";
#include "MakeMat.as";

bool addIngrediant(CBlob @this, CBlob @ingrediant){
	if(this is null || ingrediant is null)return false;
	
	string name = ingrediant.getName();
	
	if(name == "log"){
		adjustChem(this,"sap_amount",20);
		ingrediant.server_Die();
		return true;
	}

	if(name == "seed"){
		adjustChem(this,"sap_amount",5);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "grain"){
		adjustChem(this,"starch_amount",5);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "steak"){
		adjustChem(this,"meat_amount",10);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "cooked_steak"){
		adjustChem(this,"meat_amount",8);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "fishy"){
		adjustChem(this,"meat_amount",5);
		adjustChem(this,"life_amount",5);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "chicken"){
		adjustChem(this,"meat_amount",20);
		adjustChem(this,"life_amount",10);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "egg"){
		adjustChem(this,"meat_amount",5);
		adjustChem(this,"life_amount",1);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "caged_chicken"){
		adjustChem(this,"meat_amount",20);
		adjustChem(this,"life_amount",10);
		adjustChem(this,"wood_amount",20);
		ingrediant.Tag("no_chicken");
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "landfish"){
		adjustChem(this,"meat_amount",20);
		adjustChem(this,"life_amount",10);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "mat_wood"){
		adjustChem(this,"wood_amount",ingrediant.getQuantity()/10);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "lantern"){
		adjustChem(this,"wood_amount",10);
		adjustChem(this,"heat",10);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "crate"){
		adjustChem(this,"wood_amount",20);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "cage"){
		adjustChem(this,"wood_amount",20);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "ward"){
		adjustChem(this,"wood_amount",20);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "mat_stone"){
		adjustChem(this,"stone_amount",ingrediant.getQuantity()/5);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "boulder"){
		adjustChem(this,"stone_amount",20);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "key"){
		adjustChem(this,"stone_amount",5);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "mat_gold"){
		adjustChem(this,"gold_amount",ingrediant.getQuantity()/5);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "bucket"){
		adjustChem(this,"water_amount",ingrediant.get_u8("filled")*20);
		ingrediant.set_u8("filled", 0);
		return false;
	}
	
	if(name == "slime"){
		f32 mod = 1;
		if(ingrediant.hasTag("baby"))mod = 0.5;
		adjustChem(this,"sap_amount",20*mod);
		adjustChem(this,"life_amount",10*mod);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "wisp"){
		adjustChem(this,"life_amount",10);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "caged_wisp"){
		adjustChem(this,"life_amount",10);
		adjustChem(this,"wood_amount",20);
		ingrediant.Tag("no_wisp");
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "caged_slime"){
		adjustChem(this,"life_amount",10);
		adjustChem(this,"sap_amount",20);
		adjustChem(this,"wood_amount",20);
		ingrediant.Tag("no_slime");
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "corruption_orb"){
		adjustChem(this,"corruption_amount",100);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "shadowblade"){
		adjustChem(this,"corruption_amount",50);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "soup"){
		Transfer(ingrediant,this,30);
		ingrediant.server_Die();
		return true;
	}
	
	if(name == "ectoplasm"){
		adjustChem(this,"death_amount",ingrediant.getQuantity());
		ingrediant.server_Die();
		return true;
	}
	

	return false;

}

void adjustChem(CBlob @this, string name, int amount){
	this.set_u8(name, this.get_u8(name)+amount);
	this.Sync(name,true);
}


bool isFilled(CBlob @this){
	int Max = this.get_u8("max_amount");
	
	int amount = 0;
	
	amount += this.get_u8("water_amount");
	amount += this.get_u8("starch_amount");
	amount += this.get_u8("meat_amount");
	amount += this.get_u8("burn_amount");
	amount += this.get_u8("wood_amount");
	amount += this.get_u8("stone_amount");
	amount += this.get_u8("gold_amount");
	amount += this.get_u8("sap_amount");
	amount += this.get_u8("life_amount");
	amount += this.get_u8("death_amount");
	amount += this.get_u8("corruption_amount");
	for(uint i = 0; i < 100; i += 1)amount += this.get_u8("potion["+i+"]_amount");
	
	if(amount >= Max)return true;
	return false;
}

bool isEmpty(CBlob @this){
	int amount = 0;
	
	amount += this.get_u8("water_amount");
	amount += this.get_u8("starch_amount");
	amount += this.get_u8("meat_amount");
	amount += this.get_u8("burn_amount");
	amount += this.get_u8("wood_amount");
	amount += this.get_u8("stone_amount");
	amount += this.get_u8("gold_amount");
	amount += this.get_u8("sap_amount");
	amount += this.get_u8("life_amount");
	amount += this.get_u8("death_amount");
	amount += this.get_u8("corruption_amount");
	for(uint i = 0; i < 100; i += 1)amount += this.get_u8("potion["+i+"]_amount");
	
	if(amount <= 0)return true;
	return false;
}

int getAmount(CBlob @this){
	int amount = 0;
	
	amount += this.get_u8("water_amount");
	amount += this.get_u8("starch_amount");
	amount += this.get_u8("meat_amount");
	amount += this.get_u8("burn_amount");
	amount += this.get_u8("wood_amount");
	amount += this.get_u8("stone_amount");
	amount += this.get_u8("gold_amount");
	amount += this.get_u8("sap_amount");
	amount += this.get_u8("life_amount");
	amount += this.get_u8("death_amount");
	amount += this.get_u8("corruption_amount");
	for(uint i = 0; i < 100; i += 1)amount += this.get_u8("potion["+i+"]_amount");
	
	return amount;
}

void Transfer(CBlob @this, CBlob @target, int amount){

	f32 Max = getAmount(this);
	if(Max == 0)return;
	
	{
		string name = "water_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "starch_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "burn_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "meat_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "gold_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "stone_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "wood_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "sap_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "life_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "corruption_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	{
		string name = "death_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}
	for(uint i = 0; i < 100; i += 1)
	{
		string name = "potion["+i+"]_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
		adjustChem(target,name,Transfer);
	}

}

void applyEffects(CBlob @this, CBlob @Target){
	int starch = this.get_u8("starch_amount");
	
	if(this.get_u8("heat") > Target.get_u8("heat"))Target.set_u8("heat",this.get_u8("heat"));
	
	if(starch == 0){
		Heal(Target,this.get_u8("meat_amount")/5);
	} else {
		OverHeal(Target,Maths::Min(this.get_u8("meat_amount")/5,starch/5));
	}

	Target.set_s16("poison",(this.get_u8("burn_amount")+this.get_u8("wood_amount")+this.get_u8("sap_amount")-starch)/5);
	
	OverHeal(Target,-((this.get_u8("stone_amount")+this.get_u8("gold_amount"))/5));

	if(this.get_u8("meat_amount") <= 0)Target.set_s16("life",Target.get_s16("life")+this.get_u8("life_amount"));
	Target.set_s16("death",Target.get_s16("death")+this.get_u8("death_amount"));
	
	Target.set_s16("corruption",Target.get_s16("corruption")+this.get_u8("corruption_amount"));
	
	Target.Sync("corruption",true);
	Target.Sync("life",true);
	Target.Sync("death",true);
	
	Heal(Target,this.get_u8("potion[0]_amount")/5);
	Heal(Target,this.get_u8("potion[1]_amount")/5);
}

void Dump(CBlob @this){
	if(getNet().isServer()){
		for(uint i = 0; i < 100; i += 1){
			if(XORRandom(2) == 0){
				if(this.get_u8("sap_amount") >= 20)
				if(this.get_u8("life_amount") >= 10){
					server_CreateBlob("slime", -1, this.getPosition()+Vec2f(0,-8));
					adjustChem(this,"sap_amount",-20);
					adjustChem(this,"life_amount",-10);
				}
			} else {
				if(this.get_u8("sap_amount") >= 10)
				if(this.get_u8("life_amount") >= 5){
					CBlob @slime = server_CreateBlob("slime", -1, this.getPosition()+Vec2f(0,-8));
					slime.Tag("baby");
					adjustChem(this,"sap_amount",-10);
					adjustChem(this,"life_amount",-5);
				}
			}
			
			if(this.get_u8("potion[1]_amount") >= 10){
				server_CreateBlob("bread", -1, this.getPosition()+Vec2f(0,-8));
				adjustChem(this,"potion[1]_amount",-10);
			}
		}
		
		if(this.get_u8("meat_amount") <= 0)
		for(uint i = 0; i < 20; i += 1)
		if(this.get_u8("life_amount") >= 10){
			server_CreateBlob("wisp", -1, this.getPosition()+Vec2f(0,-8));
			adjustChem(this,"life_amount",-10);
		}
	}
	
	MakeMat(this, this.getPosition(), "mat_stone", this.get_u8("stone_amount")*5);
	MakeMat(this, this.getPosition(), "mat_gold", this.get_u8("gold_amount")*5);
	MakeMat(this, this.getPosition(), "mat_wood", this.get_u8("wood_amount")*10);
	
	this.set_u8("water_amount", 0);
	this.set_u8("starch_amount", 0);
	this.set_u8("meat_amount", 0);
	this.set_u8("burn_amount", 0);
	this.set_u8("wood_amount", 0);
	this.set_u8("stone_amount", 0);
	this.set_u8("gold_amount", 0);
	this.set_u8("sap_amount", 0);
	this.set_u8("life_amount", 0);
	this.set_u8("death_amount", 0);
	this.set_u8("corruption_amount", 0);
	for(uint i = 0; i < 100; i += 1)this.set_u8("potion["+i+"]_amount", 0);
}


void Spill(CBlob @this, int amount){

	f32 Max = getAmount(this);
	if(Max == 0)return;
	
	{
		string name = "water_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "starch_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "burn_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "meat_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "gold_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "stone_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "wood_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "sap_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "life_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "corruption_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	{
		string name = "death_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}
	for(uint i = 0; i < 100; i += 1)
	{
		string name = "potion["+i+"]_amount";
		int Transfer = amount*(this.get_u8(name)/Max);
		adjustChem(this,name,-Transfer);
	}

}