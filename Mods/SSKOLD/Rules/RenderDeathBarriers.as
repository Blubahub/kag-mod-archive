// render red barrier of death around maps

f32 mapWidth = 0;
f32 mapHeight = 0;

const f32 BARRIER_WIDTH = 8;
const SColor BARRIER_COLOR = SColor(100, 235, 0, 0);

void onTick(CRules@ this)
{
	updateMapVars();
}

void updateMapVars()
{
	CMap@ map = getMap();
	mapWidth = map.tilemapwidth * map.tilesize;
	mapHeight = map.tilemapheight * map.tilesize;
}


bool shouldRenderBarrier( CRules@ this )
{
	return true;
}

void onRender( CRules@ this )
{
	if (shouldRenderBarrier( this ))
	{
		f32 top_x1, top_x2, top_y1, top_y2;
		getTopBarrierPositions( top_x1, top_x2, top_y1, top_y2 );
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( top_x1, top_y1 )), getDriver().getScreenPosFromWorldPos(Vec2f( top_x2, top_y2)), BARRIER_COLOR );

		f32 bottom_x1, bottom_x2, bottom_y1, bottom_y2;
		getBottomBarrierPositions( bottom_x1, bottom_x2, bottom_y1, bottom_y2 );
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( bottom_x1, bottom_y1 )), getDriver().getScreenPosFromWorldPos(Vec2f( bottom_x2, bottom_y2)), BARRIER_COLOR );
		
		f32 left_x1, left_x2, left_y1, left_y2;
		getLeftBarrierPositions( left_x1, left_x2, left_y1, left_y2 );
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( left_x1, left_y1 )), getDriver().getScreenPosFromWorldPos(Vec2f( left_x2, left_y2)), BARRIER_COLOR ); 
		
		f32 right_x1, right_x2, right_y1, right_y2;
		getRightBarrierPositions( right_x1, right_x2, right_y1, right_y2 );
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( right_x1, right_y1 )), getDriver().getScreenPosFromWorldPos(Vec2f( right_x2, right_y2)), BARRIER_COLOR ); 

		// draw top right corner
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( mapWidth - BARRIER_WIDTH, 0 )), getDriver().getScreenPosFromWorldPos(Vec2f( mapWidth, BARRIER_WIDTH)), BARRIER_COLOR ); 

		// draw top left corner
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( 0, 0 )), getDriver().getScreenPosFromWorldPos(Vec2f( BARRIER_WIDTH, BARRIER_WIDTH)), BARRIER_COLOR ); 

		// draw bottom left corner
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( 0, mapHeight - BARRIER_WIDTH )), getDriver().getScreenPosFromWorldPos(Vec2f( BARRIER_WIDTH, mapHeight)), BARRIER_COLOR ); 

		// draw bottom right corner
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( mapWidth - BARRIER_WIDTH, mapHeight - BARRIER_WIDTH )), getDriver().getScreenPosFromWorldPos(Vec2f( mapWidth, mapHeight)), BARRIER_COLOR ); 
	}
}

void getTopBarrierPositions( f32 &out top_x1, f32 &out top_x2, f32 &out top_y1, f32 &out top_y2 )
{
	top_x1 = BARRIER_WIDTH;
	top_x2 = mapWidth - BARRIER_WIDTH;
	top_y1 = 0;
	top_y2 = BARRIER_WIDTH;
}

void getBottomBarrierPositions( f32 &out bottom_x1, f32 &out bottom_x2, f32 &out bottom_y1, f32 &out bottom_y2 )
{
	bottom_x1 = BARRIER_WIDTH;
	bottom_x2 = mapWidth - BARRIER_WIDTH;
	bottom_y1 = mapHeight - BARRIER_WIDTH;
	bottom_y2 = mapHeight;
}

void getLeftBarrierPositions( f32 &out left_x1, f32 &out left_x2, f32 &out left_y1, f32 &out left_y2 )
{
	left_x1 = 0;
	left_x2 = BARRIER_WIDTH;
	left_y1 = BARRIER_WIDTH;
	left_y2 = mapHeight - BARRIER_WIDTH;
}

void getRightBarrierPositions( f32 &out right_x1, f32 &out right_x2, f32 &out right_y1, f32 &out right_y2 )
{
	right_x1 = mapWidth - BARRIER_WIDTH;
	right_x2 = mapWidth;
	right_y1 = BARRIER_WIDTH;
	right_y2 = mapHeight - BARRIER_WIDTH;
}
