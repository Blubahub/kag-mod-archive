#define CLIENT_ONLY
//Made by Vamist
const int X = getScreenWidth();
const int Y = getScreenHeight();

class hudData
{
	Vec2f TopLeft;
	Vec2f BotRight;
	string BlobName;
	string ImageID;
	int ObjAmount;
	SColor Col;

	hudData(Vec2f TopLeftCorner, Vec2f BotRightCorner, string name,string imageName)
	{
		TopLeft = TopLeftCorner;
		BotRight = BotRightCorner;
		ImageID = imageName;
		BlobName = name;
		Col = SColor(255,255,255,255);
	}

	void addVertextPos()
	{
		v_r_invoBack.push_back(Vertex(TopLeft.x ,  TopLeft.y ,  1, 0, 0, Col));
		v_r_invoBack.push_back(Vertex(BotRight.x,  TopLeft.y ,  1, 1, 0, Col));
		v_r_invoBack.push_back(Vertex(BotRight.x,  BotRight.y,  1, 1, 1, Col));
		v_r_invoBack.push_back(Vertex(TopLeft.x ,  BotRight.y,  1, 0, 1, Col));
	}
}


class groupedHudData
{
	hudData[] DataArray;

	int Gap = 20;//Pixel gap between each 'slot'
	Vec2f TopLeftStartPos = Vec2f(50,50);
	Vec2f BotRightStartPos = Vec2f(70,70);

	groupedHudData()
	{

	}

	void addBlob(CBlob@ blob)
	{
		for(int a = 0; a < DataArray.length(); ++a)
		{
			if(DataArray[a].BlobName == blob.getName())
			{
				DataArray[a].ObjAmount += blob.getQuantity();
				return;
			}
		}

		newHud(blob);
	}

	void newHud(CBlob@ blob)
	{
		print(DataArray.length()+ "");
		u8 num = Gap + (Gap * (1 + DataArray.length()));
		Vec2f tempTop = Vec2f(TopLeftStartPos.x,TopLeftStartPos.y + num);
		Vec2f tempBot = Vec2f(BotRightStartPos.x,BotRightStartPos.y + num);
		//tempTop.y += Gap * num;
		//tempBot.y += Gap * num;
		hudData tempData = hudData(tempTop,tempBot,blob.getName(),blob.getSprite().getFilename());
		DataArray.push_back(tempData);
		tempData.addVertextPos();
	}

}


void onInit(CBlob@ this)
{
	Reset();
}

void onInit(CSprite@ this)
{
	Reset();
}

void Reset()
{
	print("hello there");
	Render::addScript(Render::layer_objects, "DefaultActorHUD.as", "hiHud", 0.0f);

}

void hiHud(int id)//New onRender
{
	CPlayer@ p = getLocalPlayer();
	byeHud(p,p.getBlob());
}

groupedHudData Data = groupedHudData();
Vertex[] v_raw;
Vertex[] v_r_hearts;
Vertex[] v_r_invoBack;

void byeHud(CPlayer@ p, CBlob@ this)
{
	Render::SetTransformScreenspace();
	Render::RawQuads("backdrop.png", v_r_invoBack);
}


void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	print("hoi");
	Data.addBlob(blob);
}

void onRemoveFromInventory( CBlob@ this, CBlob@ blob )
{
	print(blob.getName());
}

