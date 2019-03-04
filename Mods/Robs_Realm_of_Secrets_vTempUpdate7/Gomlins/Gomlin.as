
#include "AnimalConsts.as";
#include "Hitters.as";
#include "TribeCommon.as";

//sprite

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		f32 x = Maths::Abs(blob.getVelocity().x);
		if (blob.isAttached())
		{
			AttachmentPoint@ ap = blob.getAttachmentPoint(0);
			if (ap !is null && ap.getOccupied() !is null)
			{
				if (Maths::Abs(ap.getOccupied().getVelocity().y) > 0.2f)
				{
					this.SetAnimation("fly");
				}
				else
					this.SetAnimation("idle");
			}
		}
		else if (!blob.isOnGround())
		{
			this.SetAnimation("fly");
		}
		else if (x > 0.02f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			if (this.isAnimationEnded())
			{
				uint r = XORRandom(20);
				if (r == 0)
					this.SetAnimation("peck_twice");
				else if (r < 5)
					this.SetAnimation("peck");
				else
					this.SetAnimation("idle");
			}
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		this.PlaySound("/ScaredChicken");
		this.SetAnimation("dead");
	}
}

//blob

void onInit(CBlob@ this)
{

	//for shape
	this.getShape().SetRotationsAllowed(false);

	this.Tag("flesh");

	this.getShape().SetOffset(Vec2f(0, 6));
	
	this.getBrain().server_SetActive(true);
	
	this.set_u8("workstate",0);
	//0 - nothing
	//1 - dig
	//2 - build
	
	this.set_s16("blocktype",48);
	
	this.set_u8("direction",0+XORRandom(2)*2);
	this.set_s16("direction_changer",0);
	
	this.setAimPos(this.getPosition());
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("flesh");
}

void onTick(CBlob@ this)
{
	if(!this.hasTag("dead")){
		f32 x = this.getVelocity().x;
		if (Maths::Abs(x) > 1.0f)
		{
			this.SetFacingLeft(x < 0);
		} else {
			if (this.isKeyPressed(key_left))
			{
				this.SetFacingLeft(true);
			}
			if (this.isKeyPressed(key_right))
			{
				this.SetFacingLeft(false);
			}
		}
		
		if(this.get_u8("workstate") == 1){
			if(!getMap().isTileSolid(this.getAimPos())){
				this.set_u8("workstate",0);
			} else {
				getMap().server_SetTile(this.getAimPos(), 0);
				this.set_u8("workstate",0);
			}
		}
		
		if(this.get_u8("workstate") == 2){
			getMap().server_SetTile(this.getAimPos(), this.get_s16("blocktype"));
			this.set_u8("workstate",0);
		}
		
	}
	
	if(this.get_s16("direction_changer") > 0)this.set_s16("direction_changer",this.get_s16("direction_changer")-1);
	
	if(this.getHealth() < 1.0){
		this.Tag("dead");
	}
}

void onTick(CBrain@ this)
{
	CBlob @blob = this.getBlob();
	
	int GridSize = 6;
	
	TribeInfo @tribe;
	
	CBlob@[] blobs;	   
	if (getBlobsByName("gomlin_tribe", @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b.get_string("TribeName") == blob.get_string("TribeName"))
			{
				if (!b.get("TribeInfo", @tribe))
					return;
			}
		}
		if(blobs.length <= 0)return;
	} else return;
	if(tribe is null)return;
	
	if(blob.get_s16("direction_changer") <= 0){
		int X = blob.getPosition().x/8;
		int Y = (blob.getPosition().y+4)/8;
		
		if(X % GridSize == 0 && Y % GridSize == 0){blob.set_u8("direction",XORRandom(4));blob.set_s16("direction_changer",30);}
		else if(X % GridSize == 0){blob.set_u8("direction",XORRandom(2)*2+1);blob.set_s16("direction_changer",30);}
		else if(Y % GridSize == 0){blob.set_u8("direction",XORRandom(2)*2);blob.set_s16("direction_changer",30);}
	}
	
	if(blob.get_u8("direction") == 4)blob.set_u8("direction",XORRandom(4));
	
	if(blob.get_u8("direction") == 2)blob.setKeyPressed(key_left, true);
	if(blob.get_u8("direction") == 0)blob.setKeyPressed(key_right, true);
	if(blob.get_u8("direction") == 1)blob.setKeyPressed(key_up, true);
	if(blob.get_u8("direction") == 3)blob.setKeyPressed(key_down, true);
	
	if(blob.get_u8("workstate") == 0){
		CMap @ map = getMap();
		int W = getMap().tilemapwidth;
		int H = getMap().tilemapheight;
		
		for(int i = -2; i <= 2; i += 1)
		for(int j = -2; j <= 2; j += 1){
			Vec2f pos = Vec2f(blob.getPosition().x+i*8,blob.getPosition().y+4+j*8);
			int X = blob.getPosition().x/8+i;
			int Y = (blob.getPosition().y+4)/8+j;

			if(X >= W-1 || Y >= H-1 || X <= 1 || Y <= 1)continue;
			
			Tile tile = map.getTile(pos);
			
			if(tribe.TribePlan[X][Y] > 0){
				
				if(tribe.TribePlan[X][Y] == 1 || tribe.TribePlan[X][Y] == 2){
					if(!map.isTileCastle(tile.type) && map.isTileSolid(pos)){
						blob.set_u8("workstate",1);
						blob.setAimPos(pos);
						return;
					} else
					if(!map.isTileCastle(tile.type) && i != 0 && j != 0){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",48);
						blob.setAimPos(pos);
						return;
					} else 
					if(map.isTileCastle(tile.type) && !map.isTileSolid(pos)){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",48);
						blob.setAimPos(pos);
						return;
					}
				}
				
				if(tribe.TribePlan[X][Y] == 3 || tribe.TribePlan[X][Y] == 4){
					if(!map.isTileWood(tile.type) && map.isTileSolid(pos)){
						blob.set_u8("workstate",1);
						blob.setAimPos(pos);
						return;
					} else
					if(!map.isTileWood(tile.type) && i != 0 && j != 0){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",196);
						blob.setAimPos(pos);
						return;
					} else 
					if(map.isTileWood(tile.type) && !map.isTileSolid(pos)){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",196);
						blob.setAimPos(pos);
						return;
					}
				}
				
				if(tribe.TribePlan[X][Y] == 5){
					if(tile.type != 144 && map.isTileSolid(pos)){
						blob.set_u8("workstate",1);
						blob.setAimPos(pos);
						return;
					} else
					if(tile.type != 144){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",144);
						blob.setAimPos(pos);
						return;
					}
				}
				
				if(tribe.TribePlan[X][Y] == 6){
					if(tile.type != 64 && map.isTileSolid(pos)){
						blob.set_u8("workstate",1);
						blob.setAimPos(pos);
						return;
					} else
					if(tile.type != 64){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",64);
						blob.setAimPos(pos);
						return;
					}
				}
				
				if(tribe.TribePlan[X][Y] == 7){
					if(tile.type != 205 && map.isTileSolid(pos)){
						blob.set_u8("workstate",1);
						blob.setAimPos(pos);
						return;
					} else
					if(tile.type != 205){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",205);
						blob.setAimPos(pos);
						return;
					}
				}
				
				if(tribe.TribePlan[X][Y] == 8){
					if(!map.isTileWood(tile.type) && map.isTileSolid(pos)){
						blob.set_u8("workstate",1);
						blob.setAimPos(pos);
						return;
					} else
					if(!map.isTileWood(tile.type)){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",196);
						blob.setAimPos(pos);
						return;
					} else 
					if(map.isTileWood(tile.type) && !map.isTileSolid(pos)){
						blob.set_u8("workstate",2);
						blob.set_s16("blocktype",196);
						blob.setAimPos(pos);
						return;
					}
				}
			}
		}
	}
	
}