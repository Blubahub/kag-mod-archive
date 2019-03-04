
//names of stuff which should be able to be hit by
//team builders, drills etc

const string[] builder_alwayshit =
{
	//handmade
	"workbench",
	//"fireplace",
	"ac_ladderwood",
     "ladder",
	 "alpha_door"
	//faketiles
	"spikes",
	"trap_block",

	//buildings
	"factory",
	"tunnel",
	"building",
	"quarters",
	"storage",

	//mechanisms
	"bolter",
	"dispenser",
	"lamp",
	"clamp",
	"obstructor",
	"spiker",
	"diode",
	"emitter",
	"inverter",
	"junction",
	"magazine",
	"oscillator",
	"randomizer",
	"receiver",
	"resistor",
	"toggle",
	"transistor",
	"wire",
	"coin_slot",
	"lever",
	"pressure_plate",
	"push_button",
	"team_bridge",
	"tramp_bridge",
};

//fragments of names, for semi-tolerant matching
// (so we don't have to do heaps of comparisions
//  for all the shops)
const string[] builder_alwayshit_fragment =
{
	"shop",
	"door"
};

bool BuilderAlwaysHit(CBlob@ blob)
{
	string name = blob.getName();
	for (uint i = 0; i < builder_alwayshit.length; ++i)
	{
		if (builder_alwayshit[i] == name)
			return true;
	}
	for (uint i = 0; i < builder_alwayshit_fragment.length; ++i)
	{
		if (name.find(builder_alwayshit_fragment[i]) != -1)
			return true;
	}
	return false;
}

bool isUrgent(CBlob@ this, CBlob@ b)
{
	//enemy players
	return (b.getTeamNum() != this.getTeamNum() || b.hasTag("dead")) && b.hasTag("player") ||
	       //trees
	       b.getName().find("tree") != -1 ||
	       //spikes
	       b.getName() == "spikes";
}