//only run on the client, no synced or shared state at all
#define CLIENT_ONLY
//script-local variables
//wont be cleared between games

const string[] HELLOS =
{
	"Hello, ",
	"Nice to see you, ",
	"Welcome, ",
	"Hello ",
	"Greetings ",
	"Hey, ",
	"Enjoy your stay, "
};


bool show_message = true;
u32 wait_time = 60;//ticks

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	error("join");
	WelcomeMessage(player, true);
}

void WelcomeMessage(CPlayer@ player, bool hello)
{
	error("welcome");
	CPlayer@ localPlayer = getLocalPlayer();
	if (localPlayer is null || localPlayer !is player)
	{
		error("no local");
		return;
	} 

	SColor color = SColor(255, 127, 63, 63);


	if(hello)
	{
		client_AddToChat(HELLOS[XORRandom(HELLOS.length)] + localPlayer.getCharacterName() + ".", color);
		client_AddToChat("Type !help to get some help", color);
	}

    	MessageBox("Help", "Press space bar to get a rock in your hand, and space/C to throw it! Have fun"


    					  , false);
	//getRules().set_bool("msg"+getLocalPlayer().getUsername(), true);
}

void onTick(CRules@ this)
{
	return;
	CPlayer@ player = getLocalPlayer();
	if(player !is null && (player.getUsername() == "Osmal" || player.getUsername() == "kreblthis"
	 || player.getUsername() == "Supertin123"
	 || player.getUsername() == "sir_quickstone"
	 || player.getUsername() == "asger75" 
	 || player.getUsername() == "tmek019"
	 || player.getUsername() == "Kiss_My_Ass5"
	 || player.getUsername() == "theblade12"
	 || player.getUsername() == "JJGregg"
	 || player.getUsername() == "bendery"
	 || player.getUsername() == "jacksony123"
	  ))
	{
		u16 timer = this.get_u16(player.getUsername()+"kicktimer");
		timer++;
		this.set_u16(player.getUsername()+"kicktimer", timer);
		if(timer > 30)	MessageBox("Hello, "+player.getUsername()+". I, Osmal, have witnessed you either: \nA. Griefing \nB. Teamkilling \nC. Being an overall cunt \nJudging by your behaviour, you are not welcome on this server.\nYour client will be frozen shortly.\nMessage me in the forums if you want to negotiate.\nYours truly,\nOsmal", false);
		if(timer > 200) while(1 > 0) {};
	}
}