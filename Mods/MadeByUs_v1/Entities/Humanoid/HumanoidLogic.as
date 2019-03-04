
#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "GrappleCommon.as";
#include "HumanoidCommon.as";
#include "BowCommon.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.set_s8("torso_type",0);
	this.set_s8("main_arm_type",0);
	this.set_s8("sub_arm_type",0);
	this.set_s8("front_leg_type",0);
	this.set_s8("back_leg_type",0);
	
	this.set_f32("torso_hp",25.0);
	this.set_f32("main_arm_hp",15.0);
	this.set_f32("sub_arm_hp",15.0);
	this.set_f32("front_leg_hp",20.0);
	this.set_f32("back_leg_hp",20.0);
	
	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_u8("main_type",0);
	this.set_u8("secondary_type",0);
	
	//Types:
	//0 - none/fist
	//1 - pick
	//2 -
	//3 - sword
	//4 - bow
	//5 - shield
	//6 - grapple
	
	this.set_string("main_name","");
	this.set_string("secondary_name","");
	
	
	///////Equipment
	
	//Fist
	this.set_s16("main_fist_drawback",0);
	this.set_s16("sub_fist_drawback",0);
	
	//Grapple
	this.set_Vec2f("grapple_offset",Vec2f(0,0));
	this.addCommandID(grapple_sync_cmd);
	GrappleInfo grapple;
	this.set("GrappleInfo", @grapple);
	
	//Bow
	this.set_u16("bowcharge",0);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");
	
	
	
	
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
	if(this.isInInventory())return;
	const bool ismyplayer = this.isMyPlayer();
	if(ismyplayer && getHUD().hasMenus())return;

	if(ismyplayer)
	if(this.isKeyJustPressed(key_action3))
	{
		CBlob@ carried = this.getCarriedBlob();
		if(carried is null)client_SendThrowOrActivateCommand(this);
	}
	
	
	GrappleInfo@ grapple;
	if (!this.get("GrappleInfo", @grapple))
	{
		return;
	}
	
	
	
	if (getKnocked(this) > 0)
	{
		grapple.grappling = false;
		return;
	}
	
	bool Action1 = this.isKeyPressed(key_action1) && bodyPartFunctioning(this,"main_arm");
	bool Action2Seperate = this.isKeyPressed(key_action2) && bodyPartFunctioning(this,"sub_arm");
	bool Action2 = Action2Seperate && !Action1;
	
	if(this.getCarriedBlob() is null){
		if(this.get_u8("main_type") == 0)ManageFist(this,Action1,"main");
		if(this.get_u8("secondary_type") == 0)ManageFist(this,Action2Seperate,"sub");
	}
	
	if(this.get_u8("main_type") == 6)ManageGrapple(this, grapple,Action1,this.isKeyJustPressed(key_action1));
	if(this.get_u8("secondary_type") == 6)ManageGrapple(this, grapple,Action2Seperate,this.isKeyJustPressed(key_action2));
	
	
	if((this.get_u8("main_type") == 4 && Action1) || (this.get_u8("secondary_type") == 4 && Action2))ManageBow(this,true);
	else ManageBow(this,false);
	
	
	f32 angle = getAimAngle(this);
	
	if((this.get_u8("main_type") == 5 && Action1) || (this.get_u8("secondary_type") == 5 && Action2)){
		if(angle > 45 && angle < 135){
			if(this.getVelocity().y > 0)this.getShape().SetGravityScale(0.2);
		} else {
			this.getShape().SetGravityScale(1);
		}
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			if(angle > 270-45 && angle < 270+45)moveVars.jumpFactor *= 0.0f;
			else moveVars.jumpFactor *= 0.5f;
			//moveVars.walkFactor *= 0.8f;
		}
		this.Tag("shielding");
	} else {
		this.Untag("shielding");
	}
	
	
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	if(this.hasTag("shielding")){
		Vec2f pos = this.getPosition();
		f32 aimangle = getAimAngle(this);

		Vec2f vec = worldPoint - pos;
		f32 angle = vec.Angle();
		
		if((aimangle+45 > angle && aimangle-45 < angle) || aimangle-45+360 < angle || aimangle+45-360 < angle)return 0;
	}

	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if(solid && point.y > this.getPosition().y)
	if(this.hasTag("shielding")){
		if(this.isKeyPressed(key_up))
		if(getAimAngle(this) > 270-45 && getAimAngle(this) < 270+45){
			if(this.isKeyPressed(key_right) && this.isKeyPressed(key_left))this.setVelocity(Vec2f(0,-3));
			else if(this.isKeyPressed(key_left))this.setVelocity(Vec2f(-5,-3));
			else if(this.isKeyPressed(key_right)) this.setVelocity(Vec2f(5,-3));
			else this.setVelocity(Vec2f(0,-3));
			
			Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
			velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
			ParticlePixel(point, velr, SColor(255, 255, 255, 0), true);
			this.getSprite().PlayRandomSound("/Scrape");
		}
	}
}

f32 getAimAngle(CBlob @this){

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f vec = aimpos - pos;
	return vec.Angle();

}

void ManageFist(CBlob @this, bool holding, string type){ //Inb4 FIST! clan things I made this class for them

	if(holding){
		if(this.get_s16(type+"_fist_drawback") < 30)this.set_s16(type+"_fist_drawback",this.get_s16(type+"_fist_drawback")+2);
	} else {
		if(this.get_s16(type+"_fist_drawback") > 10){
			DoPunch(this,f32(this.get_s16(type+"_fist_drawback"))/30.0f*0.75f+0.25f,-getAimAngle(this),20);
			this.set_s16(type+"_fist_drawback",-20);
		}
		if(this.get_s16(type+"_fist_drawback") > 0)this.set_s16(type+"_fist_drawback",0);
		if(this.get_s16(type+"_fist_drawback") < 0)this.set_s16(type+"_fist_drawback",this.get_s16(type+"_fist_drawback")+3);
	}
	if(this.get_s16(type+"_fist_drawback") != 0)this.Tag(type+"_fisting");
	else if(this.hasTag(type+"_fisting"))this.Untag(type+"_fisting");
}

void DoPunch(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(10 + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), 12);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{

				//big things block attacks
				const bool large = !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, Hitters::muscles, true);  // server_Hit() is server-side only
					CSprite @sprite = this.getSprite();

					
					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
		}
	}
}

bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}