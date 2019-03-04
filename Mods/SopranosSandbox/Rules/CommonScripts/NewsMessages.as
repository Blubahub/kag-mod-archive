#define CLIENT_ONLY

const u16 NEWS_INTERVAL = 1800;

const string[] news_messages = {
    "We are looking for admins! If you are interested in joining, then visit KAG forums/groups/The Sopranos community or go directly to tiny.cc/Sopranos and join our Social Forum!",   // forums group
    "For more information on our servers visit tiny.cc/Sopranos",      // adveritsement
    "In order to use wings, pick them up and press v key."
};

void onTick( CRules@ this )
{
    if ( getGameTime() % NEWS_INTERVAL == 0 )
    {
        client_AddToChat(news_messages[XORRandom(news_messages.length)], SColor(255, 0, 152, 100));
    }
}