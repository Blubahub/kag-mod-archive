
#include "Hitters.as";




void onInit(CBlob@ this)
{
	this.addCommandID("path");
	this.addCommandID("longpath");
	this.set_u32("hit_rate", 15);
	this.set_f32("hit_power", 0.5f);
	this.set_u32("cooldown", this.get_u32("hit_rate"));
	this.set_f32("damage", this.get_f32("hit_power"));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("path"))
	{
		Vec2f mousePos= this.getAimPos();
		getPathTo(this, mousePos, 0);
	}
	if (cmd == this.getCommandID("longpath"))
	{
	}
}
void onTick(CBlob@ this)
{
	s32 speed = 70;
	/*if(this.getControls() is null){//print("no controls"); return;}
	CControls@ controls = this.getControls();
	Vec2f mousePos = controls.getMouseScreenPos();*/

	u8 timer = this.get_u8("hit_timer");
	if(timer > 0) this.set_u8("hit_timer", timer-1);
	Vec2f mousePos = this.getAimPos();
	bool clicked = this.isKeyJustPressed(key_action1);
	bool clicked2 = this.isKeyJustPressed(key_action2);

	CMap@ map = getMap();

	//f32 rand = (1200+XORRandom(1200));
	if(clicked2)
	{
		CBlob@[] blobsInRadius;

		if (map.getBlobsInRadius(this.getPosition(), 100.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				{
					if(b !is null && b !is this)
					{
						this.getSprite().PlaySound("/Trapped.ogg");
						this.getSprite().PlaySound("/Respawn.ogg");
						Vec2f diff = b.getPosition() - this.getPosition();
						//diff += rand;
						diff.Normalize();
						b.AddForce(diff*1500);
					}					

				}
			}
		}
	}
	if(clicked)
	{
		CBlob@[] blobsInRadius;
		CBlob@ hover = map.getBlobAtPosition(this.getAimPos());
		if(hover !is null && hover.hasTag("enemy"))
		{
			Repath(this, mousePos);
			this.set_string("state2", "charging");
			this.set_u16("target_id", hover.getNetworkID());
		}

		else if (map.getBlobsInRadius(this.getAimPos(), 20.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				{
					if(b !is null)
					{
						Repath(this, mousePos);
						this.set_string("state2", "chasing");
						this.set_u16("target_id", b.getNetworkID());
						break;
					}					

				}
			}
		}

		else
		{
			this.set_string("state2", "none");
			this.set_u16("target_id", 0);
			Repath(this, mousePos);
		}
	}

/*
	if(XORRandom(100) == 1) 
	{
		Vec2f targetPos = this.getPosition();
		targetPos.x +=(-500+(XORRandom(1000)));
		targetPos.y +=(-500+(XORRandom(1000)));

		Repath(this, targetPos);
	}*/

	string state = this.get_string("state");
	string state2 = this.get_string("state2");
	//print(state+" "+state2);
	if(state == "moving" || state2 == "chasing")
	{

		u16 node_next = this.get_u16("node_next");
		u16 node_count = this.get_u16("node_count");



		////print("node: "+node_next+" count: "+node_count);
		Vec2f node_pos = this.get_Vec2f("node"+node_next);
		Vec2f node_pos_next = this.get_Vec2f("node"+(node_next+1));
		Vec2f pos = this.getPosition();
		Vec2f diff = node_pos - pos;

		bool ranged = false;
		CBlob@ carryBlob = this.getCarriedBlob();
		if(carryBlob !is null && carryBlob.hasTag("ranged")) ranged = true;

		diff.Normalize();
		if(state2 == "chasing")
		{

			CBlob@ target = getBlobByNetworkID(this.get_u16("target_id"));
			if(target !is null)
			{
				Vec2f targetPos = target.getPosition();
				if(canSeePosition(this.getPosition(), targetPos))
				{
					diff = targetPos -this.getPosition();
					diff.Normalize();
				}

				Vec2f diff3 = targetPos - this.getPosition();
				f32 dist = diff3.Length();

				//melee attack

				if(ranged && dist < carryBlob.get_u32("range")*10 && canSeePosition(this.getPosition(), target.getPosition()))
				{
					if(target.hasTag("enemy"))
					{
						speed = -50;
						if(timer == 0)
						{
							this.set_u8("hit_timer", this.get_u32("cooldown"));
							//carryBlob.get_string("projectile")
							if(this.getSprite() !is null) this.getSprite().PlaySound("/BowFire.ogg");
							if(getNet().isServer())
							{
								CBlob@ shot = server_CreateBlob("bolt", this.getTeamNum(), carryBlob.getPosition());
								if(shot !is null)
								{	
									Vec2f shotPos = target.getPosition();
									Vec2f targetVel = target.getVelocity() * 10;
									shotPos += targetVel;
									Vec2f offset = Vec2f(XORRandom(dist)/40, XORRandom(dist)/40);
									shotPos += offset;
									
									//print("shot "+shot.getName());
									Vec2f diff4 = shotPos - carryBlob.getPosition();
									diff4.Normalize();

									shot.AddForce(diff4*350);
									shot.set_f32("damage", carryBlob.get_f32("damage"));
									shot.server_SetTimeToDie(3);
								}

							}

						}
					}
				}

				if(dist < 25)
				{
					if(target.hasTag("enemy") && !ranged)
					{
						speed = -25;
						if(timer == 0)
						{
							this.server_Hit(target, targetPos, Vec2f(10,10), this.get_f32("damage"), Hitters::sword, true); 
							this.set_u8("hit_timer", this.get_u32("cooldown"));

						}
					}

					//take item

					else if(target.hasTag("item"))
					{
						this.server_Pickup(target);
						this.set_string("state", "none");
						this.set_string("state2", "none");
					}

					//stop
					else
					{
						this.set_string("state", "none");
						this.set_string("state2", "none");
					}
				}

			}
			//auto-attack next enemy after kill
			else
			{
				this.set_string("state", "none");
				this.set_string("state2", "none");
				CBlob@[] blobsInRadius;
				if (this.getMap().getBlobsInRadius(this.getPosition(), 50, @blobsInRadius))
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob @b = blobsInRadius[i];
						if (b.hasTag("enemy"))
						{
							Repath(this, b.getPosition());
							this.set_string("state2", "chasing");
							this.set_u16("target_id", b.getNetworkID());
							break;
						}
					}
				}
			}
		}

		f32 angle = diff.Angle();
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
		//getPathTo(this, mousePos, 0);
		this.SendCommand(this.getCommandID("path"));
	}

}

bool canSeePosition(Vec2f pos, Vec2f targetPos)
{
	Vec2f col;
	return !getMap().rayCastSolid(pos, targetPos, col);
}

void getPathTo(CBlob@ this, Vec2f targetPos, u16 tryCount)
{
	if(tryCount > 160)
	{ 
		getLongPathTo(this, targetPos, 0);
		return;
	} 

	this.set_string("state", "pathing");
	Vec2f pos = this.getPosition();

	Vec2f diff = targetPos - pos;
	////print("diff: "+diff.x+", "+diff.y);
	f32 length = diff.Length();
	f32 angle = diff.Angle();
	////print("diff angle: "+angle);

	f32 angleRand = angle-tryCount*2+XORRandom(tryCount*4);
	////print("RANDOM angle: "+angleRand);
	Vec2f try = Vec2f(length*(40+tryCount+XORRandom(80))/100.0f, 0);
	try.RotateBy(-angleRand);

	try = pos+try;	
	if(try.y < 0) try.y = 0;
	if(try.x < 0) try.x = 0;/*
	CBlob@ sponge = server_CreateBlob("sponge", this.getTeamNum(), try);
	if(sponge !is null)
	{
		sponge.server_SetTimeToDie(1);
	}*/

	if(canSeePosition(this.getPosition(), try) && canSeePosition(try, targetPos))
	{
		this.set_string("state", "moving");
		//print("moving!");
		this.set_u16("node_count", 2);
		this.set_u16("node_next", 1);
		this.set_Vec2f("node1", try);
		this.set_Vec2f("node2", targetPos);
		return;
	}
	else getPathTo(this, targetPos, tryCount+1);

	//this.setPosition(try);

}
void getLongPathTo(CBlob@ this, Vec2f targetPos, u16 tryCount)
{
	//print("getting long path....");


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
	//if(try.y < 0) try.y = 0;
	//if(try.x < 0) try.x = 0;

	if(canSeePosition(this.getPosition(), try))
	{
	/*
	CBlob@ sponge = server_CreateBlob("stalagmite", this.getTeamNum(), try);
	if(sponge !is null)
	{
		sponge.server_SetTimeToDie(1);
	}*/
		Vec2f diff2 = targetPos - try;
		f32 length2 = diff2.Length();
		f32 angle2 = diff2.Angle();
		f32 angleRand2 = -tryCount*0.5+XORRandom(tryCount);

		Vec2f try2b = Vec2f(length2/2+(XORRandom(tryCount*4)/100), 0);
		try2b.RotateBy(XORRandom(360));

		Vec2f try2 = try + try2b;
		try2.RotateBy(-angleRand2);

		try2 = targetPos + try2b;
		//try2 +=try;	
		if(try2.y < 0) try2.y = 0;
		if(try2.x < 0) try2.x = 0;

		//try2 += try2b;
		/*
		CBlob@ sponge2 = server_CreateBlob("spike", this.getTeamNum(), try2);
		if(sponge2 !is null)
		{
			sponge2.server_SetTimeToDie(1);
		}*/

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
/*
	if(canSeePosition(this.getPosition(), try) && canSeePosition(try, targetPos))
	{
		this.set_string("state", "moving");
		//print("moving!");
		this.set_u16("node_count", 2);
		this.set_u16("node_next", 1);
		this.set_Vec2f("node1", try);
		this.set_Vec2f("node2", targetPos);
		return;
	}*/

	//this.setPosition(try);

}