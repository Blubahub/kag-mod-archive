
#include "WeaponCommon.as";

void onInit(CBlob@ this)
{
	this.setAimPos(this.getPosition()+Vec2f(0,-32));
	
	this.set_u16("gun_type",0);
	
	this.addCommandID("attach");
	this.addCommandID("dettach");
	
	this.set_u16("charge_time",0);
	this.set_u8("shots_fired",0);
	this.set_u8("shots_cooldown",0);
	
	this.set_u8("chains",0);
	this.set_u8("chaindecay",0);
	
	this.Tag("builder always hit");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.isOverlapping(caller) && this.getTeamNum() == caller.getTeamNum()){
		if(caller.getCarriedBlob() !is null){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(0, Vec2f(0,0), this, this.getCommandID("attach"), "Attach weapon", params);
			button.SetEnabled(caller.getCarriedBlob().getName() == "weapon");
		} else 
		if(this.get_u16("gun_type") > 0){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(1, Vec2f(0,0), this, this.getCommandID("dettach"), "Dettach weapon", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("attach"))
	{

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			if(caller.getCarriedBlob() !is null && this.get_u16("gun_type") == 0){
			
				this.set_u16("gun_type",caller.getCarriedBlob().get_u16("type"));
				caller.getCarriedBlob().server_Die();
			
				if(getNet().isServer()){
					this.Sync("gun_type",true);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("dettach"))
	{

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			if(this.get_u16("gun_type") != 0){
			
				CBlob @weapon = server_CreateBlob("weapon",0,this.getPosition());
				weapon.set_u16("type",this.get_u16("gun_type"));

				this.set_u16("gun_type",0);
				
				if(getNet().isServer()){
					this.Sync("gun_type",true);
					weapon.Sync("type",true);
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if(this.hasTag("no loot"))return;
	if(getNet().isServer())if(this.get_u16("gun_type") > 0){
		CBlob @weapon = server_CreateBlob("weapon",0,this.getPosition());
		if(weapon !is null)weapon.set_u16("type",this.get_u16("gun_type"));
	}
}

void onTick(CBlob@ this)
{
	
	int GunType = this.get_u16("gun_type");
	
	CBlob@[] blobs;
	
	getBlobsByName("weapon_room", blobs);

	int Best = -1;
	f32 bestLength = 160.0f;
	
	for (u32 k = 0; k < blobs.length; k++)
	{
		CBlob@ blob = blobs[k];
		Vec2f dir = this.getPosition() - blob.getPosition();
		f32 length = dir.Length();
		
		if(length < bestLength){
			bestLength = length;
			Best = k;
		}
	}
	
	if(Best >= 0){
		CBlob@ blob = blobs[Best];
		this.set_Vec2f("aim",blob.get_Vec2f("aim"));
		if(this.hasTag("firing")){
			if(this.get_u16("charge_time") >= ChargeTime[GunType]){

				if(this.get_u8("shots_cooldown") <= 0){
				
					
					if(ProjectileType[GunType] != ""){
						Vec2f dir = this.get_Vec2f("aim") - this.getPosition();
						dir.Normalize();
						if(getNet().isServer()){
							CBlob @projectile = server_CreateBlob(ProjectileType[GunType],this.getTeamNum(),this.getPosition()+(dir*48));
							if(projectile !is null)projectile.setVelocity(dir*16);
						}
						if(ProjectileType[GunType] == "laser" || ProjectileType[GunType] == "heavy_laser")Sound::Play("laser.ogg");
						if(ProjectileType[GunType] == "ion" || ProjectileType[GunType] == "ion2")Sound::Play("ion_spawn.ogg");
					}
					
					if(this.get_u8("chains") < ChainMax[GunType])this.set_u8("chains",this.get_u8("chains")+1);
					
					this.set_u8("chaindecay",0);
					
					this.set_u8("shots_cooldown",5);
					
					this.set_u8("shots_fired",this.get_u8("shots_fired")+1);
				
				} else {
					this.set_u8("shots_cooldown",this.get_u8("shots_cooldown")-1);
				}
				
				if(this.get_u8("shots_fired") > Shots[GunType]-1){
					this.set_u16("charge_time",ChainExtraSpeed[GunType]*this.get_u8("chains"));
					this.set_u8("shots_cooldown",0);
					this.set_u8("shots_fired",0);
				}
				if(getNet().isServer()){
					this.Sync("charge_time",true);
					this.Sync("shots_cooldown",true);
					this.Sync("shots_fired",true);
				}
			} else {
				this.Untag("firing");
				if(getNet().isServer())this.Sync("firing",true);
			}
		}
	}
	
	if(this.get_u16("charge_time") < ChargeTime[GunType])this.set_u16("charge_time",this.get_u16("charge_time")+1);
	else {
	
		this.set_u16("charge_time",ChargeTime[GunType]);
	
		if(this.get_u8("chains") > 0){
			this.set_u8("chaindecay",this.get_u8("chaindecay")+1);
			if(this.get_u8("chaindecay") >= 30){
				this.set_u8("chaindecay",0);
				this.set_u8("chains",0);
			}
		}
	}
}



void onInit(CSprite@ this)
{
	this.SetZ(-50.0f);

	CSpriteLayer@ port = this.addSpriteLayer("port", "Turret.png", 24, 24);

	if (port !is null)
	{
		Animation@ anim = port.addAnimation("default", 0, false);
		anim.AddFrame(1);
		port.SetAnimation(anim);
		port.SetRelativeZ(5.0f);
		port.SetLighting(false);
	}
	
	CSpriteLayer@ weapon = this.addSpriteLayer("weapon", "WeaponSprite.png", 96, 16);

	if (weapon !is null)
	{
		Animation@ anim = weapon.addAnimation("default", 0, false);
		anim.AddFrame(0);
		weapon.SetAnimation(anim);
		weapon.SetRelativeZ(2.5f);
		weapon.SetLighting(false);
	}
	
	this.getBlob().getShape().SetRotationsAllowed(false);
}

void onTick(CSprite@ this){

	CBlob @blob = this.getBlob();
	
	if(blob is null)return;

	Vec2f dir = blob.getPosition() - blob.get_Vec2f("aim");
	f32 angle = dir.Angle();
	
	if(blob.get_Vec2f("aim").x == 0 && blob.get_Vec2f("aim").y == 0){
		angle = 270;
	}
	
	if(this.getSpriteLayer("port") !is null){
		this.getSpriteLayer("port").ResetTransform();
		this.getSpriteLayer("port").RotateBy(-angle+180, Vec2f(0,0));
	}
	
	if(this.getSpriteLayer("weapon") !is null){
		this.getSpriteLayer("weapon").ResetTransform();
		this.getSpriteLayer("weapon").RotateBy(-angle+180, Vec2f(0,0));
		
		
		
		this.getSpriteLayer("weapon").SetFrame(blob.get_u16("gun_type")*6+((blob.get_u16("charge_time")*1.0f)/(ChargeTime[blob.get_u16("gun_type")]*1.0f)*5));
	}
	
	
	

}