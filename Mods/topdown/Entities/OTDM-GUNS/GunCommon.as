
void onInit(CBlob@ this)
{
	this.Tag("item");
	this.Tag("gun");
	if(this.getName() == "ak" || this.getName() == "flamer" || this.getName() == "mg" )
	{
		this.Tag("hold");
	}
	else
	{
		this.Tag("spam");
	}
}