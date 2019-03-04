//blob to do rank stuff

string rank_config_file = "../Cache/Rank.cfg";

void onInit(CBlob@ this)
{

}


bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}


void onTick(CBlob@ this)
{
	print("Yesss");
	this.server_Die();
}
