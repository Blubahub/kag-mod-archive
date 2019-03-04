#include "MakeMat.as";
#include "ParticleSparks.as";
#include "Hitters.as";
#include "ModHitters.as";
#include "PaletteSwap.as";
#include "Fabrics.as";
#include "Knocked.as";
#include "li.as";

void onInit(CBlob @this){
	
	this.set_u8("fabric",0);
	
	this.getSprite().AddScript("EquipmentLogic.as");
	
	this.set_u8("speed",5);

}


void onTick(CBlob @this){
	
	if(this.getCurrentScript().tickFrequency != 180){
		
		InitFabric(this,this.get_u8("fabric"));
		
		this.getCurrentScript().tickFrequency = 180;
	}

}





void onTick( CSprite@ this ){
	CBlob @blob = this.getBlob();
	if(blob !is null){
		string name = blob.getName();
		
		int Material = blob.get_u8("fabric");
		
		if(blob.get_string("sprite_mat") != name+"_"+Material){

			blob.set_string("sprite_mat",name+"_"+Material);
		
			if(Material != 0){
			
				string tex = name+"_"+Material;
				
				if(!Texture::exists(tex))Texture::createFromFile(tex, this.getFilename());
				
				string spr = PaletteSwapTexture(tex, "FabricPalette.png", Material);
			
				this.SetTexture(spr);
			}
		}
	}
}







class HarvestBlobsPair
{
	string name;
	f32 amount_wood;
	f32 amount_stone;
	HarvestBlobsPair(string blobname, f32 wood, f32 stone)
	{
		name = blobname;
		amount_wood = wood;
		amount_stone = stone;
	}
};

HarvestBlobsPair[] pairs =
{
	HarvestBlobsPair("log", 5.0f, 0.0f),
	HarvestBlobsPair("stick", 5.0f, 0.0f),
	HarvestBlobsPair("wooden_door", 5.0f, 0.0f),
	HarvestBlobsPair("stone_door", 0.0f, 5.0f),
	HarvestBlobsPair("trap_block", 0.0f, 2.5f),
};

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (!getNet().isServer() || hitBlob is null)
		return;

		
	if(this.hasTag("light_infused")){
		if(customData != Hitters::heal_light){
			restore(this,hitBlob,damage*2.0f);
		}
		this.Untag("dark_infused");
		this.Untag("cursed");
	} else {
		if(this.hasTag("death_infused"))
		if(customData != Hitters::ethereal_echo){
			this.server_Hit(hitBlob, worldPoint, Vec2f(0,0), this.get_f32("damage"), Hitters::ethereal_echo, true);
		} else return;
	}
	///MAKE SURE HITTERS DON'T CAUSE INFINITE LOOPS
	
	
	if(customData == Hitters::saw || customData == Hitters::axe || customData == Hitters::builder)
	if (damage > 0.0f)
	{
		string name = hitBlob.getName();

		CBlob @inv_blob = this;
	
		if(this.getInventoryBlob() !is null)@inv_blob = this.getInventoryBlob();
		
		int wood = 0;
		int stone = 0;
		for (uint i = 0; i < pairs.length; i++)
		{
			if (pairs[i].name == name)
			{
				stone = pairs[i].amount_stone;
				wood = pairs[i].amount_wood;
				break;
			}
		}
		
		f32 amount = Maths::Max(Maths::Min(damage,hitBlob.getHealth()+damage),0);

		if (wood > 0)
		{
			MakeMat(inv_blob, worldPoint, "mat_wood", wood*amount);
		}
		if (stone > 0)
		{
			MakeMat(inv_blob, worldPoint, "mat_stone", stone*amount);
		}
	}
}


void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (damage < 1.0f) return;

	CMap@ map = getMap();

	for(int i = 0;i < damage; i++){
	
		TileType tile = map.getTile(worldPoint).type;
		
		CBlob @inv_blob = this;
		
		if(this.getInventoryBlob() !is null)@inv_blob = this.getInventoryBlob();
		
		if(customData == Hitters::saw || customData == Hitters::axe)
		if (!map.isTileWood(tile) && !(tile >= 205 && tile <= 207)){
			return;
		}
		
		if (customData != Hitters::builder && customData != Hitters::saw && customData != Hitters::axe && customData != Hitters::pick){
			map.server_DestroyTile(worldPoint, damage, this);
			return;
		}
		
		if (getNet().isClient())
		{
			TileType tile = map.getTile(worldPoint).type;
			// hit bedrock
			if (map.isTileBedrock(tile))
			{
				this.getSprite().PlaySound("/metal_stone.ogg");
				sparks(worldPoint, velocity.Angle(), damage);
			}
			
			if (map.isTileSolid(tile))
			{
				if (map.isTileCastle(tile))
				{
					if(customData == Hitters::pick)SetKnocked(inv_blob,30,false);
				}
			}
		}

		if (getNet().isServer())
		{
			TileType tile = map.getTile(worldPoint).type;

			map.server_DestroyTile(worldPoint, damage, this);
			
			// spawn materials
			if (map.isTileStone(tile))
			{
				if (XORRandom(20) == 0)
				{
					inv_blob.server_PutInInventory(server_CreateBlob("metal_ore", this.getTeamNum(), this.getPosition()));
				}
				
				if (map.isTileThickStone(tile))
					MakeMat(inv_blob, worldPoint, "mat_stone", 5);
				else
					MakeMat(inv_blob, worldPoint, "mat_stone", 3);
			}
			else if (map.isTileGold(tile))
			{
				if (XORRandom(4) == 0){
					CBlob @gold = server_CreateBlob("gold_ore", this.getTeamNum(), this.getPosition());
					if (XORRandom(2) == 0)gold.Tag("light_infused");
					inv_blob.server_PutInInventory(gold);
				}
			}
			else
			if (map.isTileGroundStuff(tile))
			{
				MakeMat(inv_blob, worldPoint, "mat_dirt", 1);
			}
			else
			if (map.isTileSolid(tile))
			{
				if (map.isTileCastle(tile))
				{
					MakeMat(inv_blob, worldPoint, "mat_stone", 1);
					if(customData == Hitters::pick)SetKnocked(inv_blob,30,true);
					break;
				}
				else if (map.isTileWood(tile))
				{
					MakeMat(inv_blob, worldPoint, "mat_wood", 1);
					break;
				}
			}
			
			
		}
	
	}
}