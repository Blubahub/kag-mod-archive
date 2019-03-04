

// Snow stuff
Vertex[] Verts;
SColor col(0xffffffff);

void onInit(CRules@ this)
{
    this.addCommandID("play sound");

    InitSnow();
    Render::addScript(Render::layer_background, "Christmas.as", "MoveSnow", 0);

	onRestart(this);
}

void onRestart(CRules@ this)
{
    
}
// Snow

void InitSnow()
{
    Verts.clear();
    CMap@ map  = getMap();
    int chunksX = map.tilemapwidth/32+2;
    int chunksY = map.tilemapheight/32+2;
    for(int cX = 0; cX < chunksX; cX++)
        for(int cY = 0; cY < chunksY; cY++)
        {
            Verts.push_back(Vertex((cX-1)*256, (cY)*256, -500, 0, 0, col));
            Verts.push_back(Vertex((cX)*256, (cY)*256, -500, 1, 0, col));
            Verts.push_back(Vertex((cX)*256, (cY-1)*256, -500, 1, 1, col));
            Verts.push_back(Vertex((cX-1)*256, (cY-1)*256, -500, 0, 1, col));
        }
}

void MoveSnow(int id)
{
    float[] trnsfm;
    for(int i = 0; i < 3; i++)
    {
        float gt = getGameTime()+30*i;
        float X = Maths::Cos(gt/40)*20;
        float Y = gt % 255;
        Matrix::MakeIdentity(trnsfm);
        Matrix::SetTranslation(trnsfm, X, Y, 0);
        Render::SetModelTransform(trnsfm);
        Render::SetAlphaBlend(true);
        Render::RawQuads("Snow.png", Verts);
    }
}