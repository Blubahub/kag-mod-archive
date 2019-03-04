#include "Polymorph.as";

void onInit(CBlob@ this)
{
	this.Tag("polyrune");
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
	if (!blob.hasTag("flesh") || blob.hasTag("negrunetatoo") || blob.hasTag("polymorphed"))
	{
		return;
	}
	
	string polytype = "none";
	
	int flesh = 0;
	int plant = 0;
	int water = 0;
	int death = 0;
	int rock = 0;
	int wind = 0;
	
	int time = 600;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("rune"))
			if(!b.isAttached()){

				if(b.hasTag("fleshrune"))flesh += 1;
				if(b.hasTag("plantrune"))plant += 1;
				
				if(b.hasTag("consumerune"))flesh += 1;
				if(b.hasTag("growrune"))plant += 1;
				
				if(b.hasTag("waterrune"))water += 1;
				if(b.hasTag("airrune"))wind += 1;
				if(b.hasTag("deathrune"))death += 1;
				
				if(b.hasTag("earthrune"))rock += 1;
				
				if(b.hasTag("curserune"))time = 30000;

			}
		}
	}
	
	if(flesh > plant && flesh > rock){
		if(wind > death && wind > water)polytype = "polychicken";
		if(water > death && water > wind)polytype = "polyfish";
		if(death > water && death > wind)polytype = "polyzombie";
	}
	if(plant > flesh && plant > rock)polytype = "polyent";
	if(rock > flesh && rock > plant)polytype = "polygolem";
	
	
	if(polytype != "none")Polymorph(blob, polytype, time);
	
	
	
	
	return;
}

