// Priest logic

#include "Hitters.as";
#include "Knocked.as";
#include "PriestCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	this.Tag("flesh");
	this.Tag("holy");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 7, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	// activate/throw
	if(ismyplayer)
	{

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
	
	if(this.isKeyPressed(key_action1))
	{
		f32 maxDistance = 400;
		
		Vec2f hitPos;
		f32 length;
		bool flip = this.isFacingLeft();
		f32 angle =	UpdateAngle(this);
		Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
		Vec2f startPos = this.getPosition();
		Vec2f endPos = startPos + dir * maxDistance;

		getMap().rayCastSolid(startPos, endPos, hitPos);

		length = (hitPos - startPos).Length()+4;

		CSpriteLayer@ gammalaser = this.getSprite().getSpriteLayer("smite");

		if (getNet().isClient())
		{					
			if (gammalaser !is null)
			{
				gammalaser.ResetTransform();
				gammalaser.ScaleBy(Vec2f(length / 32.0f, 1.0f));
				gammalaser.TranslateBy(Vec2f((length / 2), 1.0f * (flip ? 1 : -1)));
				gammalaser.RotateBy((flip ? 180 : 0)+angle, Vec2f(0,0));
				gammalaser.SetVisible(true);
			}
		}
		
		if (getNet().isServer())
		{		
			HitInfo@[] blobs;
			getMap().getHitInfosFromRay(startPos, angle + (flip ? 180 : 0), maxDistance, this, blobs);
		
			f32 counter = 1;
		
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i].blob;
				if (b !is null && (b.hasTag("undead") || b.hasTag("evil"))){
				
					if(getGameTime() % 5 == 0){
						this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 0.25f, Hitters::suddengib, true);
						ParticleAnimated("HolyParticle.png", b.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
					}
				}
			}
		}
	}
	
	if(this.isKeyPressed(key_action2) && !this.isKeyPressed(key_action1))
	{
		RunnerMoveVars@ moveVars;
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.8f;
			moveVars.jumpFactor *= 0.4f;
		}
		if(getGameTime() % 3 == 0 && getKnocked(this) <= 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 48.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.hasTag("flesh"))
					{
						if(!b.hasTag("undead")){
							if(b.getHealth() < b.getInitialHealth())b.server_Heal(0.25f);
							ParticleAnimated("HealParticle.png", b.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
						} else {
							b.server_Hit(b, b.getPosition(), Vec2f(0.0f,0.0f), 0.5f, Hitters::suddengib, false);
							ParticleAnimated("HolyParticle.png", b.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
						}
						
						
					}
					if(b.getName() == "mansshadow"){
						Vec2f dir = b.getPosition()-this.getPosition();
						dir.Normalize();
						b.AddForce(dir*200);
						ParticleAnimated("HolyParticle.png", b.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
					}
					if(b.getName() == "plague"){
						if(getNet().isServer())b.server_Die();
					}
					if(b.getName() == "deathorb"){
						Vec2f dir = b.getPosition()-this.getPosition();
						dir.Normalize();
						b.AddForce(dir*2);
						ParticleAnimated("HolyParticle.png", b.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 2, 0.0f, true);
					}
				}
			}
		}
	} 
}

int UpdateAngle(CBlob@ this)
{

	Vec2f aimpos=this.getAimPos();
	Vec2f pos=this.getPosition();
	
	Vec2f aim_vec =(pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
	if(!this.isFacingLeft()) mouseAngle += 180;

	return -mouseAngle;
}