#include "Hitters.as";
#include "ModHitters.as";
#include "ep.as";
#include "Ally.as";
#include "eleven.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	if(this.getName() == "wo")this.set_u8("size",8);
	else if(this.getName() == "woo")this.set_u8("size",16);
	else if(this.getName() == "wooo")this.set_u8("size",32);
	else if(this.getName() == "woooo")this.set_u8("size",64);
	else this.set_u8("size",8);
	
	int size = this.get_u8("size");
	
	this.SetLight(true);
	this.SetLightRadius(this.get_u8("size")*2.0f);
	this.SetLightColor(SColor(255, 0, 255, 255));
	
	this.getShape().SetGravityScale(0.0f);
	
	for(int i = 0; i < 5; i++)lp(this.getPosition()+Vec2f(XORRandom(size+1)-(size/2),XORRandom(size+1)-(size/2)), false, this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4);
	
	this.set_u16("created",getGameTime());
	
	this.Tag("wo");
}

void onTick(CBlob@ this)
{
	int size = this.get_u8("size");
	
	if(getNet().isClient()){
		CSprite @sprite = this.getSprite();
		if(sprite !is null){
			sprite.SetZ(1500.0f);
		}
		
		if(XORRandom(64) < size)lp(this.getPosition()+Vec2f(XORRandom(size+1)-(size/2),XORRandom(size+1)-(size/2)), false, this.getVelocity()+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.4);
	}
	
	if(this.hasTag("push")){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null && !b.hasTag("push") && b.hasTag("wo")){
					Vec2f vec = b.getPosition()-this.getPosition();
					vec.Normalize();
					b.AddForce(this.getVelocity()/1000.0f*this.getDistanceTo(b)+vec*0.01f);
				}
			}
		}
	}
	
	int create = this.get_u16("created")+600;
	if(this.hasTag("burst") || this.hasTag("spawn"))create -= 400;
	
	if(getGameTime() % 40 == 0){
		if(getNet().isServer()){
			if(this.hasTag("spawn")){
				if(this.getName() == "wooo"){
					CBlob @w = server_CreateBlob("woo",this.getTeamNum(),this.getPosition());
					if(w !is null){
						w.setVelocity(Vec2f(0,-0.5f));
						w.Tag("spawn");
						w.set_u16("created",this.get_u16("created")+100);
					}
					
					CBlob @w2 = server_CreateBlob("woo",this.getTeamNum(),this.getPosition());
					if(w2 !is null){
						w2.setVelocity(Vec2f(0,+0.5f));
						w2.Tag("spawn");
						w2.set_u16("created",this.get_u16("created")+100);
					}
				} else {
					server_CreateBlob("wo",this.getTeamNum(),this.getPosition());
				}
			}
			
			if(!checkEInterface(this,this.getPosition(),size,size/2))this.server_Die();
		}
	}
	
	
	if(getGameTime() > create){
		int time = (getGameTime()-create);
		
		this.getSprite().ScaleBy(Vec2f(1.0f-(f32(time)*0.1f),1.0f-(f32(time)*0.1f)));
		
		if(getNet().isServer()){
			if(this.hasTag("burst") && !this.hasTag("bursted")){
			
					string name = "wooo";
					
					if(this.getName() == "wooo")name = "woo";
					if(this.getName() == "woo")name = "wo";
					
					Vec2f angle = this.getVelocity();
					angle.Normalize();
					for(int i = 0; i < 8; i++){
					
						angle.RotateBy(45.0f);
						CBlob @w = server_CreateBlob(name,this.getTeamNum(),this.getPosition());
						if(w !is null){
							w.setVelocity(angle);
						}
					}
			
				this.Tag("bursted");
			}
		}
		
		if(getNet().isServer())if(time > 10)this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.hasTag("flesh") && !blob.hasTag("dead") && checkAlly(this.getTeamNum(),blob.getTeamNum()) != Team::Ally);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null && solid)this.server_Die();
	
	if(blob !is null)
	if(blob.hasTag("flesh") && !blob.hasTag("dead") && checkAlly(this.getTeamNum(),blob.getTeamNum()) != Team::Ally)
	{
		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*f32(this.get_u8("size"))/128.0f, f32(this.get_u8("size")), Hitters::life_flame, true);
		this.server_Die();
	}	
}