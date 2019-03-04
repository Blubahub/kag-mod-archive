// Mage logic

#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";

const s8 healerSpeed = 40;
const f32 healAmount = 0.125f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -1.5f);
	this.Tag("player");
	this.Tag("flesh");

	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	//Heal spell
	this.set_s8("healTime", 10);
	
	//Barrier spell
	if(getNet().isServer())
	{
		this.set_u16("barrierID", 0);
	}
	
	//
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{

	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	s8 healTime = this.get_s8("healTime");
	this.set_s8("healTime", Maths::Max(healTime - 1, -5));
	if(this.isKeyPressed(key_action1) && healTime <= 0)
	{
		bool healedAnyone = false;
		//Heal all players around cursor.
		Vec2f pos = this.getAimPos();
		CMap@ map = getMap();
		CBlob@[] blobs;
		u8 team = this.getTeamNum();
		map.getBlobsInRadius(pos, 10, blobs);
		for(int step = 0; step < blobs.length; step++)
		{
			CBlob@ b = blobs[step];
			if(b !is null && b.hasTag("player") && b.getTeamNum() == team)
			{
				if(b.getHealth() < b.getInitialHealth())
				{
					b.server_Heal(healAmount);
					//if(XORRandom(5) == 0)
					{
						ParticleAnimated(CFileMatcher("HeartAnim.png").getFirst(), pos, Vec2f((XORRandom(3) - 1) / 2, 0), 0, 0.5f, 20, -0.025f, false);
					}
					healedAnyone = true;
				}
			}
		}
		if(healedAnyone) //So that if they miss timer doesn't reset.
		{
			healTime = healerSpeed;
			this.set_s8("healTime", healerSpeed);
		}
	}
	if(getNet().isServer() && this.isKeyPressed(key_action2)) //SERVER ONLY BARRIER CONTROL.
	{
		
		CBlob@ barrier = server_getBarrier(this);
		if(barrier !is null)
		{


			Vec2f aimPos = barrier.getPosition() - this.getAimPos();
			float barrierRotation = Maths::ATan2(aimPos.y,aimPos.x);
			float angleTotal = (180/3.141) * barrierRotation;
			print(angleTotal+" | " + barrier.getAngleDegrees());

			//barrier.setAngleDegrees((angleTotal + 90));
			/*f32 aimAngle = -(((Maths::ATan2(aimPos.x, aimPos.y)) * 360) - 90);
			const f32 curAngle = barrier.getAngleDegrees();
			f32 endAngle = aimAngle - curAngle;
			endAngle /= 360.0f;
			endAngle = Maths::Sin(endAngle);
			barrier.setAngleDegrees( barrier.getAngleDegrees() + endAngle * 50	);
			//Using angular velocity would work nicer, since it would throw people properly.
			//barrier.setAngularVelocity(endAngle * 20);
			*/
		}
	}
}

CBlob@ server_getBarrier(CBlob@ this)
{
	CBlob@ barrier = getBlobByNetworkID(this.get_u16("barrierID"));
	if(barrier !is null)
	{
		return barrier;
	}
	else if(true)
	{
		if(getNet().isServer())
		{
			CBlob@ newBarrier = server_CreateBlob("barrier", this.getTeamNum(), this.getAimPos());
			if(newBarrier !is null)
			{
				this.set_u16("barrierID", newBarrier.getNetworkID());
				return newBarrier;
			}
		}
	}
	else
	{
		//Bliegh.
	}
	return null;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage;
}