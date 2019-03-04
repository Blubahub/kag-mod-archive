

const int MENUHEIGHT = 6;
const int MENUWIDTH = 6;

const Vec2f BUTTONSIZE = Vec2f(1,1);
const string texname = "GUI/NewHeads.png";
const string DESC = "Select Head";

array<string> HEADFRAME(HEADCOUNT);
const int HEADCOUNT = 36;

array<string> PLAYER;

array<string> OWNER(HEADCOUNT * 4);

CRules@ headRules;

int PLAYER_OWNS_COUNT = 0;
array<int> PLAYER_HEAD(PLAYER_OWNS_COUNT);
array<string> PLAYER_OWNS(PLAYER_OWNS_COUNT);

void onInit( CRules@ this )
{
	for (int n = 0; n < HEADCOUNT; n++)
	{
		HEADFRAME[n] = "$HEAD" + n + "$";
		this.addCommandID(HEADFRAME[n]);
	}
	
	for (int i = 0; i < HEADCOUNT; i++)
	{	
		int frame = i * 4;
		AddIconToken( HEADFRAME[i], texname, Vec2f(16,16), frame);
	}
	
	this.addCommandID("default");
	AddIconToken( "$rem$", "MenuItems.png", Vec2f(32,32), 13 );
	AddIconToken( "$vilereaver41$", texname, Vec2f(16,16), 44 );
	this.addCommandID("vilereaver41");
}
void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )
{
	if (blob !is null && player !is null)
	{
		for (int i = 0; i < PLAYER_OWNS.length; i++)
		{
			if (PLAYER_OWNS[i] == player.getUsername())
			{
				blob.set_u32("new_head", PLAYER_HEAD[i]);
				blob.Tag("custom_head");
			}
		}		
	}

}

void onTick( CRules@ this  )
{
	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }
	
	CControls@ controls = getControls();
	if ( controls.isKeyJustPressed( KEY_KEY_V )){
		ShowMenu(this, p);
	}
}

void ShowMenu( CRules@ this, CPlayer@ player)
{
	getHUD().ClearMenus(true);

	CBitStream params;
    	params.write_u16( player.getNetworkID() );
	Vec2f center = getDriver().getScreenCenterPos();
	CGridMenu@ menu = CreateGridMenu( center, null , Vec2f(MENUWIDTH, MENUHEIGHT), "Submit your head at tiny.cc/funservers !" );//width = 6, height = 2
	for (int i = 0; i < HEADCOUNT; i++){
		CGridButton@ button =  menu.AddButton( HEADFRAME[i], DESC, this.getCommandID(HEADFRAME[i]), BUTTONSIZE, params );
	}
	CGridButton@ DonatorButton;
	if (player.getUsername() == "vilereaver41") 
		@DonatorButton = menu.AddButton( "$vilereaver41$", "Your own head", this.getCommandID("vilereaver41"), BUTTONSIZE, params );
		
	CGridMenu@ remMenu = CreateGridMenu( Vec2f(center.x,center.y+(MENUHEIGHT*45)), null , Vec2f(2, 2), "Change head to vanilla" );//width = 6, height = 2
	CGridButton@ remBtn =  remMenu.AddButton( "$rem$", "Change head to vanilla", this.getCommandID("default"), Vec2f(2,2), params );
	
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	CPlayer@ p = getPlayerByNetworkId( params.read_u16() );
	CBlob@ blob;
	if (p !is null) @blob = p.getBlob();
	for (int i = 0; i < HEADCOUNT; i++)
	{	
		if (cmd == this.getCommandID(HEADFRAME[i]))
			LoadHead(this, p, i);	
	}
	if (cmd == this.getCommandID("vilereaver41"))
	{
		LoadHead(this, p, 44);
	}
	if (cmd == this.getCommandID("default"))
	{
		for (int i = 0; i < PLAYER_HEAD.length; i++)
		{
			if (PLAYER_OWNS[i] == p.getUsername())
			{
				PLAYER_OWNS.removeAt(i);
				PLAYER_HEAD.removeAt(i);
				if (blob !is null) blob.Untag("custom_head");
			}
		}
	}
}

void LoadHead(CRules@ this, CPlayer@ player, int head)
{
	CBlob@ blob;
	string playerName = player.getUsername();
	if (player !is null)
	{
		@blob = player.getBlob();
		if (blob !is null)
		{
			if (blob.hasTag("custom_head"))
			{
				for (int i = 0; i < PLAYER_OWNS.length; i++)
				{
					if (PLAYER_OWNS[i] == playerName)
					{
						PLAYER_HEAD[i] = head;
					}
				}
			}
			else
			{
				PLAYER_OWNS_COUNT++;
				PLAYER_HEAD.insertLast(head);
				PLAYER_OWNS.insertLast(playerName);
			}
		}
	}
}