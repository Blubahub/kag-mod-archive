#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	
	if (blob !is null){
		string blobName = blob.getName();
		
		if (blobName == "shield")
		if(!this.hasTag("has_shield")){
			this.server_PutInInventory(blob);
		}
	}
	
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	string blobName = blob.getName();

	if (blobName == "mat_bombs" || (blobName == "satchel" && !blob.hasTag("exploding")) || blobName == "mat_waterbombs")
	{
		this.server_PutInInventory(blob);
	}
}


void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	const string itemname = blob.getName();
	
	if(itemname == "shield")if(!this.hasTag("has_shield")){
		if (getNet().isServer()){
			blob.server_Die();
			this.Tag("has_shield");
			this.Sync("has_shield",true);
			return;
		}
	}
}

void onDie(CBlob@ this){
	if (getNet().isServer()){
		if(this.hasTag("has_shield")){
			server_CreateBlob("shield", this.getTeamNum(), this.getPosition());
		}
	}
}