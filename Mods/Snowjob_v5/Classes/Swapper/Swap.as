
void onInit(CBlob@ this)
{
	this.set_u16("swap",0);
	this.set_u8("timer", 0);
}

void onTick(CBlob@ this) 
{
	CBlob@ target = getBlobByNetworkID(this.get_u16("swap"));
	if (target !is null)
	{
		target.setPosition(this.getPosition());
	}
	
	this.set_u8("timer", this.get_u8("timer")+1);
	if(this.get_u8("timer") > 10)this.server_Die();
}