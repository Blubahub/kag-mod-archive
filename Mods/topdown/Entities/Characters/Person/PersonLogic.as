// Person logic

#include "PersonCommon.as"
#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";
#include "ExtraSparks.as";
#include "Behaviour.as";
#include "Behaviour.as";
//#include "PersonAnim.as";

void onInit(CBlob@ this)
{	
/*
	{
		Vec2f[] shape = { Vec2f(2.0f,  2.0f),
		                  Vec2f(20.0f,  2.0f),
		                  Vec2f(20.0f,  20.0f),
		                  Vec2f(2.0f,  20.0f)
		                };
		this.getShape().AddShape(shape);
	}*//*
	CBlob@ gun = server_CreateBlob("revolver", 0, this.getPosition());
	if(gun !is null)
	{
		this.server_Pickup(gun);
	}*/
	if (this.getShape() !is null) 
	{
	
		this.getShape().SetGravityScale(0.0f);
		this.getShape().SetRotationsAllowed(true);
	}
	this.server_setTeamNum(this.getTeamNum()+1);
	this.server_setTeamNum(this.getTeamNum()-1);
	PersonInfo person;
	this.set("personInfo", @person);
	this.set_u32("overheat", 0);
	this.set_u32("lasthit", 0);
	this.set_u32("lastfire", 0);
	this.set_u32("max overheat", 100);
	this.set_bool("overheated", false);
	this.set_s8("charge_time", 0);
	//this.set_u8("charge_state", PersonParams::not_aiming);
	this.set_bool("has_arrow", false);
	this.set_f32("gib health", -3.0f);
	this.set_f32("accuracy", 3.0f);
	this.Tag("player");
	this.Tag("flesh");
	this.set_string("hit state", "none");

	this.set_string("skinpath", "BodyParts.png");
	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	//this.getSprite().SetEmitSound("Entities/Characters/Person/BowPull.ogg");
	CBlob@[] spawns;
	if(getBlobsByTag("spawn point", @spawns))
	{
		for(uint i = 0; i < spawns.length; i++)
		{
			CBlob@ spawn = spawns[i];
			if(spawn !is null)
			{
				Vec2f pos = spawn.getPosition();
				this.set_Vec2f("targetpos", pos);
				if(this.getSprite() !is null) this.getSprite().SetFacingLeft(false);//this.getPosition().x > pos.x);
			}
		}
	}
	Vec2f targetpos = this.get_Vec2f("targetpos");

	CBlob@[] cores;
	if(!getBlobsByName("core", @cores))
	{
		
		CBlob@ core = server_CreateBlob("core", -1, Vec2f(0, 0));
		if(core !is null)
		{
			core.set_Vec2f("targetpos", targetpos);
			core.server_SetHealth(9999);
		}
	
	}

	this.addCommandID("swingsound");
	this.addCommandID("hitsound");
	this.addCommandID("shoot arrow");
	this.addCommandID("pickup arrow");
	this.addCommandID("force jump");
	this.addCommandID("slash");
	//this.addCommandID("get bomb");

	this.push("names to activate", "keg");
	this.push("names to activate", "fl");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;


	for (uint i = 0; i < arrowTypeNames.length; i++)
	{
		this.addCommandID("pick " + arrowTypeNames[i]);
	}

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	/*if (point !is null)
	{
		point.offset.Set(0, 16);
	}*/
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}
}


void ManageBow(CBlob@ this, PersonInfo@ person, RunnerMoveVars@ moveVars)
{

	CSprite@ sprite = this.getSprite();
	bool ismyplayer = this.isMyPlayer();
	const bool pressed = this.isKeyPressed(key_action1);
	bool justpressed = this.isKeyJustPressed(key_action3);
	const bool pressed2 = this.isKeyPressed(key_action2);
	Vec2f pos = this.getPosition();
	u32 overheat = this.get_u32("overheat");
	u32 lastfire = this.get_u32("lastfire");
	bool canshoot = (!this.get_bool("overheated"));

	if (justpressed)
	{
		if(overheat < 10 && canshoot)
		{
			{
				Vec2f pos = this.getPosition();
				Vec2f aimpos = this.getAimPos();
				Vec2f dir = aimpos-pos;
				dir.Normalize();
				pos = pos+(dir*100);
				//print("shot position: "+ pos.x + ", " + pos.y);		
				//this.getSprite().PlaySound("BlasterFire.ogg");
				this.AddForce(dir*420);

				//CBitStream params;
				Vec2f vel = Vec2f(100, 0);
				//params.write_Vec2f(vel);
				//this.SendCommand(this.getCommandID("force jump"), params);
				this.set_u32("lastfire", (lastfire+9));
				this.set_u32("overheat", 450);
			}
		}
	}

	if (ismyplayer)
	{
		//fire gun


		if (!getHUD().hasButtons())
		{
			int frame = overheat/22;
			if(!canshoot)
			{
				//frame = 20;
			}

			getHUD().SetCursorFrame(frame);
		}

	}
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if( blob is null  || blob.isAttached() || !blob.hasTag("item")) return;
	if ( this.getBrain() !is null && this.getBrain().isActive()) this.server_Pickup(blob);

/*
	if(this !is null && blob !is null && getNet().isServer())
	{
		this.SendCommand(this.getCommandID("slash"));

	}
	if(!getNet().isServer())
	{
		print("no server collision");
	}*/
}

void setLegValues(CBlob@ this, CSpriteLayer@ rightleg, CSpriteLayer@ leftleg, CSpriteLayer@ rightfoot, CSpriteLayer@ leftfoot, CSpriteLayer@ rightarm, CSpriteLayer@ leftarm, CSpriteLayer@ righthand, CSpriteLayer@ lefthand )
{

	//CSpriteLayer@ rightarm = this.getSprite().getSpriteLayer("rightarm");
	int facing = this.isFacingLeft() ? 1 : -1;
	bool face = this.isFacingLeft();
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right) || this.isKeyPressed(key_up) || this.isKeyPressed(key_down));
	bool standing = !walking;
	/*bool backwards = false;
	if( this.isKeyPressed(key_left) && !face || this.isKeyPressed(key_right) && face)
	{
		backwards = true;
	}
	f32 backward = backwards ? -1 : 1;*/
	if(rightleg !is null && leftleg !is null && rightfoot !is null && leftfoot !is null && rightarm !is null && leftarm !is null && righthand !is null && lefthand !is null)
	{
		leftleg.ResetTransform();
		rightleg.ResetTransform();

		leftfoot.ResetTransform();
		rightfoot.ResetTransform();

		leftarm.ResetTransform();
		rightarm.ResetTransform();
		
		lefthand.ResetTransform();
		righthand.ResetTransform();

		f32 lla = this.get_f32("lla");
		f32 llt = this.get_f32("llt");

		f32 lfa = this.get_f32("lfa");
		f32 lft = this.get_f32("lft");

		f32 rla = this.get_f32("rla");
		f32 rlt = this.get_f32("rlt");

		f32 rfa = this.get_f32("rfa");
		f32 rft = this.get_f32("rft");

		f32 laa = this.get_f32("laa");
		f32 lat = this.get_f32("lat");

		f32 raa = this.get_f32("raa");
		f32 rat = this.get_f32("rat");

		f32 lha = this.get_f32("lha");
		f32 lht = this.get_f32("lht");

		f32 rha = this.get_f32("rha");
		f32 rht = this.get_f32("rht");


		Vec2f pos = this.getPosition();
		Vec2f rlo = Vec2f(0, 0);//*facin
		Vec2f llo = Vec2f(0, 0);//*facin

		Vec2f rfo = Vec2f(4, 0);//*facin
		Vec2f lfo = Vec2f(-4, 0);//*facin

		//llo.x -= (facing*8);



		Vec2f rlj = pos + rlo;//*facin
		Vec2f llj = pos + llo;//*facin
 		Vec2f around = Vec2f(0.0f, 0.0f);

		if(standing && !this.hasTag("dead"))
		{	
			llt = 10;
			rlt = -10;

			lft = -0;
			rft = -0;

			lat = 0;
			rat = 0;

			lht = 0;
			rht = 0;

			rightfoot.SetVisible(false);
			leftfoot.SetVisible(false);

			this.set_f32("walkcycle", 0);
		}
		f32 rhs;
		f32 ras;
		f32 lhs;
		f32 las;
		f32 lfs;
		f32 rfs;

		//walk animation

		if(walking && !this.hasTag("dead"))
		{
			f32 cycle = this.get_f32("walkcycle");
			if(cycle < 40)
			{
				cycle += 1.7f;
			}					

			if(cycle >= 40)
			{
				cycle = 0;
			}


			this.set_f32("walkcycle", cycle);


			if(cycle < 10)
			{
				lht = 40;
				rht = -40;

				rhs = cycle;
				lhs = -cycle;

				lfa = 0;
				rfa = 180;

			}	

			else if(cycle < 20)
			{

				rhs = 10-(cycle-10);
				lhs = -10+(cycle-10);

				lfa = 0;
				rfa = 180;

			}	

			else if(cycle >= 20 && cycle < 30)
			{	

				llt = -5;
				rlt = 5;

				lfa = 180;
				rfa = 0;
			

				rhs = -(cycle-20);
				lhs = cycle-20;


			}	

			else if(cycle >= 30 && cycle < 40)
			{	
				llt = -5;
				rlt = 5;

				lfa = -5;
				rfa = 5;
			
				lfa = 180;
				rfa = 0;

				rhs = -10+(cycle-30);
				lhs = 10-(cycle-30);



			}
			rfs = lhs;
			lfs = rhs;
			rightfoot.SetVisible(true);
			leftfoot.SetVisible(true);
		}
		else
		{
			rhs = 2;
			lhs = 2;
			lht = 10;
			rht = -10;
			rightfoot.SetVisible(false);
			leftfoot.SetVisible(false);

		}

		rhs /= 4;
		rfs /= 1.4;
		lhs /= 4;
		lfs /= 1.4;
		// l = left, r = right
		// a = arm, h = hand, l = leg, f = foot
		//	t = target angle, a = current angle, o = offset, d = end offset, j = joint position

		CBlob @carryBlob = this.getCarriedBlob();


		f32 hittimer = this.get_f32("hittimer");
		f32 charge = this.get_f32("charge");

		if(carryBlob is null && hittimer > 0)
		{
			bool hand = this.get_bool("hand");
			rht = -20+hittimer/2;
			rhs = hittimer/2;
			/*if(hand)
			{
				rht = -20+hittimer/2;
				rhs = hittimer/2;
			}/*
			else
			{
				lht = 20-hittimer/2;
				lhs = hittimer/2;
			}*/
		}		

		//slashcode

		if(carryBlob !is null && carryBlob.getName() == "ak" && hittimer > 0)
		{
			bool hand = this.get_bool("hand");
			if(hand)
			{
				rht = 0;//-hittimer/2;
				//rhs = hittimer/200;
				//lht = -20+hittimer/2;
				//lhs = hittimer/200;
			}
			else
			{
				rht= 0;
			}
			rht-=100;
		}
		if(carryBlob !is null && charge > 0)
		{
			bool hand = this.get_bool("hand");
			if(hand)
			{
				lht = -charge/1.7f-hittimer;
				lhs = charge/60;
			//	print("left");
			}
			else
			{
				rht = charge/1.7f;
				rhs = charge/60;
				//print("right");
			}
			rht-=100;
		}		

		Vec2f lfd = Vec2f(0, 5);
		//lfd.RotateBy(lla, around);

		Vec2f rfd = Vec2f(0, 5);
		//rfd.RotateBy(rla, around);


		//limb offsets

		Vec2f rad = Vec2f(0, -5);
		rad.RotateBy(-raa, around);

		Vec2f rhd = Vec2f(0, -8);
		rhd.RotateBy(-rha, around);

		Vec2f lad = Vec2f(0, -5);
		lad.RotateBy(-laa, around);

		Vec2f lhd = Vec2f(0, -8);
		lhd.RotateBy(-lha, around);

		this.SetFacingLeft(true);



		//rfo = Vec2f(0, -2) + rfd;
		//lfo = Vec2f(-3, -2) + lfd;


		Vec2f lao = Vec2f(-7, 0);
		//Vec2f lho = lad + Vec2f(7, -0);
		Vec2f lho = Vec2f(-7, 0);

		Vec2f rao = Vec2f(7, 0); 
		//Vec2f rho = rad + Vec2f(-7, -0);
		Vec2f rho = Vec2f(7, 0);

		rightarm.SetRelativeZ(-1.1f);
		righthand.SetRelativeZ(-1.2f);
		leftarm.SetRelativeZ(-1.1f);
		lefthand.SetRelativeZ(-1.2f);
/*
		if(laa != lat)
		{
			laa +=1+(lat - laa)/3;
		}

		if(raa != rat)
		{
			raa +=1+(rat - raa)/3;
		}

		if(lha != lht)
		{
			lha +=1+(lht - lha)/3;
		}

		if(rha != rht)
		{
			rha +=1+(rht - rha)/3;
		}
*/

		if(laa != lat)
		{
			laa +=(10+(lat - laa)/5);
		}

		if(raa != rat)
		{
			raa +=(10+(rat - raa)/5);
		}

		if(lha != lht)
		{
			lha +=(10+(lht - lha)/5);
		}

		if(rha != rht)
		{
			rha +=(10+(rht - rha)/5);
		}
		rho.y -= rhs;
		rao.y -= ras;
		lho.y -= lhs;
		lao.y -= las;
		lfo.y -= lfs;
		rfo.y -= rfs;

		Vec2f rhj = Vec2f(-rho.x, rho.y) + rhd;// + rhd;

		//Vec2f lhj = Vec2f(7, -5) + lhd;
		Vec2f lhj = Vec2f(-lho.x, lho.y) + lhd;// + rhd;
		lhs = 0;
		rhs = 0;
		lhj.y += lhs;
		rhj.y += rhs;

	//	this.set_Vec2f("carryoffset2", lhj);
		this.set_Vec2f("carryoffset", rhj);
		//lefthand.SetVisible(false);

		this.set_f32("llt", llt);
		this.set_f32("lft", lft);

		this.set_f32("rlt", rlt);
		this.set_f32("rft", rft);

		this.set_f32("lat", lat);
		this.set_f32("rat", rat);

		this.set_f32("lht", lht);
		this.set_f32("rht", rht);


		this.set_f32("lla", lla);
		this.set_f32("lfa", lfa);

		this.set_f32("rla", rla);
		this.set_f32("rfa", rfa);

		this.set_f32("laa", laa);
		this.set_f32("raa", raa);

		this.set_f32("lha", lha);
		this.set_f32("rha", rha);

		//zeta
		//righthand.SetRelativeZ(2.3);
		//lefthand.SetRelativeZ(2.3);

		f32 rha2 = rha - 270;
		f32 lha2 = lha - 270;

		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		rightarm.SetOffset(rao);
		leftarm.SetOffset(lao);
		righthand.SetOffset(rho);
		lefthand.SetOffset(lho);
		leftfoot.SetOffset(lfo);
		rightfoot.SetOffset(rfo);
		leftleg.SetOffset(llo);
		rightleg.SetOffset(rlo);


		leftfoot.RotateBy(lfa, around);
		rightfoot.RotateBy(rfa, around);

		leftarm.RotateBy(laa, around);
		lefthand.RotateBy(lha2, around);

		rightarm.RotateBy(raa, around);
		righthand.RotateBy(rha2, around);
		leftarm.SetVisible(false);
		rightarm.SetVisible(false);

//
		//print("lht: "+lht+" lha: "+lha+" rht: "+rht+" rha: "+rha);
		//rightleg.ScaleBy(Vec2f(16.0f, 48.0f));

		//leftarm.ScaleBy(Vec2f(16.0f, 48.0f));


		//saber.TranslateBy(Vec2f(1.0f, 2.0f));
	}





}

void UpdateBody(CSprite@ this, CBlob@ blob)
{

	CSpriteLayer@ leftarm = this.getSpriteLayer("leftarm");

	CSpriteLayer@ rightarm = this.getSpriteLayer("rightarm");

	CSpriteLayer@ lefthand = this.getSpriteLayer("lefthand");

	CSpriteLayer@ righthand = this.getSpriteLayer("righthand");

	CSpriteLayer@ rightleg = this.getSpriteLayer("rightleg");
	CSpriteLayer@ leftleg = this.getSpriteLayer("leftleg");

	CSpriteLayer@ rightfoot = this.getSpriteLayer("rightfoot");
	CSpriteLayer@ leftfoot = this.getSpriteLayer("leftfoot");
	setLegValues(blob, rightleg, leftleg, rightfoot, leftfoot, rightarm, leftarm, righthand, lefthand);

	// fire arrow particles

}

void onTick(CBlob@ this)
{	
	// store some vars for ease and speed
	CSprite@ sprite = this.getSprite();

	if(sprite !is null) UpdateBody(sprite, this);

	f32 hittimer = this.get_f32("hittimer");
	f32 hittimer2 = this.get_f32("hittimer2");
	f32 charge = this.get_f32("charge");

	Vec2f aimpos = this.getAimPos();
	Vec2f pos = this.getPosition();
	Vec2f diff = aimpos - this.getPosition();
	this.setAngleDegrees(-diff.Angle()+90);
	bool ismyplayer2 = this.isMyPlayer();

	CPlayer@ player = this.getPlayer();
	if (this.getTickSinceCreated() > 30 && player is null)
	{
 		this.getBrain().server_SetActive(true);
 		this.Tag("NPC");
	}

	PersonInfo@ person;
	if (!this.get("personInfo", @person))
	{
		return;
	}

	if (this.isInInventory()) return;
/*
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	ManageBow(this, person, moveVars);*/

	bool pressed1 = this.isKeyPressed(key_action1);
	bool pressed1b = this.isKeyJustPressed(key_action1);

	CBlob@ carryBlob = this.getCarriedBlob();


	if(carryBlob !is null)
	{
		f32 rht;
		f32 rhs;
		f32 lht;
		f32 lhs;
/*
		if(carryBlob is null && hittimer > 0)
		{
			bool hand = this.get_bool("hand");
			if(hand)
			{
				rht = 20-hittimer/2;
				rhs = hittimer/2;
			}
			else
			{
				lht = 20-hittimer/2;
				lhs = hittimer/2;
			}
		}		

		if(carryBlob !is null && charge > 0)
		{
			bool hand = this.get_bool("hand");
			if(hand)
			{
				lht = -charge/2;
				lhs = charge/60;
				//print("left");
			}
			else
			{
				rht = charge/2;
				rhs = -charge/60;
				//print("right");
			}
		}		
*//*
		this.set_f32("rht", rht);
		this.set_f32("rhs", rhs);
		this.set_f32("lht", lht);
		this.set_f32("lhs", lhs);*/

		if(this.get_string("weapon type") == "slash")
		{
			string hitstate = this.get_string("hit state");
			f32 carryangle;
			// charging

			if(hitstate == "slashing" &&  charge < 0)
			{
				hitstate = "none";
				//print("none");
				charge = 0;
			}
			
			if(hitstate == "charging" && pressed1 && charge < 180)
			{
			//	print("charging");
				charge+=5;
			}		

			// start charge

			if(hitstate == "none" && pressed1)
			{
				//print("charge start");
				hitstate = "charging";
			}

			// release
			 if(hitstate == "charging" && !pressed1)
			{
				//print("release");
				/*this.set_f32("rha", 0);
				this.set_f32("rht", 0);
				this.set_f32("lha", 0);
				this.set_f32("lht", 0);*/
				hitstate = "slashing";
				hittimer = charge;
				if(charge < 90) carryBlob.set_f32("hitpower", 1);
				else if(charge < 120) carryBlob.set_f32("hitpower", 2);
				else carryBlob.set_f32("hitpower", 3);
			}		

			//slashing

			if(hitstate == "slashing")
			{
				//print("slashing");
				charge-=16;
				hittimer-=2.8f;
				//print("carryangle: "+carryangle+" charge: "+charge);
			}
			
			this.set_bool("hand", false);

			carryangle = charge;//-hittimer; 
			//print("charge" + charge);
			this.set_f32("charge", charge);
			this.set_f32("carryangle", carryangle*1.2-70);
			this.set_string("hit state", hitstate);
			this.set_bool("outer slash", true);
			carryBlob.set_string("hit state", hitstate);
			//rint("hit state: "+hitstate);
		}

	}
	if(hittimer > 0)
	{
		hittimer--;
		this.set_f32("hittimer", hittimer);
	}

	if(hittimer2 > 0)
	{
		hittimer--;
		this.set_f32("hittimer2", hittimer);
	}


	if(carryBlob is null && this.isKeyJustPressed(key_action1) && hittimer < 5)
	{
		Attack(this, true);
	}

	if(carryBlob is null && this.isKeyJustPressed(key_action2) && hittimer < 5)
	{
		Attack(this, false);
	}
}

void Attack(CBlob@ this, bool hand)
{
	u32 lasthit = this.get_u32("last hit");
	const u32 gametime = getGameTime();
	int diff = gametime - (lasthit + 10);
	f32 hittimer = this.get_f32("hittimer");


	if(diff > 0)
	{
		hittimer = 20;
		this.set_u32("last hit", gametime);
		this.set_f32("hittimer", hittimer);
	}
	this.set_bool("hand", hand);
	if(hittimer == 20)
	{

		Vec2f pos = this.get_Vec2f(hand ? "carryoffset" : "carryoffset2");
		pos.RotateBy(this.getAngleDegrees());
		pos += this.getPosition();
		CBlob@[] hitblobs;
		if(getMap().getBlobsInRadius(pos, 12.0f, @hitblobs))
		{
			for(uint i = 0; i < hitblobs.length; i++)
			{
				CBlob@ hitblob = hitblobs[i];
				if(hitblob !is null && hitblob !is this)
				{
					//this.server_Die();
					Vec2f diff = (hitblob.getPosition() - this.getPosition())*10;
					//this.AddForce(diff);
					diff.Normalize();
					diff *= 100;
					this.server_Hit(hitblob, Vec2f_zero, diff, 1.0f, Hitters::stomp, false);
					//hitblob.server_Die();
					//this.setPosition(hitblob.getPosition());
					if(i > 3) break;
				}
			}
		}
	}
	/*if(hittimer > 0)
	{
		Attack(this, hand);
	}*/

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{		
	if (cmd == this.getCommandID("force jump"))
	{
		Vec2f pos = this.getPosition();
		Vec2f aimpos = this.getAimPos();
		Vec2f dir = aimpos-pos;
		dir.Normalize();
		pos = pos+(dir*100);	
		//this.getSprite().PlaySound("BlasterFire.ogg");
		this.AddForce(dir*1500);

	}	
	if (cmd == this.getCommandID("swingsound"))
	{/*
		CSprite@ sprite = this.getSprite();
		if (sprite is null) return;
		string hitsound = ("Saber"+XORRandom(3)+".ogg");
		sprite.PlaySound(hitsound);*/
	}	
	if (cmd == this.getCommandID("hitsound"))
	{/*
		CSprite@ sprite = this.getSprite();
		if (sprite is null) return;
		string hitsound2 = ("SaberHit"+XORRandom(2)+".ogg");
		sprite.PlaySound(hitsound2);*/
	}		

	if (cmd == this.getCommandID("slash"))
	{	

	}	
}




// arrow pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (arrowTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(arrowTypeNames.length, 2), "Current arrow");

	PersonInfo@ person;
	if (!this.get("personInfo", @person))
	{
		return;
	}
	const u8 arrowSel = person.arrow_type;

}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached.hasTag("weapon"))
	{
		this.set_string("weapon type", attached.get_string("weapon type"));
	}

}
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	if (detached.hasTag("weapon"))
	{
		this.set_string("weapon type", detached.get_string("none"));
	}

}
// auto-switch to appropriate arrow when picked up
void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	string itemname = blob.getName();
	if (this.isMyPlayer())
	{
		for (uint j = 0; j < arrowTypeNames.length; j++)
		{
			if (itemname == arrowTypeNames[j])
			{
				SetHelp(this, "help self action", "person", "$arrow$Fire arrow   $KEY_HOLD$$LMB$", "", 3);
				if (j > 0 && this.getInventory().getItemsCount() > 1)
				{
					SetHelp(this, "help inventory", "person", "$Help_Arrow1$$Swap$$Help_Arrow2$         $KEY_TAP$$KEY_F$", "", 2);
				}
				break;
			}
		}
	}

	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0)
	{
		PersonInfo@ person;
		if (!this.get("personInfo", @person))
		{
			return;
		}

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (itemname == arrowTypeNames[i])
			{
				person.arrow_type = i;
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
}

