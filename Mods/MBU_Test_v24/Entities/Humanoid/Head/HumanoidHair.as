
void onInit(CBlob@ this)
{
	this.set_u8("hair_index",XORRandom(4));
	this.set_u8("hair_colour",getHairColour(this));
	
	this.addCommandID("sync_hair");
	
	if(getNet().isServer()){
		CBitStream params;
		params.write_u8(this.get_u8("hair_index"));
		params.write_u8(this.get_u8("hair_colour"));
		this.SendCommand(this.getCommandID("sync_hair"), params);
	}
}

void onTick(CBlob@ this)
{
	if(getNet().isServer()){
		if(!this.hasTag("checked_hair")){
			if(getHairColour(this) > 5)this.set_u8("hair_colour",getHairColour(this));
				
			CBitStream params;
			params.write_u8(this.get_u8("hair_index"));
			params.write_u8(this.get_u8("hair_colour"));
			this.SendCommand(this.getCommandID("sync_hair"), params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sync_hair"))
	{
		int hair_style = params.read_u8();
		int hair_colour = params.read_u8();
		
		this.set_u8("hair_index",hair_style);
		this.set_u8("hair_colour",hair_colour);
	}
}

int getHairColour(CBlob@ this, CPlayer @player){

	if(player !is null){
	
		if (player.getUsername().toLower() == "niiiiii"){
			return 15;
		}
		
		if( player.getUsername().toLower() == "tflippy"){
			return 7;
		}
		
		if( player.getUsername().toLower() == "vamist"){
			return 14;
		}
		
		this.Tag("checked_hair");
	}

	return 2+XORRandom(4);

}

int getHairColour(CBlob@ this){

	return getHairColour(this, this.getPlayer());

}