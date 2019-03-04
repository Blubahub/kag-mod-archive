shared class FloorCoin
{
	Vec2f pos;
	Vec2f vel;
	const string filename = "FloorCoins.png";
	int frame = 0;
	int team_cooldown;
	
	void Update()
	{
		if (team_cooldown > 0)
		{
			team_cooldown--;
		}
		pos += vel;
		vel += Vec2f(0.0f, -1.0f)
	}
	
	void setFrame(int newFrame)
	{
		frame = newFrame;
	}
	
	void Draw()
	{
		GUI::DrawIcon(filename, frame, pos, 1.0f);
	}
	
	CPlayer@ GetPlayer()
	{
		
	}
}