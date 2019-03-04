// red barrier before match starts

const f32 BARRIER_PERCENT = 0.33f; //0.265f;
bool barrier_set = false;

bool shouldBarrier( CRules@ this )
{
	return this.isIntermission() || this.isWarmup() || this.isBarrier();
}

void onTick( CRules@ this )
{
	if ( shouldBarrier(this) )
	{
		if(!barrier_set)
		{
			barrier_set = true;
			addDoubleBarrier();
		}
		
		f32 x1, x2, y1, y2, x21, x22, y21, y22;
		getDoubleBarrierPositions( x1, x2, y1, y2, x21, x22, y21, y22);
		const f32 middle1 = x1+(x2-x1)*0.5f;
		const f32 middle2 = x21+(x22-x21)*0.5f;

		CBlob@[] blobsInBox1;
		if (getMap().getBlobsInBox( Vec2f(x1,y1), Vec2f(x2,y2), @blobsInBox1 ))
		{
			for (uint i = 0; i < blobsInBox1.length; i++)
			{
				CBlob @b = blobsInBox1[i];
				if (b.getTeamNum() < 100)
				{
					Vec2f pos = b.getPosition();
					
					f32 f = b.getMass() * 2.0f;
					
					if (pos.x < middle1) {
						b.AddForce( Vec2f(-f,-f*0.1f) );
					}
					else {
						b.AddForce( Vec2f(f,-f*0.1f) );
					}
				}
			}
		}
		CBlob@[] blobsInBox2;
		if (getMap().getBlobsInBox( Vec2f(x21,y21), Vec2f(x22,y22), @blobsInBox2 ))
		{
			for (uint i = 0; i < blobsInBox2.length; i++)
			{
				CBlob @b = blobsInBox2[i];
				if (b.getTeamNum() < 100)
				{
					Vec2f pos = b.getPosition();
					
					f32 f = b.getMass() * 2.0f;
					
					if (pos.x < middle2) {
						b.AddForce( Vec2f(-f,-f*0.1f) );
					}
					else {
						b.AddForce( Vec2f(f,-f*0.1f) );
					}
				}
			}
		}
		
	}
	else
	{
		if(barrier_set)
		{
			removeDoubleBarrier();
			barrier_set = false;
		}
	}
}

void onRestart(CRules@ this)
{
	barrier_set = false;
}


void onRender( CRules@ this )
{
	if (shouldBarrier( this ))
	{
		f32 x1, x2, y1, y2, x21, x22, y21, y22;
		getDoubleBarrierPositions( x1, x2, y1, y2, x21, x22, y21, y22);
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( x1, y1 )), getDriver().getScreenPosFromWorldPos(Vec2f( x2, y2)), SColor( 100, 235, 0, 0 ) ); 
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( x21, y21 )), getDriver().getScreenPosFromWorldPos(Vec2f( x22, y22)), SColor( 100, 235, 0, 0 ) ); 
	}
}

void getBarrierPositions( f32 &out x1, f32 &out x2, f32 &out y1, f32 &out y2 )
{
	CMap@ map = getMap();
	const f32 mapWidth = map.tilemapwidth * map.tilesize;
	const f32 mapMiddle = mapWidth * 0.5f;
	const f32 barrierWidth = BARRIER_PERCENT * mapWidth;
	x1 = mapMiddle - barrierWidth;
	x2 = mapMiddle + barrierWidth;
	y2 = map.tilemapheight * map.tilesize;
	y1 = -y2;	
	y2 *= 2.0f;
}

void getDoubleBarrierPositions( f32 &out x1, f32 &out x2, f32 &out y1, f32 &out y2, f32 &out x21, f32 &out x22, f32 &out y21, f32 &out y22 )
{
	CMap@ map = getMap();
	const f32 mapWidth = map.tilemapwidth * map.tilesize;
	const f32 mapMiddle = mapWidth * 0.5f;
	const f32 barrierWidth = BARRIER_PERCENT * mapWidth;
	const f32 barrierGapWidth = barrierWidth * 0.66f;
	x1 = mapMiddle - barrierWidth;
	x2 = mapMiddle - barrierGapWidth;
	x21 = mapMiddle + barrierGapWidth;
	x22 = mapMiddle + barrierWidth;
	y2 = map.tilemapheight * map.tilesize;
	y1 = -y2;	
	y2 *= 2.0f;
	y22 = map.tilemapheight * map.tilesize;
	y21 = -y2;	
	y22 *= 2.0f;
}

/**
 * Adding the barrier sector to the map
 */

void addBarrier()
{
	CMap@ map = getMap();
	
	f32 x1, x2, y1, y2;
	getBarrierPositions( x1, x2, y1, y2 );
	
	Vec2f ul(x1,y1);
	Vec2f lr(x2,y2);
	
	if(map.getSectorAtPosition( (ul + lr) * 0.5, "barrier" ) is null)
		map.server_AddSector( Vec2f(x1, y1), Vec2f(x2, y2), "barrier" );
}

void addDoubleBarrier(){
	
	CMap@ map = getMap();
	
	f32 x1, x2, y1, y2, x21, x22, y21, y22;
	getDoubleBarrierPositions( x1, x2, y1, y2, x21, x22, y21, y22);
	
	Vec2f ul(x1,y1);
	Vec2f lr(x2,y2);
	
	Vec2f ul2(x21,y21);
	Vec2f lr2(x22,y22);
	
	if(map.getSectorAtPosition( (ul + lr) * 0.5, "barrier" ) is null)
		map.server_AddSector( Vec2f(x1, y1), Vec2f(x2, y2), "barrier" );
		
	if(map.getSectorAtPosition( (ul2 + lr2) * 0.5, "barrier" ) is null)
		map.server_AddSector( Vec2f(x21, y21), Vec2f(x22, y22), "barrier" );

}


/**
 * Removing the barrier sector from the map
 */

void removeBarrier()
{
	CMap@ map = getMap();
	
	f32 x1, x2, y1, y2;
	getBarrierPositions( x1, x2, y1, y2 );
	
	Vec2f ul(x1,y1);
	Vec2f lr(x2,y2);
	
	map.RemoveSectorsAtPosition( (ul + lr) * 0.5 , "barrier" );
}

void removeDoubleBarrier()
{
	CMap@ map = getMap();
	
	f32 x1, x2, y1, y2, x21, x22, y21, y22;
	getDoubleBarrierPositions( x1, x2, y1, y2, x21, x22, y21, y22);
	
	Vec2f ul(x1,y1);
	Vec2f lr(x2,y2);
	
	Vec2f ul2(x21,y21);
	Vec2f lr2(x22,y22);
	
	map.RemoveSectorsAtPosition( (ul + lr) * 0.5 , "barrier" );
	map.RemoveSectorsAtPosition( (ul2 + lr2) * 0.5 , "barrier" );
}
