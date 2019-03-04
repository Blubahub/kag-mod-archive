#include "/Entities/Common/Attacks/Hitters.as";
#include "/Entities/Common/Attacks/LimitedAttacks.as";
#include "ContainerCommon.as";
#include "FireParticle.as"

const int pierce_amount = 8;

const f32 hit_amount_ground = 0.5f;
const f32 hit_amount_air = 1.0f;
const f32 hit_amount_air_fast = 3.0f;
const f32 hit_amount_cata = 10.0f;

void onInit(CBlob @ this)
{
	this.set_u8("launch team", 255);
	this.server_setTeamNum(-1);
	this.Tag("medium weight");

	LimitedAttack_setup(this);

	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
	
	this.addCommandID("soup");
}

void onTick(CBlob@ this)
{
	if(this.isInWater() && !isFilled(this)){
		int amount = this.get_u8("max_amount");
		amount -= getAmount(this);
		adjustChem(this,"water_amount",amount);
	}
	
	if (getNet().isClient()){
		if(this.get_u8("water_amount") > 0 && this.get_u8("heat") > 75){ //Steamy
			Vec2f random = Vec2f(XORRandom(12) - 6, -8);
			ParticleAnimated(CFileMatcher("SmallSteam").getFirst(), this.getPosition() + random, Vec2f(0,-0.01), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
		}
		if(this.get_u8("water_amount") <= 0 && this.get_u8("heat") > 75 && !isEmpty(this)){
			Vec2f random = Vec2f(XORRandom(12) - 6, -8);
			makeSmokeParticle(this.getPosition() + random, -0.05f);
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is null)
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(19, Vec2f(0,-4), this, this.getCommandID("insert"), "Insert Ingrediant", params);
	}
	if(caller.getCarriedBlob() is null && !isEmpty(this)){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(9, Vec2f(0,4), this, this.getCommandID("dump"), "Dump Contents", params);
	}
	if(caller.getCarriedBlob() is null && getAmount(this) >= 30){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(24, Vec2f(4,0), this, this.getCommandID("soup"), "Serve a bowl of soup", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{	
	if (cmd == this.getCommandID("soup")){
		if (getNet().isServer() && getAmount(this) >= 30){
			CBlob@ soup = server_CreateBlob("soup", -1, this.getPosition()+Vec2f(0,-8));
			Transfer(this,soup,30);
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.set_u8("launch team", detached.getTeamNum());
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.set_u8("launch team", attached.getTeamNum());
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid && blob !is null)
	{
		Vec2f hitvel = this.getOldVelocity();
		Vec2f hitvec = point1 - this.getPosition();
		f32 coef = hitvec * hitvel;

		if (coef < 0.706f) // check we were flying at it
		{
			return;
		}

		f32 vellen = hitvel.Length();

		//fast enough
		if (vellen < 1.0f)
		{
			return;
		}

		u8 tteam = this.get_u8("launch team");
		CPlayer@ damageowner = this.getDamageOwnerPlayer();

		//not teamkilling (except self)
		if (damageowner is null || damageowner !is blob.getPlayer())
		{
			if (
			    (blob.getName() != this.getName() &&
			     (blob.getTeamNum() == this.getTeamNum() || blob.getTeamNum() == tteam))
			)
			{
				return;
			}
		}

		//not hitting static stuff
		if (blob.getShape() !is null && blob.getShape().isStatic())
		{
			return;
		}

		//hitting less or similar mass
		if (this.getMass() < blob.getMass() - 1.0f)
		{
			return;
		}

		//get the dmg required
		hitvel.Normalize();
		f32 dmg = vellen > 8.0f ? 5.0f : (vellen > 4.0f ? 1.5f : 0.5f);

		//bounce off if not gibbed
		if(dmg < 4.0f)
		{
			this.setVelocity(blob.getOldVelocity() + hitvec * -Maths::Min(dmg * 0.33f, 1.0f));
		}

		//hurt
		this.server_Hit(blob, point1, hitvel, dmg, Hitters::boulder, true);

		return;

	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return damage *= 0.5f;
	}

	return damage;
}

//sprite

void onTick(CSprite@ this)
{
	if(this.getBlob().get_u8("heat") > 75)this.animation.frame = 1;
	else this.animation.frame = 0;
}
