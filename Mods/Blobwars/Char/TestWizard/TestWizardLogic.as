//used pirate-robs template, thank you rob

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "ChannelingParticles.as";

int charge = 5;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);
	this.set_s8("charge_time", 0);

	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

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
	//declearing basic stuff
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	//if left mouse key is pressed, + 1 to charge
	if(this.isKeyPressed(key_action1))
	{
		charge++;
		while(charge > 24) //while its above 24, set to 24 (altough ingame its displays 25) ¯\_(ツ)_/¯
		{
			charge = 24;
		}
	}

	if(this.isKeyJustReleased(key_action1))// when key is closed, FIREEEE
	{
		CBlob@ fireball = server_CreateBlobNoInit("fireball");
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
		charge = 5;
	}

	if(this.isKeyJustReleased(key_action2))// when key is closed, FIREEEE
	{
		int x;
		int y;
		int bx;
		int by;


		for(int x = y; x <= y - 1; x++);
		{
			CoolEffect(pos + (Vec2f(a,a)), vel + Vec2f(a-a,a),SColor(255, 255, 100+ a, 150 + a));
		}
		for(int y = x; y <= x; y++)
		{
			CoolEffect(pos + (Vec2f(a,a)), vel + Vec2f(a-a,a),SColor(255, 255, 100+ a, 150 + a));
		}

		/*CBlob@ metor = server_CreateBlobNoInit("Metor");
		if (metor !is null)
		{
			Vec2f metorVel = (this.getAimPos() - pos);
			metorVel.Normalize();//not sure what this does.. but it 'normalizes' the aiming so i'l keep it
			metorVel *= charge/3.0f;//will change in the future, will change the charge distance

			metor.SetDamageOwnerPlayer(this.getPlayer());
			metor.Init();

			metor.IgnoreCollisionWhileOverlapped(this);
			metor.server_setTeamNum(this.getTeamNum());
			metor.setPosition(Vec2f(pos.x, 0));
			metor.setVelocity(Vec2f(0,0));
		}
		charge = 5;*/
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
