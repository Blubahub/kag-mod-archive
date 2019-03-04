
#include "Hitters.as";

void onTick(CBlob@ this)
{
	handleShit(this);
}

void handleShit(CBlob@ this)
{
	//if(getNet().isClient()) print("client");
	u8 timer = this.get_u8("hit_timer");
	if(timer > 0) this.set_u8("hit_timer", timer-1);

	s32 speed = 25;
	/*if(this.getControls() is null){//print("no controls"); return;}
	CControls@ controls = this.getControls();
	Vec2f mousePos = controls.getMouseScreenPos();*/

	Vec2f mousePos = this.getAimPos();
	bool clicked = this.isKeyJustPressed(key_action1);

	if(clicked)
	{
		//print("repath");
		Repath(this, mousePos);
	}

	u16 id = this.get_u16("target_id");
	CBlob@ target = getBlobByNetworkID(id);

	if(XORRandom(100) == 1 && this.get_string("state2") != "chasing" && getNet().isServer()) 
	{
		Vec2f targetPos = this.getPosition();
		targetPos.x +=(-500+(XORRandom(1000)));
		targetPos.y +=(-500+(XORRandom(1000)));

		Repath(this, targetPos);
	}	

	//if(getNet().isClient()) print("client2");
	if(XORRandom(30) == 1 && this.get_string("state2") == "chasing" && getNet().isServer()) 
	{
		if(target !is null)
		{
			Repath(this, target.getPosition());
		}
		else
		{
			print("null target");
			this.set_string("state2", "idle");
		}
	}
//get target
	if(XORRandom(100) == 1 && this.get_string("state2") != "chasing") 
	{
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), 150.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if(b.getName() == "person")
				{
					print("person noticed");
					if(canSeePosition(this.getPosition(), b.getPosition()))
					{

					//if(getNet().isClient()) print("client2b");
						print("enemy noticed");
						this.set_u16("target_id", b.getNetworkID());
						this.set_string("state2", "chasing");
					}
				}
			}
		}
	}

	string state = this.get_string("state");
	string state2 = this.get_string("state2");
	if(state == "moving" || state2 == "chasing")
	{

		//if(getNet().isClient()) print("client3");
		u16 node_next = this.get_u16("node_next");
		u16 node_count = this.get_u16("node_count");



		////print("node: "+node_next+" count: "+node_count);
		Vec2f node_pos = this.get_Vec2f("node"+node_next);
		Vec2f node_pos_next = this.get_Vec2f("node"+(node_next+1));
		Vec2f pos = this.getPosition();
		Vec2f diff = node_pos - pos;
		if(this.get_string("state2") == "chasing" && target !is null && canSeePosition(pos, target.getPosition()))
		{
			Vec2f targetPos = target.getPosition();
			diff = targetPos - pos;
			f32 dist = diff.Length();

			if(dist < 30)
			{
				speed = -10;
				if(timer == 0)
				{
					this.server_Hit(target, targetPos, Vec2f(10,10), 0.5f, Hitters::arrow, true); 
					this.set_u8("hit_timer", 30+(XORRandom(10)));

				}
			}
		}
		diff.Normalize();
		f32 angle = diff.Angle();
		//print("targetPos: "+this.get_Vec2f("target_pos").x+", "+this.get_Vec2f("target_pos").y);
		this.AddForce(diff*speed);
		if(node_next <= node_count)this.setAngleDegrees(-angle+90);
		//diff*=10;
		//this.setPosition(pos+diff);
		//print("nextpos: "+node_pos_next.x + ", "+ node_pos_next.y);

		if(node_pos_next != Vec2f(0, 0) && canSeePosition(pos, this.get_Vec2f("target_pos")))
		{
			//print("found quicker route");
			this.set_u16("node_next", node_count);
		}

		if(node_next > node_count)
		{
				
			this.set_u16("node_count", 0);
			this.set_string("state", "idle");
			this.set_u16("node_next", 0);
			return;
		}

		//if(getNet().isClient()) print("client5");
		if(XORRandom(16) > 8 )
		{
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(node_pos, 32.0f, @blobsInRadius))
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					if (b is this)
					{
						//print("node reached!");

						this.set_u16("node_next", node_next+1);

					}
				}
			}
		}
		//if(getNet().isClient()) print("client6");
	}	
}
void Repath(CBlob@ this, Vec2f mousePos)
{
	string state = this.get_string("state");
	//print("mouse pos: "+mousePos.x+", "+mousePos.y);
	//this.setPosition(mousePos);

	this.set_string("state", "pathing");
	this.set_Vec2f("target_pos", mousePos);

	if(!canSeePosition(this.getPosition(), mousePos) || this !is null)
	{
		//print("cant see");
		getPathTo(this, mousePos, 0);
	}

}

bool canSeePosition(Vec2f pos, Vec2f targetPos)
{
	Vec2f col;
	return !getMap().rayCastSolid(pos, targetPos, col);
}

void getPathTo(CBlob@ this, Vec2f targetPos, u16 tryCount)
{
	CMap@ map = getMap();
	if(tryCount > 160)
	{ 
		getLongPathTo(this, targetPos, 0);
		return;
	} 

	this.set_string("state", "pathing");
	Vec2f pos = this.getPosition();

	Vec2f diff = targetPos - pos;
	f32 length = diff.Length();
	f32 angle = diff.Angle();

	f32 angleRand = angle-tryCount*2+XORRandom(tryCount*4);
	Vec2f try = Vec2f(length*(40+tryCount+XORRandom(80))/100.0f, 0);
	try.RotateBy(-angleRand);

	try = pos+try;	
	if(try.y < 0) try.y = 0;
	if(try.x < 0) try.x = 0;
	if(targetPos.x < 0) targetPos.x = 20;
	if(targetPos.y < 0) targetPos.x = 20;
	if(targetPos.x > map.tilemapwidth*8) targetPos.x = map.tilemapwidth*8-20;
	if(targetPos.y > map.tilemapwidth*8) targetPos.y = map.tilemapwidth*8-20;
	if(canSeePosition(this.getPosition(), try) && canSeePosition(try, targetPos))
	{

		this.set_string("state", "moving");
		this.set_u16("node_count", 2);
		this.set_u16("node_next", 1);
		this.set_Vec2f("node1", try);
		this.set_Vec2f("node2", targetPos);
		return;
	}
	else getPathTo(this, targetPos, tryCount+1);


}
void getLongPathTo(CBlob@ this, Vec2f targetPos, u16 tryCount)
{

	this.set_string("state", "pathing");
	Vec2f pos = this.getPosition();

	Vec2f diff = targetPos - pos;
	f32 length = diff.Length();
	f32 angle = diff.Angle();

	if(tryCount > 700)
	{ 
		return;
	} 
//(length*(50))/100.0f
	f32 angleRand = -angle+(tryCount-(XORRandom(tryCount*2)));//angle-tryCount/6+XORRandom(tryCount/3);
	Vec2f try = Vec2f(XORRandom(200)+XORRandom(tryCount), 0);
	try.RotateBy(angleRand);

	try = pos+try;	

	if(canSeePosition(this.getPosition(), try))
	{
		Vec2f diff2 = targetPos - try;
		f32 length2 = diff2.Length();
		f32 angle2 = diff2.Angle();
		f32 angleRand2 = -tryCount*0.5+XORRandom(tryCount);

		Vec2f try2b = Vec2f(length2/2+(XORRandom(tryCount*4)/100), 0);
		try2b.RotateBy(XORRandom(360));

		Vec2f try2 = try + try2b;
		try2.RotateBy(-angleRand2);

		try2 = targetPos + try2b;
		if(try2.y < 0) try2.y = 0;
		if(try2.x < 0) try2.x = 0;


		if(canSeePosition(try, try2) && canSeePosition(try2, targetPos))
		{
			this.set_string("state", "moving");
			this.set_u16("node_count", 3);
			this.set_u16("node_next", 1);
			this.set_Vec2f("node1", try);
			this.set_Vec2f("node2", try2);
			this.set_Vec2f("node3", targetPos);
			return;
		}
		else getLongPathTo(this, targetPos, tryCount+1);
	}

	else getLongPathTo(this, targetPos, tryCount+1);


}