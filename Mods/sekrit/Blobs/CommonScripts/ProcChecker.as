//Oil tag = Oilled
//burning tag = burning

void ProcCheck(CBlob@ this)
{
	if(this is null)
	{
		return;
	}

	if(this.get_bool("Oilled"))
	{
		if(this.hasTag("burning"))
		{
			//this.Tag("burning")

			//this.Untag("burning_tag");
			//this.Sync("burning_tag", true);
			if(this.isInWater())
			{
				this.Untag("burning");
				this.Sync("burning", true);
			}
			else
			{
				this.add_s16("burn timer", 2);
				this.Sync("burn timer", true);
			}

		}
	}
}