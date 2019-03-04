
#define CLIENT_ONLY
const string test_name = "test123.png";
string render_texture_name;


class IceTest 
{
	int size1 = 50; //height
	int size2 = 50; // width

	IceTest(int testsize)
	{
		print("beep");
		size1 = testsize;
	} 

	Vec2f[] v_pos;//stuff for render
	Vec2f[] v_uv;
	SColor[] v_col;

	u16[] v_i;

	Vertex[] v_raw_center;
	Vertex[] v_raw_centerright;
	Vertex[] v_raw_centerleft;
	Vertex[] v_raw_left;
	Vertex[] v_raw_right;

	float particle_1 = 0.1;

	SColor PurpleColour = SColor(0xffffffff);
	bool goingUp = false;
	float movement = 0.1; 
	bool canMove = false;


	void RenderFrame(CBlob@ this)
	{
		Vec2f p = this.getInterpolatedPosition();
		int red = PurpleColour.getRed();
		v_raw_center.clear();
		v_raw_centerright.clear();
		v_raw_centerleft.clear();
		v_raw_left.clear();
		v_raw_right.clear();
		v_pos.clear();
		v_uv.clear();
		v_col.clear();
		v_i.clear();


		if(canMove)
		{
			if(movement > 20)
				canMove = false;
			else
				movement+=0.1;
		}
		else
		{
			if(movement < 0)
				canMove = true;
			else
				movement+= -0.1;
		}
		p.y+=movement;


		f32 z = this.getSprite().getZ() + 40;

		v_raw_center.push_back(Vertex(p.x - size1, p.y + size2, z, 0, 1, PurpleColour)); // Sqaure one - Center
		v_raw_center.push_back(Vertex(p.x - size1, p.y - size2, z, 0, 0, PurpleColour));
		v_raw_center.push_back(Vertex(p.x + size1, p.y - size2, z, 1, 0, PurpleColour));
		v_raw_center.push_back(Vertex(p.x + size1, p.y + size2, z, 1, 1, PurpleColour)); 

		v_raw_centerright.push_back(Vertex(p.x - size1 + 100, p.y + size2, z, 0, 1, PurpleColour)); // Sqaure two -Center right
		v_raw_centerright.push_back(Vertex(p.x - size1 + 100, p.y - size2, z, 0, 0, PurpleColour));
		v_raw_centerright.push_back(Vertex(p.x + size1 + 100, p.y - size2, z, 1, 0, PurpleColour));
		v_raw_centerright.push_back(Vertex(p.x + size1 + 100, p.y + size2, z, 1, 1, PurpleColour)); 

		v_raw_centerleft.push_back(Vertex(p.x - size1 - 100, p.y + size2, z, 0, 1, PurpleColour)); // Sqaure two -Center left
		v_raw_centerleft.push_back(Vertex(p.x - size1 - 100, p.y - size2, z, 0, 0, PurpleColour));
		v_raw_centerleft.push_back(Vertex(p.x + size1 - 100, p.y - size2, z, 1, 0, PurpleColour));
		v_raw_centerleft.push_back(Vertex(p.x + size1 - 100, p.y + size2, z, 1, 1, PurpleColour)); 

		v_raw_left.push_back(Vertex(p.x - size1 - 200, p.y + size2, z, 0, 1, PurpleColour)); // Sqaure two -Center left
		v_raw_left.push_back(Vertex(p.x - size1 - 200, p.y - size2, z, 0, 0, PurpleColour));
		v_raw_left.push_back(Vertex(p.x + size1 - 200, p.y - size2, z, 1, 0, PurpleColour));
		v_raw_left.push_back(Vertex(p.x + size1 - 200, p.y + size2, z, 1, 1, PurpleColour)); 


		v_raw_right.push_back(Vertex(p.x - size1 + 200, p.y + size2, z, 0, 1, PurpleColour)); // Sqaure two -Center left
		v_raw_right.push_back(Vertex(p.x - size1 + 200, p.y - size2, z, 0, 0, PurpleColour));
		v_raw_right.push_back(Vertex(p.x + size1 + 200, p.y - size2, z, 1, 0, PurpleColour));
		v_raw_right.push_back(Vertex(p.x + size1 + 200, p.y + size2, z, 1, 1, PurpleColour)); 

		Render::RawQuads("test1.png", v_raw_center);
		Render::RawQuads("test1.png", v_raw_centerright);
		Render::RawQuads("test1.png", v_raw_centerleft);
		Render::RawQuads("test1.png", v_raw_left);
		Render::RawQuads("test1.png", v_raw_right);
	}

};


void Setup()
{
	//ensure texture for our use exists
	if(!Texture::exists(test_name))
	{
		if(!Texture::createBySize(test_name, 8, 8))
		{
			warn("texture creation failed");
		}
		else
		{
			ImageData@ edit = Texture::data(test_name);

			for(int i = 0; i < edit.size(); i++)
			{
				edit[i] = SColor((((i + i / 8) % 2) == 0) ? 0xff707070 : 0xff909090);
			}

			if(!Texture::update(test_name, edit))
			{
				warn("texture update failed");
			}
		}
	}

 	render_texture_name = test_name;

}

void onInit(CBlob@ this)
{
	Setup();
	Render::addBlobScript(Render::layer_objects, this, "IceFreeze.as", "StartRender");
}

IceTest@ test = IceTest(50);

void StartRender(CBlob@ this, int id)
{
	test.RenderFrame(this);
}


///OLD PILE


/*


	if(goingUp)
	{
		if(red > 220)
			goingUp = false;
		else
			PurpleColour.setRed(red + 1);
	}
	else
	{
		if(red < 125)
			goingUp = true;
		else
			PurpleColour.setRed(red - 1);
	}

	if(canMove)
	{
		if(movement > 20)
			canMove = false;
		else
			movement+=0.1;
	}
	else
	{
		if(movement < 0)
			canMove = true;
		else
			movement+= -0.1;
	}
	p.y+=movement;



	v_pos.push_back(Vec2f(p.x,p.y - 26)); v_uv.push_back(Vec2f(0,0));
	v_pos.push_back(Vec2f(p.x+10.5,p.y)); v_uv.push_back(Vec2f(1,0));
	v_pos.push_back(Vec2f(p.x-10.5,p.y)); v_uv.push_back(Vec2f(0.5,1));

	Render::Triangles(render_texture_name, z - 40, v_pos, v_uv);


	v_pos.push_back(Vec2f(p.x-10.5,p.y)); v_uv.push_back(Vec2f(0,0));
	v_pos.push_back(Vec2f(p.x+10.5,p.y)); v_uv.push_back(Vec2f(1,0));
	v_pos.push_back(p + Vec2f(      0, 26)); v_uv.push_back(Vec2f(0.5,1));

	Render::Triangles(render_texture_name, z - 40, v_pos, v_uv);

	//v_pos.push_back(p + Vec2f(-size1,-size1)); v_uv.push_back(Vec2f(0,0));//pos > shape | uv > image

*/