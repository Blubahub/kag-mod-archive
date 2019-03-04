///Casuals'OTPS.txt

int checkRelationshipTotal(CBlob @this, CBlob @blob){

	int relationship = 0;

	if(lovesThing(this,blob.getName()))relationship += 50;
	if(hatesThing(this,blob.getName()))relationship -= 50;

	relationship += checkRelationship(this,blob);
	
	return relationship;
}

int checkRelationship(CBlob @this, CBlob @blob){
	
	int relationship = 0;

	if(this.exists("ship_"+blob.getNetworkID()))relationship += this.get_s8("ship_"+blob.getNetworkID());
	
	return relationship;
}

bool lovesThing(CBlob @this, string thing){
	string[] @thingsILove;
	if(!this.get("blobLove",@thingsILove))return false;
	
	if(thingsILove.find(thing) >= 0)return true;
	
	return false;
}
bool hatesThing(CBlob @this, string thing){
	string[] @thingsIHate;
	if(!this.get("blobHate",@thingsIHate))return false;
	
	if(thingsIHate.find(thing) >= 0)return true;
	
	return false;
}

void setRelationship(CBlob @this, CBlob @blob, int amount){

	this.set_s8("ship_"+blob.getNetworkID(),amount);
	//print("Set relationship between "+this.getName()+" and "+blob.getName()+" to "+amount+", current amount:"+checkRelationshipTotal(this,blob));
	
}

void editRelationship(CBlob @this, CBlob @blob, int amount){

	if(this.exists("ship_"+blob.getNetworkID()))this.set_s8("ship_"+blob.getNetworkID(),this.get_s8("ship_"+blob.getNetworkID())+amount);
	else this.set_s8("ship_"+blob.getNetworkID(),amount);
	
	if(this.get_s8("ship_"+blob.getNetworkID()) > 100)this.set_s8("ship_"+blob.getNetworkID(),100);
	if(this.get_s8("ship_"+blob.getNetworkID()) < -100)this.set_s8("ship_"+blob.getNetworkID(),-100);
	
	//print("Editted relationship between "+this.getName()+" and "+blob.getName()+" by "+amount+", current amount:"+checkRelationshipTotal(this,blob));
}

void addHateThing(CBlob @this, string thing){

	string[] @thingsIHate;

	if(!this.get("blobHate",@thingsIHate))return;
	
	thingsIHate.push_back(thing);
	
	this.set("blobHate",thingsIHate);
	
}

void addLoveThing(CBlob @this, string thing){

	string[] @thingsILove;

	if(!this.get("blobLove",@thingsILove))return;
	
	thingsILove.push_back(thing);
	
	this.set("blobLove",thingsILove);
	
}