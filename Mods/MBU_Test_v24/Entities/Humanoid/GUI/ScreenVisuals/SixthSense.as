
#include "HumanoidCommon.as";
#include "DrawOverlay.as";

void onRender(CSprite@ this)
{

	CBlob@ blob = this.getBlob();

	if(getLocalPlayer() !is blob.getPlayer())return;

	float Scale = getCamera().targetDistance;
	float Block_scale = Scale*1.25f;
	
	bool FireSight = blob.hasTag("fire_sight");
	
	SColor c_blood_sight(255,255,0,0);
	SColor c_warmth_sight(128,255,255,0);
	SColor c_fire_sight(255,255,255,0);
	
	RenderStyle::Style style = RenderStyle::light;
	
	CBlob@[] blobs;	   
	getBlobsByName("no", @blobs);
	getBlobsByName("fb", @blobs);
	getBlobsByName("sn", @blobs);
	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		if(b !is blob){
			b.RenderForHUD(Vec2f(0,0), 0, c_fire_sight, style);
		}
	}
	
	int vent_width = 10;
	int vent_height = 10;
	
	if(FireSight && blob.get_u8("burnt_eyes") > 1){
		CBlob@[] humans;
		getBlobsByName("humanoid", humans);
	
		for(int k = 0;k < humans.length;k++){
			CBlob @b = humans[k];

			if(b.hasTag("venting_heat")){
			
				Vec2f block_pos = Vec2f(Maths::Floor(b.getPosition().x/8)*8,Maths::Floor(b.getPosition().y/8)*8);
				
				for(int i = -vent_width;i <= vent_width;i++)
				for(int j = -vent_height;j <= vent_height;j++){
					
					
					f32 ratio = (Vec2f(i,j).Length()/((vent_width+vent_height)/2));
					if(ratio < 1.0f)
					{
					
						//GUI::DrawIcon("world.png", getMap().getTile(block_pos+Vec2f(i*8,j*8)).type, Vec2f(8, 8), getDriver().getScreenPosFromWorldPos(block_pos+Vec2f(i*8,j*8)), Block_scale);
						//continue;
					
						Vec2f pos = block_pos+Vec2f(i*8,j*8);
						Tile tile = getMap().getTile(pos);
						
						if(tile.type != CMap::tile_empty){
							if(!getMap().isTileBackground(tile)){
								/*Tile Top = getMap().getTile(pos+Vec2f(0,-8));
								Tile Bot = getMap().getTile(pos+Vec2f(0,8));
								Tile Lef = getMap().getTile(pos+Vec2f(-8,0));
								Tile Rig = getMap().getTile(pos+Vec2f(8,0));
								if(getMap().isTileBackground(Top) || Top.type == CMap::tile_empty
								|| getMap().isTileBackground(Bot) || Bot.type == CMap::tile_empty
								|| getMap().isTileBackground(Lef) || Lef.type == CMap::tile_empty
								|| getMap().isTileBackground(Rig) || Rig.type == CMap::tile_empty)*/
								
								
								GUI::DrawIcon("world.png", tile.type+tile.damage, Vec2f(8, 8), getDriver().getScreenPosFromWorldPos(pos), Block_scale,SColor(128*(1.1-ratio),255,128,0));
							} //else GUI::DrawIcon("world.png", tile.type, Vec2f(8, 8), getDriver().getScreenPosFromWorldPos(pos), Block_scale,SColor(128*(1.1-ratio),255,128,0));
						}
					}
				}
			}
		}
	}

	
	if(blob.hasTag("blood_sight") || (FireSight && blob.get_u8("burnt_eyes") > 1)){
		CBlob@[] blobs;	   
		getBlobsByTag("flesh", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is blob && !b.isInInventory()){
				if(b.getName() == "chicken" || b.getName() == "bison"){
					if(!FireSight)b.RenderForHUD(Vec2f(0,0), 0, c_blood_sight, style);
					else b.RenderForHUD(Vec2f(0,0), 0, c_warmth_sight, style);
				} else 
				if(b.getName() == "humanoid"){
					if(b.get_s16("blood_amount") > 0 && b.hasTag("flesh")){
						int blood = 100+(150.0f*(f32(b.get_s16("blood_amount"))/1000.0f));
						if(!FireSight)b.RenderForHUD(Vec2f(0,0), 0, SColor(blood,255,0,0), style);
						else b.RenderForHUD(Vec2f(0,0), 0, c_warmth_sight, style);
					}
				}
			}
		}
	}
	
	if(FireSight){
		CBlob@[] blobs;	   
		getBlobsByName("lantern", @blobs);
		getBlobsByName("stickfire", @blobs);
		getBlobsByTag("heat_infused", @blobs);
		getBlobsByTag("warm", @blobs);
		getBlobsByTag("burning", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is blob && !b.isInInventory()){
				if(b.getName() == "lantern" || b.getName() == "stickfire"){
					b.RenderForHUD(Vec2f(0,0), 0, c_fire_sight, style);
				}  else 
				if(b.hasTag("heat_infused")){
					b.RenderForHUD(Vec2f(0,0), 0, SColor(Maths::Min(50.0f+b.get_u16("heat_amount")*2,255),255,255,0), style);
				} else 
				if(b.hasTag("burning")){
					b.RenderForHUD(Vec2f(0,0), 0, SColor(200,255,255,0), style);
				} else
				if(b.hasTag("warm")){
					b.RenderForHUD(Vec2f(0,0), 0, SColor(100,255,255,0), style);
					if(b.getDistanceTo(blob) > 160.0f || !blob.hasTag("venting_heat"))b.Untag("warm");
				}
			}
		}
	}
	
	if(blob.hasTag("death_sight")){
		CBlob@[] blobs;
		getBlobsByTag("death_infused", @blobs);
		getBlobsByTag("death_tak", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is blob && !b.isInInventory()){
				if(b.hasTag("death_infused")){
					b.RenderForHUD(Vec2f(0,0), 0, SColor(100,200,255,200), style);
				} else 
				if(b.hasTag("death_tak") && b.get_s16("death_amount") > 0){
					b.RenderForHUD(Vec2f(0,0), 0, SColor(100+(150.0f*(f32(b.get_s16("death_amount"))/1000.0f)),200,255,200), style);
				}
			}
		}
	}
	
	if(blob.hasTag("life_sight")){
		CBlob@[] blobs;
		getBlobsByTag("life_tak", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is blob && !b.isInInventory() && b.getName() != "tree_life"){
				if(b.get_s16("life_amount") > 0){
					b.RenderForHUD(Vec2f(0,0), 0, SColor(100+(150.0f*(f32(b.get_s16("life_amount"))/1000.0f)),62,181,225), style);
				}
			}
		}
	}
	
	if(blob.hasTag("light_sight")){
		CBlob@[] blobs;
		getBlobsByTag("light_tak", @blobs);
		getBlobsByTag("light_infused", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is blob && !b.isInInventory()){
				if(b.hasTag("light_tak") && b.get_s16("light_amount") > 0){
					b.RenderForHUD(Vec2f(0,0), 0, SColor(100+(150.0f*(f32(b.get_s16("light_amount"))/1000.0f)),255,255,225), style);
				}
				if(b.hasTag("light_infused")){
					b.RenderForHUD(Vec2f(0,0), 0, SColor(100,255,255,225), style);
				}
				if(b.getName() == "goldenbeing"){
					GUI::DrawIcon("gb.png",b.getInterpolatedScreenPos()-Vec2f(48.0f*Scale*2.0f,48.0f*Scale*2.0f),Scale);
				}
			}
		}
	}

	{
		CBlob@[] blobs;
		getBlobsByName("tree_life", @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b !is null){
				b.RenderForHUD(Vec2f(0,0), 0, SColor(100,62,181,225), style);
			}
		}
	}
	
	
}
