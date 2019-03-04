


void onTick(CBlob@ this)
{

	for(int i = 0; i < 10; i += 1)if(this.getTeamNum() == i)this.Tag("key"+i);

}