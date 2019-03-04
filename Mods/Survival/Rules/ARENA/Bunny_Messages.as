#define CLIENT_ONLY
const u16 MESSAGE_INTERVAL = 60 * 30;
const string[] messages = {
	
	// -- GAME INFO
	"Build A Kitchen to Get Food!",
	"Make a Chicken Coop for steady food!",
	
};
int counter = 0;
int counteri = 0;
void onTick( CRules@ this )
{
	
	if(counteri == MESSAGE_INTERVAL)
	{
	    client_AddToChat(messages[counter++ % messages.length], SColor(255, 125, 0, 0));
		counteri = 0;
	}
	else 
	{
	    counteri++;
	}
}
