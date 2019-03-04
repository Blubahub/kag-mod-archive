// Swing Door logic

#include "Hitters.as"
#include "FireCommon.as"
#include "MapFlags.as"
#include "EquipCommon.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = true;
	
	this.getSprite().SetZ(-100.0f);

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);

	// this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 0;


	//block knight sword
	this.Tag("blocks sword");

	this.Tag("door");
	this.Tag("blocks water");
	
	this.Tag("place norotate");
	this.set_Vec2f("place offset",Vec2f(0.0f,-4.0f));
	this.Tag("ignore blocking actors");
	
	
	this.set_u8("destruction",0);
	//this.getShape().SetStatic(false);
	
	this.set_s16("password",-1);
	
	//this.Tag("locked");
	
	this.addCommandID("add_lock");
	this.addCommandID("unlock");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.getShape().isStatic()){
		if(caller.getCarriedBlob() !is null && caller.getCarriedBlob().getName() == "simplelock" && this.get_s16("password") == -1){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("add_lock"), "Add lock to door", params);
		}
		
		if(this.get_s16("password") != -1){
			
			bool canUnlock = false;
			
			if(getEquippedBlob(caller,"back") !is null){
			
				CBlob @invBlob = getEquippedBlob(caller,"back");
				
				if(invBlob.getInventory() !is null){
					CInventory @inv = invBlob.getInventory();
					for(int i = 0; i < inv.getItemsCount(); i += 1){
						CBlob @item = inv.getItem(i);
						if(item !is null && item.getName() == "simplekey"){
							if(item.get_s16("password") == this.get_s16("password"))canUnlock = true;
						}
					}
				}
			}
			
			if(caller.getCarriedBlob() !is null && caller.getCarriedBlob().getName() == "simplekey"){
				if(caller.getCarriedBlob().get_s16("password") == this.get_s16("password"))canUnlock = true;
			}
			
			if(canUnlock){
			
				int icon = 3;
				string text = "Unlock";
				if(!this.hasTag("locked")){
					icon = 2;
					text = "Lock";
				}
				
				CButton@ button = caller.CreateGenericButton(icon, Vec2f(0,0), this, this.getCommandID("unlock"), text);
			
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("add_lock"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@ hold = caller.getCarriedBlob();
			if(hold !is null){
				if(getNet().isServer()){
					if(hold.getName() == "simplelock"){
						this.set_s16("password",hold.get_s16("password"));
						this.Sync("password",true);
						hold.server_Die();
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("unlock"))
	{	
		if(getNet().isServer()){
			if(this.hasTag("locked"))this.Untag("locked");
			else this.Tag("locked");
			this.Sync("locked",true);
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

void setOpen(CBlob@ this, bool open, bool faceLeft = false)
{
	CSprite@ sprite = this.getSprite();
	if (open)
	{
		if(this.getShape().isStatic()){
			sprite.SetZ(-100.0f);
			sprite.SetAnimation("open"+this.get_u8("destruction"));
			sprite.SetFacingLeft(faceLeft);   // swing left or right
			Sound::Play("/DoorOpen.ogg", this.getPosition());
		}
		this.getShape().getConsts().collidable = false;
		this.getCurrentScript().tickFrequency = 3;
	}
	else
	{
		if(this.getShape().isStatic()){
			sprite.SetZ(100.0f);
			sprite.SetAnimation("close"+this.get_u8("destruction"));
			Sound::Play("/DoorClose.ogg", this.getPosition());
		}
		this.getShape().getConsts().collidable = true;
		this.getCurrentScript().tickFrequency = 0;
	}

	//TODO: fix flags sync and hitting
	//SetSolidFlag(this, !open);
}

void onTick(CBlob@ this)
{
	const uint count = this.getTouchingCount();
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob is null) continue;

		if (!this.hasTag("locked") && !isOpen(this))
		{
			Vec2f pos = this.getPosition();
			Vec2f other_pos = blob.getPosition();
			Vec2f direction = Vec2f(1, 0);
			direction.RotateBy(this.getAngleDegrees());
			setOpen(this, true, ((pos - other_pos) * direction) < 0.0f);
		}
	}
	// close it
	if (isOpen(this) && canClose(this))
	{
		setOpen(this, false);
	}
}


bool canClose(CBlob@ this)
{
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			collided++;
		}
	}
	return collided == 0;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		this.getCurrentScript().tickFrequency = 3;
	}
}

void onEndCollision(CBlob@ this, CBlob@ blob)
{
	if (blob !is null)
	{
		if (canClose(this))
		{
			if (isOpen(this))
			{
				setOpen(this, false);
			}
			this.getCurrentScript().tickFrequency = 0;
		}
	}
}


bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.getShape().isStatic();
}

// this is such a pain - can't edit animations at the moment, so have to just carefully add destruction frames to the close animation >_>
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CSprite @sprite = this.getSprite();

	if (sprite !is null)
	{
		u8 frame = 0;

		if (this.getHealth() < this.getInitialHealth())
		{
			f32 ratio = (this.getHealth() - damage * getRules().attackdamage_modifier) / this.getInitialHealth();


			if (ratio <= 0.25f)
			{
				frame = 3;
			} else
			if (ratio <= 0.5f)
			{
				frame = 2;
			} else
			if (ratio <= 0.75f)
			{
				frame = 1;
			}
		}
	
		this.set_u8("destruction",frame);
	}

	return damage;
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	
	if (isOpen(this))
		return false;

	if (!this.hasTag("locked"))
	{
		Vec2f pos = this.getPosition();
		Vec2f other_pos = blob.getPosition();
		Vec2f direction = Vec2f(1, 0);
		direction.RotateBy(this.getAngleDegrees());
		setOpen(this, true, ((pos - other_pos) * direction) < 0.0f);
		return false;
	}
	
	return true;
}
