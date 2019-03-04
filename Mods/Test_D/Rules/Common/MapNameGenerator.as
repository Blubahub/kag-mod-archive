namespace MapNameGeneration
{

	Random _r;

	string Location()
	{
		//city names; just using real ones for now, should consider making up city names to avoid problems :D
		string s[] = {
			"Warsaw",
			"Melbourne",
			"Java",
			"Cambridge",
			"Shanghai",
			"Tokyo",
			"Sydney",
			"Copenhagen",
			"Oslo",
			"Krakow",
			"Auckland",
			"Dunedin"
		};

		return s[_r.NextRanged(s.length)];
	}

	string FlavourPrefix()
	{
		string s[] = {
			"Adamant",
			"Better",
			"Cold",
			"Deft",
			"Energetic",
			"Frank",
			"Genial",
			"Hectic",
			"Illicit",
			"Joking",
			"Kite",
			"Little",
			"Messy",
			"Noisy",
			"Open",
			"Punctual",
			"Queer",
			"Risky",
			"Stinging",
			"Terraced",
			"Unsung",
			"Vehement",
			"Worrying",
			"Xerxes",
			"Yearly",
			"Zipping"
		};

		return s[_r.NextRanged(s.length)];
	}

	string FlavourSuffix()
	{
		string s[] = {
			"Adama",
			"Betty",
			"Carl",
			"Delilah",
			"Errol",
			"Felicity",
			"Gerry",
			"Hope",
			"Iago",
			"Jenny",
			"Kyle",
			"Lenny",
			"Max",
			"Nora",
			"Owen",
			"Penny",
			"Quade",
			"Rhiannon",
			"Steven"
			"Tabitha",
			"Upton",
			"Valentine",
			"Winston",
			"Xanthus",
			"Yu",
			"Zara"
		};

		return s[_r.NextRanged(s.length)];
	}

	string FlavourName()
	{
		return FlavourPrefix()+" "+FlavourSuffix();
	}

	string Operation()
	{
		return "Operation "+FlavourName();
	}

	string Skirmish()
	{
		string s[] = {
			"at ",
			"near ",
			"by "
		};

		return "Skirmish "+s[_r.NextRanged(s.length)]+Location();
	}

	string Battle()
	{
		return "Battle of "+Location();
	}

	string Year()
	{
		return 1912 + _r.NextRanged(60);
	}

	string BattleName()
	{
		string s[] = {
			Battle(),
			Skirmish(),
			Operation()
		};

		return s[_r.NextRanged(s.length)];
	}

	string FullName()
	{
		return BattleName()+", "+Year();
	}
};

string GenerateMapName()
{
	return MapNameGeneration::FullName();
}

string GenerateMapNameNoYear()
{
	return MapNameGeneration::BattleName();	
}