#define CLIENT_ONLY
const u16 MESSAGE_INTERVAL = 60 * 30;
const string[] messages = {
	
	// -- GAME INFO
	"You can obtain wood by beating bushes senseless",
	"You can build crap by punching f on your keyboard",
	"Use the W A S D keys on your keyboard to make \n your bunny's jets push him/her in the specified direction",
	"Play the god d*** game pweeez",
	"To initiate twerk mode use the left mouse button",
	"You cant suicide as a bunny, because they are to pure",
	"If you can read your half way to winning this game",
	"Potatoes :D",
	"No god d*** swearing or any of that s***",
	"When in doubt, spam a admin until they help you",
	"Just a tip, Mutants likely have rabies",
	"If you think someone should be kicked, they think you should be kicked",
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
