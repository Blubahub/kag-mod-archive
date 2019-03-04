#include "Mooks.as"

int MOOKS = 1;

void onTick(CRules@ this)
{
	if (!this.isMatchRunning())
		return;

    CBlob@[] mooks;
    if (getBlobsByTag( "mook", @mooks ))
    {
    }

    if (getGameTime() % 450 == 0){
    	MOOKS++;
    	printf("MOOKS " + MOOKS);
    }

    if (mooks.length < MOOKS && getLocalPlayer() !is null && getLocalPlayer().getBlob() !is null)
    {
     //   SpawnMook();
    }
}

void onRestart(CRules@ this)
{
	MOOKS = 1;
}