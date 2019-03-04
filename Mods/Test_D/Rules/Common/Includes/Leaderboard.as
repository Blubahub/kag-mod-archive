namespace Leaderboard
{
	shared class Data
	{
		string boardname;
		Score[] scores;
	};

	shared class Score
	{
		string name;
		int score;

		int opCmp (const Score &in other) const {
			return (other.score < score) ? 1 : -1;
		}
	};

	void Init(const string &in name, const string &in friendlyName)
	{
		if (get(name) is null)
		{
			Leaderboard::Data lb;
			lb.boardname = friendlyName;
			getRules().set(name, @lb);
			if(getNet().isServer())
			{
				LoadFromDisk(get(name));
			}
		}
	}

	Data@ get(const string &in name)
	{
		Data@ data;
		getRules().get(name, @data);
		return data;
	}

	void AddScore(const string &in name, const string &in character, const int score)
	{
		Data@ data = get(name);
		if (data !is null)
		{
			for (uint i=0; i < data.scores.length; i++)
			{
				Score@ s = data.scores[i];
				if (s.name == character)
				{
					printf("add score " + score);
					SetScore( name, character, s.score + score );
					return;
				}
			}
			// not found - create new
			printf("add new score " + score);
			SetScore( name, character, score );
		}
	}

	void SetScore(const string &in name, const string &in character, const int score)
	{
		Data@ data = get(name);
		if (data !is null)
		{
			for (uint i=0; i < data.scores.length; i++)
			{
				Score@ s = data.scores[i];
				if (s.name == character)
				{
					printf("set score " + score);
					s.score = score;
					SaveToDisk(data);
					return;
				}
			}
			// not found - create new
			Score s;
			printf("set new score " + score);
			s.name = character;
			s.score = score;
			data.scores.push_back(s);
			SaveToDisk(data);
		}
	}	

	void Sync(CBlob@ this, const string &in name, CPlayer@ player)
	{
		if (player is null){
			return;
		}

		Data@ data = get(name);
		if (data !is null)
		{
			CBitStream stream;
			stream.write_string(name);
			stream.write_u16(data.scores.length);
			for (uint i=0; i < data.scores.length; i++)
			{
				Score@ s = data.scores[i];
				stream.write_string(s.name);
				stream.write_s32(s.score);
				//printf("write " + s.name);
			}

			this.server_SendCommandToPlayer(this.getCommandID("leaderboard"), stream, player);
		}
	}

	void Read(CBitStream@ stream)
	{
		string name = stream.read_string();
		Data@ data = get(name);
		if (data !is null)
		{
			data.scores.clear();
			u16 length = stream.read_u16();
			for (uint i=0; i < length; i++)
			{
				Score s;
				s.name = stream.read_string();
				s.score = stream.read_s32();
				data.scores.push_back(s);
				//printf("read " + s.name);
			}
			Sort(data);
		}
	}

	string getCfgFileName(Data@ data)
	{
		string fname = "leaderboard " + data.boardname + ".cfg";
		//strip spaces to avoid trouble
		for(u32 i = 0; i < fname.size(); i++)
		{
			if(fname[i] == 0x20)
			{
				fname[i] = 0x5F;
			}
		}
		return fname;
	}

	void SaveToDisk(Data@ data)
	{
		Sort(data);

		ConfigFile cfg;
		string[] names;
		s32[] scores;
		const u32 count = data.scores.length; //Maths::Min( 100, data.scores.length ); - uncomment in case of trouble saving lots of names
		for (uint i=0; i < count; i++)
		{
			Score@ s = data.scores[i];
			names.push_back(s.name);
			scores.push_back(s.score);
		}
		cfg.addArray_string("names", names);
		cfg.addArray_s32("scores", scores);
		cfg.saveFile(getCfgFileName(data));
	}

	void LoadFromDisk(Data@ data)
	{
		ConfigFile cfg;
		data.scores.clear();

		if (cfg.loadFile("../Cache/"+getCfgFileName(data)))
		{
			string[] names;
			s32[] scores;
			cfg.readIntoArray_string(names, "names");
			cfg.readIntoArray_s32(scores, "scores");

			for (uint i=0; i < names.length; i++)
			{
				Score s;
				s.name = names[i];
				s.score = scores[i];
				data.scores.push_back(s);
			}

			Sort(data);
		}
	}

	void Sort(Data@ data)
	{
		data.scores.sortDesc();
	}

	// display
	
	void SetCurrentLeaderboard(const u32 time, const string &in name)
	{
		CRules@ rules = getRules();
		rules.set_u32("leaderboard show time", time);
		rules.set_string("leaderboard name", name);
	}

	u32 getLeaderboardTime()
	{
		return getRules().get_u32("leaderboard show time");
	}

	string getLeaderboardName()
	{
		return getRules().get_string("leaderboard name");
	}	
}
