string[] _biomes =
{
	"city",
	"trenches",
	"village",
	"desert",
	"mountain",
	"forest",
	"swamp"
};

void LoadBiomeMap(const int index, const string &in directory)
{
	const string biome = _biomes[index % _biomes.length];
	LoadBiomeMap( biome, directory );
}

void LoadBiomeMap(const string &in biome, const string &in directory)
{
	CRules@ rules = getRules();
	rules.set_string("biome", biome);
	rules.set_bool("force biome", true);

	CFileMatcher@ matcher = CFileMatcher("Maps/" + directory + "/" + biome + "/map");
	const string mapname = matcher.getRandom();
	LoadMap(mapname);
}

void SyncBiome( CRules@ this )
{
	this.Sync("biome", true);
	this.Sync("force biome", true);
}
