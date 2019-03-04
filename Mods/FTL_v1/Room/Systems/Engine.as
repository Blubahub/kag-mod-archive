
void onInit(CBlob @ this){
	this.set_u8("MaxLevel",8);
}


void onTick(CBlob @ this)
{
	updateThrusterPosition(this);
}

void updateThrusterPosition(CBlob @ this)
{
	Vec2f Pos = this.getPosition()-Vec2f(this.getSprite().getFrameWidth()/2,this.getSprite().getFrameHeight()/2);

	int direction = -1;
	
	Vec2f LastGoodPosition = Vec2f(0,0);
	
	for(int i = direction;i != 100*direction;i += direction){
		
		if(!getMap().isTileSolid(getMap().getTile(Pos+Vec2f(i*8+4,4))) && !getMap().isTileSolid(getMap().getTile(Pos+Vec2f(i*8+4,12))))
		if(getMap().isTileSolid(getMap().getTile(Pos+Vec2f((i-direction)*8+4,4))) || getMap().isTileSolid(getMap().getTile(Pos+Vec2f((i-direction)*8+4,12)))){
		
			bool solid = false;
			
			CBlob@[] blobs;
			
			getMap().getBlobsAtPosition(Pos+Vec2f(i*8+4,4), @blobs);
			getMap().getBlobsAtPosition(Pos+Vec2f(i*8+4,12), @blobs);
			
			for (u32 k = 0; k < blobs.length; k++)
			{
				CBlob@ blob = blobs[k];
				if(blob.getName() == "airlock")solid = true;
			}
			
			if(!solid){
				
				LastGoodPosition = Vec2f(-(i*8)+24,0);
				
				if(getMap().getTile(Pos+Vec2f(i*8+4,4)).type == CMap::tile_empty || getMap().getTile(Pos+Vec2f(i*8+4,12)).type == CMap::tile_empty)break;
			}
		
		}
	}
	
	if(this.getSprite() !is null){
		if(this.getSprite().getSpriteLayer("thruster") !is null){
			this.getSprite().getSpriteLayer("thruster").SetOffset(LastGoodPosition);
		}
	}
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ thruster = this.addSpriteLayer("thruster", "thruster.png" , 40, 16, blob.getTeamNum(), blob.getSkinNum());

	if (thruster !is null)
	{
		Animation@ anim = thruster.addAnimation("default", 0, false);
		anim.AddFrame(0);
		thruster.SetOffset(Vec2f(0, 0));
		thruster.SetRelativeZ(100);
	}
}