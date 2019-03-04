
#include "EquipCommon.as";
#include "PaletteSwap.as";

void ReloadEquipment(CSprite @this, CBlob @blob){

	if(blob is null)return;
	
	CBlob @ItemMain = getEquippedBlob(blob, "main_arm");
	CBlob @ItemSub = getEquippedBlob(blob, "sub_arm");

	///Tools,weapons
	ReloadHandEquips(this, blob, ItemMain, ItemSub);
	ReloadShield(this, blob, ItemMain, ItemSub);
	
	///Armour
	ReloadHelmet(this,blob,getEquippedBlob(blob, "head"));
	
	//Misc
	ReloadBack(this, blob);
	ReloadBelt(this, blob);
}

void ReloadHandEquips(CSprite @this, CBlob @blob, CBlob @main_item, CBlob @sub_item){
	
	if(main_item !is null){
		string name = main_item.getName();
		
		int Material = main_item.get_u8("fabric");
		
		if(blob.get_string("main_equiped_sprite") != name+"_"+Material){

			blob.set_string("main_equiped_sprite",name+"_"+Material);
		
			CSpriteLayer @ equip = this.getSpriteLayer("main_equip");
		
			if(equip !is null){

				if(Material != 0){
				
					string tex = "character_"+name+"_"+Material;
					
					if(!Texture::exists(tex))Texture::createFromFile(tex, "character_"+name+".png");
					
					string spr = PaletteSwapTexture(tex, "FabricPalette.png", Material);
				
					equip.SetTexture(spr, 64, 64);
				} else {
					equip.ReloadSprite("character_"+name+".png");
				}
			
			}
		}
	}
	
	if(sub_item !is null){
		string name = sub_item.getName();
		
		int Material = sub_item.get_u8("fabric");
		
		if(blob.get_string("sub_equiped_sprite") != name+"_"+Material){

			blob.set_string("sub_equiped_sprite",name+"_"+Material);
		
			CSpriteLayer @ equip = this.getSpriteLayer("sub_equip");
		
			if(equip !is null){

				if(Material != 0){
				
					string tex = "character_"+name+"_"+Material;
					
					if(!Texture::exists(tex))Texture::createFromFile(tex, "character_"+name+".png");
					
					string spr = PaletteSwapTexture(tex, "FabricPalette.png", Material);
				
					equip.SetTexture(spr, 64, 64);
				} else {
					equip.ReloadSprite("character_"+name+".png");
				}
			
			}
		}
	}
}


string getEquipIcon(CBlob @item, string result){
	
	if(item !is null){
		string name = item.getName();
		
		int Material = item.get_u8("fabric");
		
		if(Material != 0){
		
			string tex = "icon_"+name+"_"+Material;
			
			if(!Texture::exists(tex))Texture::createFromFile(tex, name+"_icon.png");
			
			result = PaletteSwapTexture(tex, "FabricPalette.png", Material);
		}
	}
	
	return result;
}

string getEquipIconFile(CBlob @item, string result){
	
	if(item !is null){
		string name = item.getName();
		
		int Material = item.get_u8("fabric");
		
		if(Material != 0){
		
			string tex = "iconfile_"+name+"_"+Material;

			if(!Texture::exists(tex)){
				
				Texture::createFromFile(tex, name+"_icon.png");
				
				string swapped_texture = PaletteSwapTexture(tex, "FabricPalette.png", Material);
				
				ImageData@ texture = Texture::data(swapped_texture);
				
				CFileImage @file = CFileImage(24,24,true);
				file.setFilename(tex+".png",ImageFileBase::IMAGE_FILENAME_BASE_MAPS);
				
				for(int i = 0; i < texture.size(); i++)
				{
					file.setPixelAndAdvance(texture[i]);
				}
				
				file.Save();
			
			} else 
				return tex+".png";
		}
	}
	
	return result;
}

void ReloadBack(CSprite @this, CBlob @blob){

	string name = "";
	
	if(getEquippedBlob(blob, "back") !is null)
	name = getEquippedBlob(blob, "back").getName();
	
	if(this.getSpriteLayer("back") !is null){
		if(this.getSpriteLayer("back").getFilename().find(name) > 0)return;
	}
	
	this.RemoveSpriteLayer("back");
	
	if(name != ""){
		CSpriteLayer@ layer = this.addSpriteLayer("back", "character_"+name+".png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
			layer.SetOffset(Vec2f(0,0));
			layer.SetRelativeZ(-3.5f);
			layer.SetFacingLeft(this.isFacingLeft());
		}
	}
}

void ReloadBelt(CSprite @this, CBlob @blob){

	string name = "";
	
	if(getEquippedBlob(blob, "belt") !is null)
	name = getEquippedBlob(blob, "belt").getName();
	
	if(this.getSpriteLayer("belt") !is null){
		if(this.getSpriteLayer("belt").getFilename().find(name) > 0)return;
	}
	
	this.RemoveSpriteLayer("belt");

	if(name != ""){
		CSpriteLayer@ layer = this.addSpriteLayer("belt", "character_"+name+".png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("default", 0, false);
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
			layer.SetOffset(Vec2f(0,0));
			layer.SetRelativeZ(1.9f);
			layer.SetFacingLeft(this.isFacingLeft());
		}
	}
}

void ReloadHelmet(CSprite @this, CBlob @blob, CBlob @helmet){
	
	if(helmet !is null){
		string name = helmet.getName();
		
		if(this.getSpriteLayer("helmet") !is null){
		
			if(this.getSpriteLayer("helmet").getFilename().find(name) <= 0)this.getSpriteLayer("helmet").ReloadSprite("character_"+name+".png",32,32,helmet.getTeamNum(),0);
		
		}
	} else {
		if(this.getSpriteLayer("helmet") !is null)
			if(this.getSpriteLayer("helmet").getFilename().find("aracter_no_helmet.png") <= 0)
				this.getSpriteLayer("helmet").ReloadSprite("character_no_helmet.png");
	}
}

void ReloadShield(CSprite @this, CBlob @blob, CBlob @main_item, CBlob @sub_item){

	if(main_item !is null)if(main_item.get_u8("equip_type") == 5){
		string name = main_item.getName();
		
		if(this.getSpriteLayer("shield") !is null){
		
			if(this.getSpriteLayer("shield").getFilename().find(name) <= 0)this.getSpriteLayer("shield").ReloadSprite("character_"+name+".png",32,32,main_item.getTeamNum(),0);
		
		}
	}
	
	if(sub_item !is null)if(sub_item.get_u8("equip_type") == 5){
		string name = sub_item.getName();
		
		if(this.getSpriteLayer("shield") !is null){
		
			if(this.getSpriteLayer("shield").getFilename().find(name) <= 0)this.getSpriteLayer("shield").ReloadSprite("character_"+name+".png",32,32,sub_item.getTeamNum(),0);
		
		}
	}
}