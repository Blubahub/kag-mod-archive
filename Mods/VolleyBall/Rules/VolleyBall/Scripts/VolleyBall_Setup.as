
int direction = -1;	
bool CloudyDay;

const string texture_name = "WavesTexture.png";

void Setup()
{
	//ensure texture for our use exists
	if(!Texture::exists(texture_name))
	{
		if(!Texture::createBySize(texture_name, 48, 48))
		{
			warn("texture creation failed");
		}
		else
		{
			ImageData@ edit = Texture::data(texture_name);

			for(int i = 0; i < edit.size(); i++)
			{
				edit[i] = SColor((((i + i / 8) % 2) == 0) ? 0xff707070 : 0xff909090);
			}

			if(!Texture::update(texture_name, edit))
			{
				warn("texture update failed");
			}
		}
	}
}

void onInit(CRules@ this)
{	
	Setup();
	int cb_id = Render::addScript(Render::layer_postworld, "VolleyBall_Setup.as", "RenderFunction", 500.0f);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (XORRandom(2) == 0) 
	{ direction = -1; }
	else 
	{ direction = 1; }

	if (XORRandom(2) == 0) 
	{ CloudyDay = false; }
	else 
	{ CloudyDay = true; }
	

	SetupArena(this);
}

void SetupArena(CRules@ this)
{
	if (getNet().isServer())
	{
		CMap@ map = getMap();
		if(map !is null)
		{	
			if (CloudyDay)
			{				
				for (int i = 0; i < 8; i++)
				{
					Vec2f pos = Vec2f((i+1)*80,32+XORRandom(64));
					CBlob @blob = server_CreateBlob("cloud"+(1+XORRandom(3)), -1, pos);
				}
			}

			Vec2f GroundMid = Vec2f((map.tilemapwidth * map.tilesize)/2, map.getLandYAtX(150.0f / map.tilesize) * map.tilesize -40.0f);
			CBlob@ nl = server_CreateBlob("net", -1, GroundMid);
			if (nl !is null)
			{
				nl.getSprite().SetZ(-100.0f);
				nl.getShape().SetStatic( true );
			}
			CBlob@ nr = server_CreateBlob("net", -1, GroundMid);
			if (nr !is null)
			{
				nr.getSprite().SetZ(500.0f);
				nr.getSprite().SetFacingLeft(true);
				nr.getShape().SetStatic( true );	
			}

		//	CBlob@ b = server_CreateBlob("balllauncher", -1, Vec2f(GroundMid.x+200.0f,GroundMid.y));
		//	if (b !is null)
		//	{
		//		//nr.getSprite().SetZ(500.0f);
		//		//nr.getSprite().SetFacingLeft(true);
		//		//nr.getShape().SetStatic( true );	
		//	}
		}
	}
}

void RenderFunction(int id)
{	
	RenderWaves();	
}

Vertex[] v_raw;
void RenderWaves()
{
	CMap@ map = getMap();
	string render_texture_name = texture_name;	
	const f32 z = 500.0;	
	const float x_size = 48.0;
	const float y_size = 32.0;	

	const int wavelength = 16;
	const f32 amplitude = 3.5;
	const f32 pi = 3.14159;

	const int wavecount = (map.tilemapwidth * map.tilesize)/x_size;
	const u16 mapheight =	map.tilemapheight * map.tilesize;
	const u16 mapwidth =	map.tilemapwidth * map.tilesize;

	Vec2f p = Vec2f(0,(map.tilemapheight * map.tilesize)-20);
	float time = (getGameTime() / 5.0f*direction);

	v_raw.clear();

	for (int i = 0; i < wavecount; i++)
	{		
		//   y =   amplitude * sin(2*Pi*(time+Offset)/length)

		f32 y1 =  -amplitude * Maths::Sin(2*pi*((time)+i)/wavelength);
		f32 y2 =  -amplitude * Maths::Sin(2*pi*((time)+i+1)/wavelength);

		v_raw.push_back(Vertex(p.x + x_size*i, 		p.y +		y1, 	z ,0,0, SColor(100,255,255,255)));
		v_raw.push_back(Vertex(p.x + x_size*(i+1),  p.y +		y2, 	z ,1,0, SColor(100,255,255,255)));
		v_raw.push_back(Vertex(p.x + x_size*(i+1),  p.y +	y_size, 	z ,1,1, SColor(255,0,0,0)));
		v_raw.push_back(Vertex(p.x + x_size*i, 		p.y + 	y_size, 	z ,0,1, SColor(255,0,0,0)));
	}

	Render::SetAlphaBlend(true);
	Render::RawQuads(render_texture_name, v_raw);
}
