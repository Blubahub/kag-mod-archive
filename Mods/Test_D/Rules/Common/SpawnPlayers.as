#define SERVER_ONLY
#define ALWAYS_ONRELOAD
#include "RulesCommon.as"

void onReload(CRules@ this)
{
    CBlob@[] players;
    if (getBlobsByName( "soldier", @players ))
    {
        for (uint step = 0; step < players.length; ++step)
        {
            CBlob@ blob = players[step];
            CPlayer@ player = blob.getPlayer();
            if (player !is null){
                player.server_setClassNum( blob.get_u8("class") );
                CBlob@ newBlob = SpawnPlayer( this, player );
                if (newBlob !is null){
                    newBlob.setPosition( blob.getPosition() );
                }
            }
        }
    }
    // spawn players without blobs
    for (uint i=0; i < getPlayersCount(); i++)
    {
        CPlayer@ player = getPlayer(i);
        if (player.getBlob() is null)
        {
            SpawnPlayer( this, player );
        }
    }
}