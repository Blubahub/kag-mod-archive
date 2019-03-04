#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "BombCommon.as"; // TFlippy
#include "Help.as";
#include "Requirements.as";
#include "FireParticle.as";


void onInit(CBlob@ this)
{
	this.Tag("player");
	this.Tag("evil");
	this.Tag("pure_corruption");
	
	this.set_s16("timer",0);
	this.set_s16("smitetimer",0);
	
	this.getShape().getConsts().mapCollisions = false;
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	
	this.set_Vec2f("inventory offset", Vec2f(0.0f, -152.0f));
	
	this.Tag("spirit_view");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		this.SetLight(true);
		this.SetLightColor(SColor(255, 200, 0, 255));
		this.SetLightRadius(80.0f);
	
		player.SetScoreboardVars("DarkBeingIcon.png", 0, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{		
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(this.get_s16("timer") < 5*30)this.set_s16("timer",this.get_s16("timer")+1);
	else {
		this.set_s16("corruption",this.get_s16("corruption")-1);
		this.set_s16("timer",0);
	}
	
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	if(this.get_s16("smitetimer") > 3){
		if(this.isKeyPressed(key_action1))
		{
			this.getSprite().PlaySound("/OrbExplosion", 2.50f, 0.90f);	
			if(getNet().isServer()){
				CBlob @blob = server_CreateBlob("darkmissile", -1, this.getPosition()+Vec2f(XORRandom(32)-16,XORRandom(32)-16));
				if (blob !is null)
				{
					Vec2f smiteVel = this.getAimPos()-this.getPosition();
					smiteVel.Normalize();
					blob.setVelocity(smiteVel*8);
					this.set_s16("corruption",this.get_s16("corruption")-5);
				}
			}
			this.set_s16("smitetimer",0);
		}
	} else this.set_s16("smitetimer",this.get_s16("smitetimer")+1);
	
	
	if(getNet().isServer())this.Sync("corruption", true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("projectile");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.set_s16("corruption",this.get_s16("corruption")-damage*4);
	return 0;
}

void onDie(CBlob@ this){
	SetupBomb(this, 0, 32.0f, 2.5f, 16.0f, 0.5f, true);
	this.getSprite().PlaySound("/KegExplosion", 3.50f, 0.60f);
	ParticleZombieLightning(this.getPosition());
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && blob.hasTag("flesh") && blob.hasTag("dead"))
	{
		if(getNet().isServer()){
			CBlob @skelebro = server_CreateBlob("evilskeleton", this.getTeamNum(), blob.getPosition());
			if(this.getPlayer() !is null)skelebro.set_string("boss",this.getPlayer().getUsername());
			this.set_s16("corruption",this.get_s16("corruption")+20);
			blob.server_Die();
		}
	}
}