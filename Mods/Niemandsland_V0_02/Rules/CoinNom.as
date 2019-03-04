//aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
#define SERVER_ONLY

void onTick(CRules@ this)
{
    if(getGameTime() % 120 == 0)
    {
        for(int a = 0; a < getPlayerCount(); a++)
        {
            CPlayer@ p = getPlayer(a);
            if(p !is null)
            {
               p.server_setCoins(p.getCoins() + 1);
            }
        }
    }
}