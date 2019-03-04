
void onInit(CRules@ this)
{
	this.addCommandID("sync_life");
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sync_life")){
		int PID = params.read_u16();
		int lives = params.read_u8();
		CPlayer @player = getPlayerByNetworkId(PID);
		if(player !is null){
			this.set_u8(player.getUsername()+"_lives",lives);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{	
	this.set_u8(player.getUsername()+"_lives",4);
	
	if(getNet().isServer()){
	
		ConfigFile cfg = ConfigFile("../Cache/player_lives.cfg");

		int lives = cfg.read_u16(player.getUsername(), 4);
		
		if(lives < 0)lives = 0;
		if(lives > 4)lives = 4;

		this.set_u8(player.getUsername()+"_lives",lives);
		
		CBitStream params;
		params.write_u16(player.getNetworkID());
		params.write_u8(lives);
		this.SendCommand(this.getCommandID("sync_life"), params);
	}
}



const f32 Scale = 1.0f;
const f32 PosScale = Scale*2.0f;

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ player = getLocalPlayer();
	
	if(getLocalPlayer() is null)return;
	
	Vec2f HUD = Vec2f(getScreenWidth()-(44*PosScale+12),getScreenHeight()-(191*PosScale+12));

	int lives = this.get_u8(player.getUsername()+"_lives");
	
	if(lives > 3)lives = 3;
	
	GUI::DrawIcon("LivesGUI.png", lives, Vec2f(44, 147), HUD, Scale);

	float time_length = 15*60*30;
	
	float time = getGameTime() % time_length;
	
	float segments = 100.0f;
	float time_till = time/time_length;
	
	if(time < 100)time_till = (100.0f-time)/100.0f; 
	
	for(int i = 0; i < segments*time_till;i++){
		GUI::DrawIcon("LivesBarGUI.png", (segments-1)-i, Vec2f(6, 1), HUD+Vec2f(35*PosScale,(102-i)*PosScale), Scale);
	}
	
}
