class RankedServer
{
	string address_and_port;
	string region;
	string caption1, caption2;
	u32 background, icon;
	string description;
	string players;
	SELECT_FUNCTION@ selectFunc;
	RankedServer(string _address_and_port,
	             string _caption1, string _caption2,
	             u32 _background,
	             u32 _icon_frame,
	             string _description,
	             SELECT_FUNCTION@ _selectFunc,
	             string _region)
	{
		address_and_port = _address_and_port;
		caption1 = _caption1;
		caption2 = _caption2;
		background = _background;
		icon = _icon_frame;
		description = _description;
		@selectFunc = _selectFunc;
		players = "";
		region = _region;
	}
};

const string VINO = "98.142.97.202"; //USA
const string TOTO = "178.63.17.152"; //EU
const string AU2 = "163.53.233.12"; //AUS

RankedServer[] _rankedServers;

void InitRankedServers()
{
	_rankedServers.clear();
	//official servers
	RankedServer[] _officialServers =
	{
		//US

		RankedServer(VINO + ":50350", "LOBBY", "", 1, 0,
		"USA lobby - no entry cost!", SelectServer, "USA")

		//EU

		, RankedServer(TOTO + ":50350", "LOBBY", "", 1, 0,
		"EU lobby - no entry cost!", SelectServer, "EU")

		//AUS

		, RankedServer(AU2 + ":50350", "LOBBY", "", 1, 0,
		"AUS lobby - no entry cost!", SelectServer, "AUS")

	};
	for (u32 i = 0; i < _officialServers.length; i++)
	{
		_rankedServers.push_back(_officialServers[i]);
	}

	if (isTestBuild())
	{
		//test servers
		RankedServer[] _testServers =
		{
			RankedServer(VINO + ":50425", "LOBBY", "", 1, 0,
			"Test Build Lobby", SelectServer, "USA")
		};
		for (u32 i = 0; i < _testServers.length; i++)
		{
			_rankedServers.push_back(_testServers[i]);
		}
	}
}
