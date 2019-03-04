// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.set_bool("open", false);
	this.Tag("place norotate");

	//block knight sword
	this.Tag("blocks sword");

	if (getNet().isServer())
	{
		dictionary harvest;
		harvest.set('mat_stone', 4);
		this.set('harvest', harvest);
	}

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.set_u16("grid_id",0);
	this.set_u16("client_grid_id",0);
	
	u16[] Connections;
	this.set("connections",Connections);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
	
	u16[] Connections;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			
			if(b !is null && b !is this && b.getName() == "power_node" && b.getShape().isStatic()){
				Connections.push_back(b.getNetworkID());
				
				u16[] @OtherConnections;
				if(b.get("connections",@OtherConnections)){
					OtherConnections.push_back(this.getNetworkID());
					b.set("connections",OtherConnections);
				}
				
				if(b.get_u16("grid_id") > this.get_u16("grid_id")){
					this.set_u16("grid_id",b.get_u16("grid_id"));
				}
			}
		}
	}
	
	this.set("connections",Connections);
	
	if(Connections.length <= 0){
		this.set_u16("grid_id",getGameTime());
		
		//Todo, make sure this grid ID isn't being used already
	} else {
		getRules().Tag("electric_grid_recal");
	}
	
	this.SetFacingLeft(false);
}

void onTick(CBlob @this){

	u16[] @Connections;
	if(this.get("connections",@Connections)){
		this.setInventoryName("Power Node\nGrid Number:"+this.get_u16("grid_id")+"\nGrid power: "+(f32(getRules().get_u16("grid_"+this.get_u16("grid_id")+"_power"))/1000.0f)+" kW\nGrid requires: "+(f32(getRules().get_u16("grid_"+this.get_u16("grid_id")+"_watts_needed"))/1000.0f)+" kW\nGrid Satisfaction: "+(f32(getRules().get_f32("grid_"+this.get_u16("grid_id")+"_power_ratio"))*100)+"%");
	}

	
	if(getNet().isServer()){
		if(this.get_u16("client_grid_id") != this.get_u16("grid_id")){
			this.set_u16("client_grid_id",this.get_u16("grid_id"));
			this.Sync("grid_id",true);
		}
	}
}

void onDie(CBlob @this){

	u16[] @Connections;
	if(this.get("connections",@Connections)){
		for (uint j = 0; j < Connections.length; j++)
		{
			CBlob @con = getBlobByNetworkID(Connections[j]);
			if(con !is null){
				con.set_u16("grid_id",this.get_u16("grid_id")+j*5+5);
				getRules().Tag("electric_grid_recal");
			}
		}
	}

}

void onTick(CSprite @this){

	if(!this.isFacingLeft()){
		CBlob @blob = this.getBlob();
		
		u16[] @Connections;
		if(blob.get("connections",@Connections)){
			for (uint j = 0; j < Connections.length; j++)
			{
				CBlob @con = getBlobByNetworkID(Connections[j]);

				if(con !is null){
					if(con.getNetworkID() < blob.getNetworkID())
					if(this.getSpriteLayer("wire"+j) is null && this.getSpriteLayerCount() < 3){
						CSpriteLayer@ wire = this.addSpriteLayer("wire"+j, "LecitCable.png" , 32, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

						if (wire !is null)
						{
							Animation@ anim = wire.addAnimation("default", 0, false);
							anim.AddFrame(0);
							wire.SetRelativeZ(-50.0f);
							wire.SetOffset(Vec2f(0,-0.5));
							wire.SetFacingLeft(false);
							
							Vec2f off = con.getPosition() - blob.getPosition();

							f32 wirelen = Maths::Max(0.1f, off.Length() / 32.0f);

							wire.ResetTransform();
							wire.ScaleBy(Vec2f(wirelen, 1.0f));

							wire.TranslateBy(Vec2f(wirelen * 16.0f, 0.0f));

							wire.RotateBy(-off.Angle() , Vec2f(0,0.5));
						}
					}
				} else {
					this.RemoveSpriteLayer("wire"+j);
				}
			}
		}
	}
	

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}