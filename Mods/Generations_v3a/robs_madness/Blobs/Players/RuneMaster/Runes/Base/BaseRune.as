// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	
	this.Tag("place norotate");

	this.set_TileType("background tile", CMap::tile_castle);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.Tag("builder always hit");
	
	this.Tag("runeblock");
	
	//this.Tag("dead");
	
	int ID = -1;
	
	string runeblock = "runeblock";
	
	if(this.getName() == "fire"+runeblock)ID = 0;
	if(this.getName() == "water"+runeblock)ID = 1;
	if(this.getName() == "earth"+runeblock)ID = 2;
	if(this.getName() == "air"+runeblock)ID = 3;
	
	if(this.getName() == "consume"+runeblock)ID = 4;
	if(this.getName() == "grow"+runeblock)ID = 5;
	if(this.getName() == "space"+runeblock)ID = 6;
	if(this.getName() == "time"+runeblock)ID = 7;
	
	if(this.getName() == "light"+runeblock)ID = 8;
	if(this.getName() == "life"+runeblock)ID = 9;
	if(this.getName() == "restore"+runeblock)ID = 10;
	if(this.getName() == "order"+runeblock)ID = 11;
	
	if(this.getName() == "dark"+runeblock)ID = 12;
	if(this.getName() == "death"+runeblock)ID = 13;
	if(this.getName() == "decay"+runeblock)ID = 14;
	if(this.getName() == "chaos"+runeblock)ID = 15;
	
	this.getSprite().SetFrame(ID);
	
	this.set_s8("rune_ID",ID);
}

void onTick(CBlob@ this)
{
	this.getSprite().SetZ(1000);
	
	if(!this.getShape().isStatic())return;
	
	int dead = 0;
	
	if(this.hasTag("dead")){
		dead = 16;
		this.SetLight(false);
		this.getSprite().SetLighting(true);
	} else {
		this.getSprite().SetLighting(false);
		this.SetLight(true);
		this.SetLightRadius(32.0f);
		this.SetLightColor(SColor(255, 255, 255, 255));
	}
	
	if(this.get_s8("rune_ID") != -1){
		this.Tag("dead");
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("triggerrune") && b.getShape().isStatic()){
					if(!b.hasTag("dead"))this.Untag("dead");
				}
			}
		}
		
		this.getSprite().SetFrame(this.get_s8("rune_ID")+dead);
	}

	if(this.hasTag("set_background"))if(!getMap().isTileSolid(getMap().getTile(this.getPosition())))this.server_Die();
	
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	if(this.getShape().isStatic()){
		CBlob@ blob = server_CreateBlob("mat_gold", this.getTeamNum(), this.getPosition());
		if (blob !is null)
		{
			blob.server_SetQuantity(8);
			if(this.getName() == "curseruneblock")blob.server_SetQuantity(40);
			if(this.getName() == "witnessruneblock")blob.server_SetQuantity(180);
		}
	}
}

