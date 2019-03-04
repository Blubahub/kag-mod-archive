namespace LinkSpawnCmd
{
	enum Cmd
	{
		buildMenu = 1,
		changeClass = 2,
		buildDPSMenu = 3,
		buildTankMenu = 4,
		buildSupportMenu = 5,
		buildSpecialistMenu = 6,
	}
}

namespace SpawnCmd
{
	enum Cmd
	{
		buildMenu = 1,
		changeClass = 2,
	}
}

void write_classchange(CBitStream@ params, u16 callerID, string config, u32 cost)
{
	params.write_u16(callerID);
	params.write_string(config);
}

void write_classchange(CBitStream@ params, u16 callerID, string config)
{
	params.write_u16(callerID);
	params.write_string(config);
}
