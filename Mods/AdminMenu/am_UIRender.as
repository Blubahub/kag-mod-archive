//Made by Vamist
//Holds all the diffrent render stuff as part of the admin menu
Vertex[] v_background;
Vertex[] v_buttons;

//background
const Vec2f topLeftPos 				= Vec2f(0,0);
const Vec2f botRightPos 			= Vec2f(SCREEN_X,SCREEN_Y_HALF / 3);
//buttons
const int buttonSize = 40;
const int distanceBetween2 = 40;


Vec2f worldPosFromScreen(Vec2f screenpos)
{
	return getDriver().getWorldPosFromScreenPos(screenpos);
}

void RenderBackground(int id) // runs on render
{	
	v_background.clear();
	Vec2f topLeftPos 			= worldPosFromScreen(Vec2f(0,SCREEN_Y /3));
	Vec2f botRightPos 			= worldPosFromScreen(Vec2f(SCREEN_X/3,SCREEN_Y));

	v_background.push_back(Vertex(topLeftPos.x,topLeftPos.y,		 100, 1, 0, SColor(255,255,255,255)));//top
	v_background.push_back(Vertex(botRightPos.x,topLeftPos.y,		 100, 1, 1, SColor(255,255,255,255)));//top
	v_background.push_back(Vertex(botRightPos.x,botRightPos.y,		 100, 0, 1, SColor(255,255,255,255)));//top
	v_background.push_back(Vertex(topLeftPos.x,botRightPos.y,		 100, 0, 0, SColor(255,255,255,255)));//top

	Render::SetAlphaBlend(true);
	Render::RawQuads("background.png", v_background);
}

void renderButtons(int id)
{

	v_buttons.clear();
	CPlayer@ p = getLocalPlayer();
	int row = 1;
	int 
	Vec2f topLeftPos 			= worldPosFromScreen(Vec2f(0,SCREEN_Y /3));
	Vec2f botRightPos 			= worldPosFromScreen(Vec2f(SCREEN_X/3,SCREEN_Y));

	v_background.push_back(Vertex(topLeftPos.x,topLeftPos.y,		 100, 1, 0, SColor(255,255,255,255)));//top
	v_background.push_back(Vertex(botRightPos.x,topLeftPos.y,		 100, 1, 1, SColor(255,255,255,255)));//top
	v_background.push_back(Vertex(botRightPos.x,botRightPos.y,		 100, 0, 1, SColor(255,255,255,255)));//top
	v_background.push_back(Vertex(topLeftPos.x,botRightPos.y,		 100, 0, 0, SColor(255,255,255,255)));//top

	Render::SetAlphaBlend(true);
	Render::RawQuads("button.png", v_background);
}

