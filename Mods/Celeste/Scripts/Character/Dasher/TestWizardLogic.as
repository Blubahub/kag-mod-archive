//used pirate-robs template, thank you rob <3

//TODO optimize
//clean up code, move parts like animation to diffrent file
//diffrent tick rate for particle
//use hitarray? instead of velocity

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Particles.as";

const bool is_client = getNet().isClient();
const bool is_server = getNet().isServer();
int gameTimeStart = 0;
int gameTimeEnd = 0;
Vec2f OldVelocity = Vec2f(0,0);
bool dashOn = true;
bool dashGoing = false;
bool dashParticle1 = false;
bool dashParticle2 = false;
bool dashParticle3 = false;
bool revertVelocity = false;

int particleNumber = 0;


void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);
	this.set_s8("charge_time", 0);

	this.set_bool("dash_charge", true);
	this.set_bool("dash_going", false);

	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.8f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}


void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	
	//declearing basic stuff
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();

	if(dashOn == true)
	{
		if(this.getControls().isKeyJustPressed(KEY_KEY_X))//improve controls if needed, could do wait function or something
		{
			gameTimeStart = getGameTime();//maybe optimize later
			OldVelocity = this.getVelocity();
			gameTimeEnd = getGameTime() + (26);
			Vec2f aimDir = pos - aimpos;
			aimDir.Normalize();

			HitInfo@[] hitInfos;
			Vec2f hitPos;
			
			//map.rayCastSolidNoBlobs(pos, pos + (aimDir * -96.0f), hitPos);


			f32 length = (hitPos - pos).Length();
			f32 angle =	-aimDir.Angle() + 180;
		
			/*Vec2f TilePos = map.getTileWorldPosition(hitPos);
			print(""+hitPos);
			if(TilePos == hitPos)
			{
				print("teleported inside of a tile");
			}

			this.setPosition(hitPos);*/


			//this.setVelocity(vel);
			if(this.getControls().isKeyPressed(KEY_UP) && this.getControls().isKeyPressed(KEY_RIGHT))
			{
				print("x top right");
				this.setVelocity(Vec2f(8,-8));
				dashOn = false;
				dashGoing = true;
			}
			else if(this.getControls().isKeyPressed(KEY_UP) && this.getControls().isKeyPressed(KEY_LEFT))
			{
				print("x top left");
				this.setVelocity(Vec2f(-8,-8));
				dashOn = false;
				dashGoing = true;
			}
			else if(this.getControls().isKeyPressed(KEY_DOWN) && this.getControls().isKeyPressed(KEY_LEFT))
			{
				print("x bottom left");
				this.setVelocity(Vec2f(-8,8));
				dashOn = false;
				dashGoing = true;
			}
			else if(this.getControls().isKeyPressed(KEY_DOWN) && this.getControls().isKeyPressed(KEY_RIGHT))
			{
				print("x bottom right");
				this.setVelocity(Vec2f(8,8));
				dashOn = false;
				dashGoing = true;
			}
			else if(this.getControls().isKeyPressed(KEY_UP))//x key up
			{	
				print("x up");
				this.setVelocity(Vec2f(0,-10));
				dashOn = false;
				dashGoing = true;
			}
			else if(this.getControls().isKeyPressed(KEY_LEFT))//x key left
			{
				print("x left");
				this.setVelocity(Vec2f(-8,0));
				dashOn = false;
				dashGoing = true;
			}
			else if(this.getControls().isKeyPressed(KEY_RIGHT))
			{
				print("x right");
				this.setVelocity(Vec2f(8,0));
				dashOn = false;
				dashGoing = true;
			}
			else if(this.getControls().isKeyPressed(KEY_DOWN))
			{
				print("x bottom");
				this.setVelocity(Vec2f(0,8));
				dashOn = false;
				dashGoing = true;
			}
			else
			{
				if(this.isFacingLeft())
				{
					this.setVelocity(Vec2f(-8,0));
					
				}
				else
				{
					this.setVelocity(Vec2f(8,0));
					
				}
				dashOn = false;
				dashGoing = true;
			}

		}

		/*if(this.isKeyPressed(key_action1))//TODO place 0.000 to 0
		{
		CControls@ cc = this.getControls();
		if(cc !is null)
		{
			Vec2f mousePos = (cc.getMouseWorldPos() - this.getPosition());
			print("Position Blob:"+this.getPosition());
			print("Position Mouse:"+mousePos);
			this.AddForce(mousePos);
			if(mousePos.x > 0.00000001f && mousePos.y < -0.00000001f)//top right
			{
				print("Top right");
			}
			else if(mousePos.x < -0.00000001f && mousePos.y < -0.00000001f)//top left
			{
				print("Top left");
			}
			else if(mousePos.x < -0.00000001f && mousePos.y > 0.00000001f)//bottom left
			{
				print("Bottom left");
			}
			else//bottom right
			{
				print("Bottom right");
			}

		}*/
	}

	if(dashOn == false)
	{
		if(this.isOnGround() == true)
		{
			dashOn = true;
			dashParticle1 = false;
			dashParticle2 = false;
			dashParticle3 = false;
			revertVelocity = false;
			dashGoing = false;
		}
	}

	if(dashGoing == true) // fix this, move to diffrent file, low tick rate (maybe 1?)
	{
		if(gameTimeEnd > getGameTime())
		{
			if(getGameTime() > gameTimeStart + 7 && particleNumber == 3 )	
			{
				this.setVelocity(OldVelocity);
				particleNumber = 4;
			}
			else if(getGameTime() > gameTimeStart + 5 && particleNumber == 2)
			{
				DashEffectTemp(this.getPosition());
				particleNumber = 3;
			}
			else if(getGameTime() > gameTimeStart + 3 && particleNumber == 1)
			{
				DashEffectTemp(this.getPosition());
				particleNumber = 2;
			}
			else if(getGameTime() > gameTimeStart + 1 && particleNumber == 0)
			{
				DashEffectTemp(this.getPosition());
				particleNumber = 1;
			}
			/*else if(getGameTime() > gameTimeStart + 10)
			{
				DashEffectTemp(this.getPosition());
			}*/
		}
	}
	else
	{
		if(!(particleNumber == 0))
		{
			particleNumber = 0;
		}
	}

	if(this.getControls().isKeyJustReleased(KEY_KEY_C))
	{
		print("C");
	}


	if(this.getControls().isKeyJustReleased(KEY_KEY_Z))
	{
		print("Z");
	}

	if(this.isKeyJustReleased(key_action1))// when key is closed, FIREEEE
	{
		/*CBlob@ fireball = server_CreateBlobNoInit("fireball");
		if (fireball !is null)
		{
			Vec2f fireballVel = (this.getAimPos() - pos);
			fireballVel.Normalize();//not sure what this does.. but it 'normalizes' the aiming so i'l keep it
			fireballVel *= charge/3.0f;//will change in the future, will change the charge distance

			fireball.SetDamageOwnerPlayer(this.getPlayer());
			fireball.Init();

			fireball.IgnoreCollisionWhileOverlapped(this);
			fireball.server_setTeamNum(this.getTeamNum());
			fireball.setPosition(pos);
			fireball.setVelocity(fireballVel);
		}
		charge = 8;*/
	}


	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	if(ismyplayer)
	{

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null)
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
}
