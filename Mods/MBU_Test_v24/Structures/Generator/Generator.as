#include "MakeMat.as";
#include "Requirements.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_empty);
	//this.getSprite().getConsts().accurateLighting = true;
	
	if(getNet().isServer()){
		for(int i=-1;i <2;i++)
		getMap().server_SetTile(this.getPosition()+Vec2f(0,i*8), CMap::tile_castle_back);
		
		for(int i=-1;i <2;i++)
		getMap().server_SetTile(this.getPosition()+Vec2f(i*8,-16), CMap::tile_castle);
		for(int i=-1;i <2;i++)
		getMap().server_SetTile(this.getPosition()+Vec2f(i*8,16), CMap::tile_castle);
	}
	
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	
	this.set_u16("grid_id",0);
	this.set_u16("connection_id",0);
	
	this.set_u16("power",0);
	
	this.Tag("grid_blob");
}

void onTick(CBlob@ this)
{
	this.set_u16("grid_id",0);
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), 24.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			
			if(b !is null && b !is this && b.getName() == "power_node" && b.getShape().isStatic()){
				
				if(b.get_u16("grid_id") > this.get_u16("grid_id")){
					this.set_u16("grid_id",b.get_u16("grid_id"));
				}
			}
		}
	}
	
	f32 effective_heat = (this.get_s16("heat")-100)/2;
	
	if(effective_heat > 0)this.set_u16("power",effective_heat*10.0f);
	else this.set_u16("power",0);
	
	string Grid = "\nNo Grid Connection";
	if(this.get_u16("grid_id") > 0)Grid = "\nGrid Number: "+this.get_u16("grid_id");
	
	this.setInventoryName("Generator"+"\nPower Output: "+(f32(this.get_u16("power"))/1000.0f)+" kW\nTemperature: "+(27+this.get_s16("heat"))+"C"+Grid);
}

void onInit(CSprite @this){
	this.SetZ(-60);
	
	CSpriteLayer@ cog = this.addSpriteLayer("cog", "Generator.png" , 24, 24, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (cog !is null)
	{
		Animation@ anim = cog.addAnimation("default", 0, false);
		anim.AddFrame(1);
		cog.SetRelativeZ(1.0f);
		cog.SetOffset(Vec2f(0,3));
	}
	
	{
		CSpriteLayer@ gear = this.addSpriteLayer("gear1", "Generator.png" , 24, 24, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(2);
			gear.SetRelativeZ(-1.0f);
			gear.SetOffset(Vec2f(6,8));
		}
	}
	{
		CSpriteLayer@ gear = this.addSpriteLayer("gear2", "Generator.png" , 24, 24, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(2);
			gear.SetRelativeZ(0.5f);
			gear.SetOffset(Vec2f(-6,-4));
		}
	}
	
	CSpriteLayer@ plank = this.addSpriteLayer("plank", "Generator.png" , 24, 24, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (plank !is null)
	{
		Animation@ anim = plank.addAnimation("default", 0, false);
		anim.AddFrame(4);
		plank.SetRelativeZ(2.0f);
	}
}

void onTick(CSprite @this){
	CBlob @blob = this.getBlob();
	
	CSpriteLayer @cog = this.getSpriteLayer("cog");
	
	if (cog !is null)
	{
		cog.RotateBy(blob.get_u16("power")/100, Vec2f(0,0));
	}
	
	CSpriteLayer @gear = this.getSpriteLayer("gear1");
	
	if (gear !is null)
	{
		gear.RotateBy(-(blob.get_u16("power")/50), Vec2f(0,0));
	}
	
	CSpriteLayer @gear2 = this.getSpriteLayer("gear2");
	
	if (gear2 !is null)
	{
		gear2.RotateBy(-(blob.get_u16("power")/50), Vec2f(0,0));
	}
}