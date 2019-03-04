
#include "AnimalConsts.as";
#include "Hitters.as";

const u8 DEFAULT_PERSONALITY = 0;

//sprite

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	string baby = "";
	if(blob.hasTag("baby"))baby = "baby";
	
	if(blob.isOnGround() || blob.isAttached()){
		this.SetAnimation(baby+"idle");
	} else {
		this.SetAnimation(baby+"fall");
	}
}

//blob

void onInit(CBlob@ this)
{
	//brain
	this.set_u8(personality_property, AGGRO_BIT);
	this.getBrain().server_SetActive(true);
	this.set_f32(target_searchrad_property, 30.0f);
	this.set_f32(terr_rad_property, 160.0f);
	this.set_u8(target_lose_random, 14);

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);

	this.getShape().SetOffset(Vec2f(0, 7));

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;

	// movement

	AnimalVars@ vars;
	if (!this.get("vars", @vars))
		return;
	vars.walkForce.Set(2.0f, -0.1f);
	vars.runForce.Set(2.0f, -1.0f);
	vars.slowForce.Set(1.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -25.0f);
	vars.maxVelocity = 1.1f;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true; //maybe make a knocked out state? for loading to cata?
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("onewithnature"))return false;
	return blob.getShape().isStatic() || blob.getName() == "slime" || blob.getTeamNum() != this.getTeamNum();
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	if (Maths::Abs(x) > 0.0f)
	{
		this.SetFacingLeft(x < 0);
	}
	else
	{
		if (this.isKeyPressed(key_left))
		{
			this.SetFacingLeft(true);
		}
		if (this.isKeyPressed(key_right))
		{
			this.SetFacingLeft(false);
		}
	}
	
	if (this.isAttached())
	{
		if(!this.hasTag("baby")){
			AttachmentPoint@ att = this.getAttachmentPoint(0);   //only have one
			if (att !is null)
			{
				CBlob@ b = att.getOccupied();
				if (b !is null && this.getTeamNum() != b.getTeamNum() && !b.hasTag("onewithnature"))
				{
					if (getNet().isServer())this.server_Hit(b, b.getPosition(), Vec2f(0,0.1), 0.25f, Hitters::suddengib, false);
					if(XORRandom(10) == 0){
						if (getNet().isServer())b.DropCarried();
					}
				}
			}
		}
	} else if(this.isOnGround()){
		if(XORRandom(20) == 0){
			this.AddForce(Vec2f((XORRandom(2)*2-1)*10,-50));
		}
	}
	
	if(!this.hasTag("baby"))
	if(XORRandom(1000) == 0)
	if (getNet().isServer())
	{
		Vec2f pos = this.getPosition();
		int slimeCount = 0;
		string name = this.getName();
		CBlob@[] blobs;
		this.getMap().getBlobsInRadius(pos, 128, @blobs);
		for (uint step = 0; step < blobs.length; ++step)
		{
			CBlob@ other = blobs[step];
			if (other is this)
				continue;

			const string otherName = other.getName();
			if (otherName == name)
			{
				slimeCount++;
			}
		}

		if (slimeCount < 5)
		{
			{
			CBlob @baby = server_CreateBlob("slime", this.getTeamNum(), this.getPosition() + Vec2f(-2.0f, 5.0f));
			baby.Tag("baby");
			}
			{
			CBlob @baby = server_CreateBlob("slime", this.getTeamNum(), this.getPosition() + Vec2f(2.0f, 5.0f));
			baby.Tag("baby");
			}
			this.server_Die();
		}
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(!this.isOnGround())
	if(blob !is null && blob.hasTag("flesh") && this.getTeamNum() != blob.getTeamNum() && !blob.hasTag("onewithnature"))
	{
		if(!this.hasTag("baby"))
		if(getNet().isServer()){
			this.server_Hit(blob, this.getPosition(), this.getVelocity()*-0.5f, 0.25f, Hitters::suddengib, false);
		}
		this.getSprite().PlaySound("Gurgle2", 2.00f, 2.00f);
	}
	
	
	if(this.hasTag("baby"))
	if(XORRandom(5) == 0)
	if(blob !is null && (blob.getName() == "log" || blob.getName() == "seed" || blob.getName() == "flowers" || blob.getName() == "grain" || blob.getName() == "bush"))
	{
		if (getNet().isServer()){
			this.Untag("baby");
			this.Sync("baby",true);
			blob.server_Die();
		}
		this.getSprite().PlaySound("Gurgle2", 2.00f, 2.00f);
	}
	
	if(solid){
		if(XORRandom(10) == 0)makeGibParticle("GenericGibs.png", this.getPosition()+Vec2f(XORRandom(8)-4,2+XORRandom(4)), Vec2f(XORRandom(4)-2,-XORRandom(2)), 7, 1+XORRandom(4), Vec2f(8, 8), 2.0f, 20, "Gurgle2", this.getTeamNum());
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if(this.hasTag("baby"))this.server_setTeamNum(attached.getTeamNum());
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{	

	this.getSprite().PlaySound("Gurgle2", 2.00f, 2.00f);
	makeGibParticle("GenericGibs.png", this.getPosition()+Vec2f(XORRandom(8)-4,2+XORRandom(4)), Vec2f(XORRandom(4)-2,-XORRandom(2)), 7, 1+XORRandom(4), Vec2f(8, 8), 2.0f, 20, "Gurgle2", this.getTeamNum());

    return damage;
}

void onDie(CBlob @this){
	this.getSprite().Gib();
	ParticlesFromSprite(this.getSprite());
}