







void onTick(CBlob@ this)
{
	/*if(this.getControls() is null){print("no controls"); return;}
	CControls@ controls = this.getControls();
	Vec2f mousePos = controls.getMouseScreenPos();*/

	Vec2f mousePos = this.getAimPos();
	bool clicked = this.isKeyJustPressed(key_action1);

	if(clicked)
	{
		print("repath");
		Repath(this, mousePos);
	}
	string state = this.get_string("state");
	if(state == "moving")
	{
		u16 node_next = this.get_u16("node_next");
		u16 node_count = this.get_u16("node_count");
		Vec2f node_pos = this.get_Vec2f("node"+node_next);
		Vec2f pos = this.getPosition();
		Vec2f diff = node_pos - pos;
		diff.Normalize();
		f32 angle = diff.Angle();
		this.AddForce(diff*100);
		//diff*=10;
		//this.setPosition(pos+diff);

		if(node_next == node_count -1)
		{
			print("last node");
		}
	}
}

void Repath(CBlob@ this, Vec2f mousePos)
{
	string state = this.get_string("state");
	print("mouse pos: "+mousePos.x+", "+mousePos.y);
	//this.setPosition(mousePos);

	this.set_string("state", "pathing");
	this.set_Vec2f("targetpos", mousePos);

	if(!canSeePosition(this.getPosition(), mousePos) || this !is null)
	{
		print("cant see");
		getPathTo(this, mousePos);
	}

}

bool canSeePosition(Vec2f pos, Vec2f targetPos)
{
	Vec2f col;
	return !getMap().rayCastSolid(pos, targetPos, col);
}

void getPathTo(CBlob@ this, Vec2f targetPos)
{
	this.set_string("state", "pathing");
	Vec2f pos = this.getPosition();

	Vec2f diff = targetPos - pos;
	print("diff: "+diff.x+", "+diff.y);
	f32 length = diff.Length();
	f32 angle = diff.Angle();
	//print("diff angle: "+angle);

	f32 angleRand = angle-40+XORRandom(80);
	//print("RANDOM angle: "+angleRand);
	Vec2f try = Vec2f(length*0.7, 0);
	try.RotateBy(-angleRand);
	try = pos+try;
	CBlob@ sponge = server_CreateBlob("sponge", this.getTeamNum(), try);

	if(canSeePosition(this.getPosition(), try) && canSeePosition(try, targetPos))
	{
		this.set_string("state", "moving");
		print("moving!");
		this.set_u16("node_count", 2);
		this.set_u16("node_next", 1);
		this.set_Vec2f("node1", try);
	}

	//this.setPosition(try);

}