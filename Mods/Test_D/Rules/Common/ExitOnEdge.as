#define CLIENT_ONLY

#include "MainMenuCommon.as"

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	CBlob@ blob = getLocalPlayerBlob();
	if(this.get_s16("in menu") > 0 || map is null || blob is null || blob.isAttached()) return;

	Vec2f pos = blob.getPosition();
	if (pos.x < map.tilesize || pos.x > (map.tilemapwidth-1)*map.tilesize)
	{
		OpenMenu(this);
	}
}

void OpenMenu(CRules@ this)
{
//	getHUD().ShowCursor();
	//ShowMultiplayerMenu( this, null, null );


	UI::Clear();
	UI::SetFont("menu");
	UI::AddGroup("title", Vec2f(0, 0), Vec2f(1.0f, 0.4));
	UI::Grid(1, 1);
	UI::Image::Add("TitleScreen.png");
	UI::AddGroup("escmenu", Vec2f(0.2f, 0.4), Vec2f(0.8, 1));
	UI::Grid(2, 1);

	UI::Button::Add("ONLINE", ShowMultiplayerMenu);
	 UI::Label::Add("search new games");	
	UI::Transition(Vec2f(-1.0f, 0.0f));
	UI::SetLastSelection(0);	
}