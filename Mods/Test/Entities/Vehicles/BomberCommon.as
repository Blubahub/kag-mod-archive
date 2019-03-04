#include "VehicleCommon.as"
#include "Hitters.as"
#include "Explosion.as";

// Boat logic

void onInit(CBlob@ this)
{
	this.Tag("aerial");

	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255,255,240,171));

	this.set_f32("map dmg modifier",35.0f);
	this.set_u32("lastDropTime",0);
	
	this.getSprite().SetEmitSound(this.exists("bomber_sound") ? this.get_string("bomber_sound") : "BomberLoop.ogg");
	
	//this.set_f32("fuel",0.0f);
	//this.set_f32("fuelMax",50.0f);
}
void onTick(CBlob@ this)
{
	//don't stop executing this when bomber is empty
	if(this.getHealth()>1.0f) {
		VehicleInfo@ v;
		if(!this.get("VehicleInfo",@v)) {
			return;
		}
		CSprite@ sprite=this.getSprite();
		sprite.SetEmitSoundPaused(false);
		sprite.SetEmitSoundVolume(0.3f + v.soundVolume);
		BomberHandling(this,v);

		//TODO: move to atmosphere damage script
		// f32 y=	this.getPosition().y;
		// if(y<100) {
			// if(getGameTime() % 15 == 0)
				// this.server_Hit(this,this.getPosition(),Vec2f(0,0),y<50 ?(y<0 ? 2.0f : 1.0f) : 0.25f,0,true);
		// }
	// }else{
		// this.server_DetachAll();
		// this.setAngleDegrees(this.getAngleDegrees() +(this.isFacingLeft() ? 1 : -1));
		// if(this.isOnGround() || this.isInWater()) {
			// this.Untag("invincible");
			// this.server_SetHealth(-1.0f);
			// this.server_Die();
		// }else{
			// this.Tag("invincible");
		// }
	}
}
void BomberHandling(CBlob@ this,VehicleInfo@ v)
{
	AttachmentPoint@ driverSeat=this.getAttachments().getAttachmentPointByName("FLYER");
	if(driverSeat !is null){
		CBlob@ blob= driverSeat.getOccupied();
		//Jumping out
		if(blob !is null){
			if(blob.isMyPlayer() && driverSeat.isKeyJustPressed(key_up)) {
				CBitStream params;
				params.write_u16(blob.getNetworkID());
				this.SendCommand(this.getCommandID("vehicle getout"),params);
				return;
			}
		}
		//Bombing
		if (!this.hasTag("disable bomber drop") && driverSeat.isKeyPressed(key_action3) && this.get_u32("lastDropTime")<getGameTime()) {
			CInventory@ inv=	this.getInventory();
			if(inv !is null) {
				u32 itemCount=	inv.getItemsCount();
				
				if(getNet().isClient()) {
					if(itemCount>0){ 
						this.getSprite().PlaySound("bridge_open",1.0f,1.0f);
					}else if(blob !is null && blob.isMyPlayer()){
						Sound::Play("NoAmmo");
					}
				}
				if(itemCount>0) {
					if(getNet().isServer()) {
						CBlob@ item=	inv.getItem(0);
						u32 quantity=	item.getQuantity();

						if(item.maxQuantity>8) { // To prevent spamming 
							this.server_PutOutInventory(item);
							item.setPosition(this.getPosition());
						}else{
							CBlob@ dropped=server_CreateBlob(item.getName(),this.getTeamNum(),this.getPosition());
							dropped.server_SetQuantity(1);
							dropped.SetDamageOwnerPlayer(blob.getPlayer());
							dropped.Tag("no pickup");
							
							if(quantity>0){
								item.server_SetQuantity(quantity-1);
							}
							if(item.getQuantity()==0) {
								item.server_Die();
							}
						}
					}
				}
				this.set_u32("lastDropTime",getGameTime()+30);
			}
		}
		//Handling
		const Vec2f vel=this.getVelocity();
		f32 moveForce=	v.move_speed;
		f32 turnSpeed=	v.turn_speed;

		Vec2f force;
		bool up=		driverSeat.isKeyPressed(key_action1);
		bool down=		driverSeat.isKeyPressed(key_action2);
		bool left=		driverSeat.isKeyPressed(key_left);
		bool right=		driverSeat.isKeyPressed(key_right);
		bool fakeCrash=	blob is null && !this.isOnGround() && !this.isInWater();
		if(fakeCrash) {
			up=		false;
			down=	true;
			if(Maths::Abs(vel.x)>=0.5f){
				left=	vel.x<0.0f ? true : false;
				right=	vel.x<0.0f ? false : true;
			}
		}
		
		v.soundVolume=		Maths::Clamp(Lerp(v.soundVolume,up ? 1.0f : (down ? 0.0f : (this.isOnGround() ? 0.0f : 0.15f)),(1.0f/getTicksASecond())*2.5f),0.0f,1.0f);
		float goalSpeed=	fakeCrash ? -300.0f : ((up ? v.fly_speed : 0.0f)+(down ? -v.fly_speed / 2 : 310.15f));
		force.y=			Lerp(v.fly_amount,goalSpeed,(1.0f/getTicksASecond())*(fakeCrash ? 0.2f : 1.0f));
		v.fly_amount=		force.y;

		if(left) {
			force.x-=moveForce;
			if(vel.x<-turnSpeed) {
				this.SetFacingLeft(true);
			}
		}
		if(right) {
			force.x+=moveForce;
			if(vel.x>turnSpeed){
				this.SetFacingLeft(false);
			}
		}
		if(fakeCrash) {
			if(Maths::Abs(vel.x)>=0.5f){
				force.x*=1.1f;
			}
		}
		this.AddForce(Vec2f(force.x,-force.y));
	}
}
/*void onAddToInventory(CBlob@ this,CBlob@ blob)
{
	if(blob.getName()=="mat_oil"){
		int quantity=	this.get_f32("fuel");
		this.set_f32("fuel",quantity+blob.getQuantity());
		blob.server_Die();
	}
}*/
void onCollision(CBlob@ this,CBlob@ blob,bool solid)
{
	float power=this.getOldVelocity().getLength();
	if(power>1.5f &&(solid ||(blob !is null && blob.isCollidable() && blob.getTeamNum()!=this.getTeamNum() && this.doesCollideWithBlob(blob)))){
		if(getNet().isClient()){
			Sound::Play("WoodHeavyHit1.ogg",this.getPosition(),1.0f);
		}
		this.server_Hit(this,this.getPosition(),Vec2f(0,0),this.getAttachments().getAttachmentPointByName("FLYER") is null ? power*2.5f : power*0.6f,0,true);
	}
}

void onDie( CBlob@ this )
{
	//explode all bombs we dropped from inventory cuz of death
	CBlob@[] explosives;
	// getBlobsByName("mat_smallbomb",		@explosives);
	// getBlobsByName("mat_bigbomb",		@explosives);
	// getBlobsByName("mat_incendiarybomb",@explosives);
	getBlobsByTag("explosive",@explosives);
	
	for(int i=0;i<explosives.length();i++){
		float distance=(explosives[i].getPosition()-this.getPosition()).Length();
		if(distance<1.0f){
			explosives[i].Tag("DoExplode");
			explosives[i].server_Die();
		}
	}
	
	Sound::Play("WoodDestruct.ogg",this.getPosition(),1.0f);
	DoExplosion(this,this.getOldVelocity());
	
	AttachmentPoint@ driverSeat = this.getAttachments().getAttachmentPointByName("FLYER");
	if (driverSeat !is null)
	{
		CBlob@ blob= driverSeat.getOccupied();
		if (blob !is null)
		{
			blob.server_Die();
		}
	}
}

void DoExplosion(CBlob@ this,Vec2f velocity)
{
	Sound::Play("KegExplosion.ogg",this.getPosition(),1.0f);
	this.set_Vec2f("explosion_offset",Vec2f(0,-16).RotateBy(this.getAngleDegrees()));
	
	Explode(this,32.0f,3.0f);
	for(int i=0;i<16;i++) {
		Vec2f dir=		Vec2f(1-i / 2.0f,-1+i / 2.0f);
		Vec2f jitter=	Vec2f((XORRandom(200)-100) / 200.0f,(XORRandom(200)-100) / 200.0f);
		
		LinearExplosion(this,Vec2f(dir.x*jitter.x,dir.y*jitter.y),16.0f+XORRandom(16),10.0f,4,5.0f,Hitters::explosion);
	}
	this.getSprite().Gib();
}
void Vehicle_onFire(CBlob@ this,VehicleInfo@ v,CBlob@ bullet,const u8 charge)
{
	print("hello");
}
bool Vehicle_canFire(CBlob@ this,VehicleInfo@ v,bool isActionPressed,bool wasActionPressed,u8 &out chargeValue)
{
	return true;
}
bool doesCollideWithBlob(CBlob@ this,CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this,blob) && !blob.hasTag("turret") && !blob.isAttached();
}
bool canBePickedUp(CBlob@ this,CBlob@ byBlob)
{
	return false;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	AttachmentPoint@ ap_pilot = this.getAttachments().getAttachmentPointByName("FLYER");
	
	// print("test");
	
	if (ap_pilot !is null)
	{
		return ap_pilot.getOccupied() == null;
	}
	else return false;
}

void onAttach(CBlob@ this,CBlob@ attached,AttachmentPoint @attachedPoint)
{
	if (attached.hasTag("bomber")) return;

	attached.Tag("invincible");
	attached.Tag("invincibilityByVehicle");

	VehicleInfo@ v;
	if(!this.get("VehicleInfo",@v))
	{
		return;
	}
	Vehicle_onAttach(this,v,attached,attachedPoint);
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	if (detached.hasTag("bomber")) return;

	detached.Untag("invincible");
	detached.Untag("invincibilityByVehicle");

	VehicleInfo@ v;
	if(!this.get("VehicleInfo",@v))
	{
		return;
	}
	Vehicle_onDetach(this,v,detached,attachedPoint);
}