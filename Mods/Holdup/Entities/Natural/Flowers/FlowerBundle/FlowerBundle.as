/*
void onInit(CBlob @this){
	this.set_u16("created",getGameTime());
}


void onTick(CBlob@ this)
{
	if(this.get_u16("created") == getGameTime()-(30*60)){
		if(getNet().isServer()){
			server_CreateBlob("herb",-1,this.getPosition());
			this.server_Die();
		}
	
	}
}*/

void onTick(CSprite@ this)
{
	this.SetZ(100.0f);
}