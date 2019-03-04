	
//names of stuff which should be able to be hit by
//team builders, drills etc

const string[] builder_alwayshit = {
	//handmade
	"workbench",
	"fireplace",
	"ladder",
	
	//faketiles
	"spikes",
	"trap_block",
	"gold_block",
	"farming_block",
	"wooden_trap_block",
	"triangle_wood_block",
	"triangle_stone_block",

	
	//buildings
	"factory",
	"tunnel",
	"building",
	"quarters",
	"storage",
	
	//new
	//blocks
	"wooden_spikes",
	"trap_ladder",
	"lamp_block",
	"wooden_trap_block",
	"teamcolored_wooden_platform",

	//buildings
	"animalshop",
	"barracks",
	"storage",
	"ctfkitchen",
	"nursery",
	"minibuilding",
	"bigbuilding",
	"mill",
	"forge",
	"ctfnursery",
	"personal_bank",
	"portal",
	
	//flesh
	"zombie",
	"skeleton",
	"steel_block",

	//natural
	"flowers",
	"chaparral"

};

//fragments of names, for semi-tolerant matching
// (so we don't have to do heaps of comparisions
//  for all the shops)
const string[] builder_alwayshit_fragment = {
	"shop",
	"door"
};

bool BuilderAlwaysHit(CBlob@ blob)
{
	if(blob.hasTag("builder always hit"))
	{
		return true;
	}

	string name = blob.getName();
	for(uint i = 0; i < builder_alwayshit.length; ++i)
	{
		if (builder_alwayshit[i] == name)
			return true;
	}
	for(uint i = 0; i < builder_alwayshit_fragment.length; ++i)
	{
		if(name.find(builder_alwayshit_fragment[i]) != -1)
			return true;
	}
	return false;
}

bool isUrgent( CBlob@ this, CBlob@ b )
{
			//enemy players
	return (b.getTeamNum() != this.getTeamNum() || b.hasTag("dead")) && b.hasTag("player") ||
			//tagged
			b.hasTag("builder urgent hit") ||
			//trees
			b.getName().find("tree") != -1 ||
			//spikes
			b.getName() == "spikes";
}
