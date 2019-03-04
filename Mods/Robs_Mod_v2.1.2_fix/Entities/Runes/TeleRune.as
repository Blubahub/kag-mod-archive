void onInit(CBlob@ this)
{
	this.Tag("telerune");
	this.set_string("telekey","");
	this.set_bool("chaos",false);
}

void onTick(CBlob@ this){
	
	string TeleKey = "";
	this.set_bool("chaos",false);
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("rune")){
				if(b.hasTag("firerune"))TeleKey += "f";
				if(b.hasTag("waterrune"))TeleKey += "w";
				
				if(b.hasTag("earthrune"))TeleKey += "e";
				if(b.hasTag("airrune"))TeleKey += "a";
				
				if(b.hasTag("fleshrune"))TeleKey += "s";
				if(b.hasTag("plantrune"))TeleKey += "p";
				
				if(b.hasTag("chaosrune")){
					if(XORRandom(4) > 2){TeleKey += "lol";break;}
					if(XORRandom(4) > 2)TeleKey += "f";
					if(XORRandom(4) > 2)TeleKey += "w";
					if(XORRandom(4) > 2)TeleKey += "e";
					if(XORRandom(4) > 2)TeleKey += "a";
					if(XORRandom(4) > 2)TeleKey += "s";
					if(XORRandom(4) > 2)TeleKey += "p";
					this.set_bool("chaos",true);
				}
				if(b.hasTag("negrune"))this.set_bool("chaos",false);
			}
		}
	}
	
	this.set_string("telekey",TeleKey);
	
	
	return;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if (this.isAttached())
	{
		return;
	}

	//shouldn't be in here! collided with map??
	if (blob is null)
	{
		return;
	}

	// only hit living things
	if (!blob.hasTag("flesh") || blob.hasTag("negrunetatoo") || blob.get_s16("temp_statis") > 0)
	{
		return;
	}
	
	
	if(this.get_bool("chaos") == false){
		CBlob@[] telerunes;
		getBlobsByName("telerune", @telerunes);
		
		for(uint i = 0; i < telerunes.length; i++){
			if(this !is telerunes[i]){
				if(this.get_string("telekey") == telerunes[i].get_string("telekey")){
					blob.setPosition(telerunes[i].getPosition()+(blob.getPosition()-this.getPosition()));
					blob.set_s16("temp_statis",60);
					break;
				}
			}
		}
	} else {
		blob.setPosition(blob.getPosition() + Vec2f(XORRandom(128)-64,XORRandom(128)-64));
	}
	
	return;
}