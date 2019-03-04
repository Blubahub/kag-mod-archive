void onInit(CBlob@ this)
{
	this.Tag("chaosrune");
}

void onTick(CBlob@ this)
{
	if (!getNet().isServer() || this.isAttached())
	{
		return;
	}
	
	
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("flesh") && !b.hasTag("negrunetatoo")){
				if(XORRandom(4) > 2)if(b.get_s16("empowerfire") < 300)b.set_s16("empowerfire",300);
				if(XORRandom(4) > 2)if(b.get_s16("empowerwater") < 300)b.set_s16("empowerwater",300);
				if(XORRandom(4) > 2)if(b.get_s16("weak") < 300)b.set_s16("weak",300);
				if(XORRandom(4) > 2)if(b.get_s16("defense") < 300)b.set_s16("defense",300);
				if(XORRandom(4) > 2)if(b.get_s16("highjump") < 300)b.set_s16("highjump",300);
				if(XORRandom(4) > 2)if(b.get_s16("squat") < 300)b.set_s16("squat",300);
				if(XORRandom(4) > 2)if(b.get_s16("drain") < 300)b.set_s16("drain",300);
				if(XORRandom(4) > 2)if(b.get_s16("lifesteal") < 300)b.set_s16("lifesteal",300);
				if(XORRandom(4) > 2)if(b.get_s16("stunt") < 300)b.set_s16("stunt",300);
				if(XORRandom(4) > 2)if(b.get_s16("overregen") < 300)b.set_s16("overregen",300);
				if(XORRandom(4) > 2)if(b.get_s16("noheal") < 300)b.set_s16("noheal",300);
				if(XORRandom(4) > 2)if(b.get_s16("overheal") < 300)b.set_s16("overheal",300);
				if(XORRandom(4) > 2)if(b.get_s16("poison") < 300)b.set_s16("poison",300);
				if(XORRandom(4) > 2)if(b.get_s16("buff") < 300)b.set_s16("buff",300);
				if(XORRandom(4) > 2)if(b.get_s16("haste") < 300)b.set_s16("haste",300);
				if(XORRandom(4) > 2)if(b.get_s16("slow") < 300)b.set_s16("slow",300);
				if(XORRandom(4) > 2)if(b.get_s16("cleanse") < 300)b.set_s16("cleanse",300);
				if(XORRandom(4) > 2)if(b.get_s16("infect") < 300)b.set_s16("infect",300);
			}
		}
	}
	
	
	return;
}