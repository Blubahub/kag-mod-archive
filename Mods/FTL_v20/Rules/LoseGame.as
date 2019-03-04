
void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(30);
}

void onDie(CBlob@ this){

	LoadNextMap();

}