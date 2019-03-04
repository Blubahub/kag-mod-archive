u16 producing_time = 100 * 30; //100 seconds

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60; //two seconds
	this.set_u16("flour_blob_id", 0);
	this.set_s32("producing_finish_time", 0);
}

void onTick(CBlob@ this)
{
	if (!getNet().isServer()) return;

	if (this.hasTag("producing"))
	{
		u16 flour_blob_id = this.get_u16("flour_blob_id");
		CBlob@ flour = getBlobByNetworkID(flour_blob_id);
		s32 producing_finish_time = this.get_s32("producing_finish_time");
		s32 time_before_produce = producing_finish_time - getGameTime();
		if (flour is null && time_before_produce < 0)
		{
			this.set_s32("producing_finish_time", getGameTime() + producing_time);
			@flour = server_CreateBlob("flour", this.getTeamNum(), this.getPosition());
			this.set_u16("flour_blob_id", flour.getNetworkID());
		}
	}
}