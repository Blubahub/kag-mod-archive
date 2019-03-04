namespace SkipScreen
{
	shared class Data
	{
		string[] skippable;
	}

	Data@ getData(CRules@ this)
	{
		Data@ data;
		this.get("skipscreen", @data);
		return data;
	}

	void AddSkippable( CRules@ this, string[] skippable )
	{
		Data@ data = getData(this);
		if (data is null)
		{
			// data
			SkipScreen::Data newdata;
			this.set("skipscreen", @newdata);	
			@data = getData(this);
		}

		for (uint i=0; i < skippable.length; i++)
		{
			data.skippable.push_back(skippable[i]);
		}
	}
}