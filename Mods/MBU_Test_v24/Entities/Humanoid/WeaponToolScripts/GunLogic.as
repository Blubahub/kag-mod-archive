
#include "Hitters.as";
#include "ModHitters.as";

void onInit(CBlob@ this)
{
	this.addCommandID("shoot_gun");
}





void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shoot_gun")){
		CBlob@ target = getBlobByNetworkID(params.read_u16());
		CBlob@ gun = getBlobByNetworkID(params.read_u16());
		Vec2f HitPos = params.read_Vec2f();
		bool Main = params.read_bool();
		
		if(gun is null)return;

		if(gun.get_s8("bullets") > 0){
		
			gun.sub_s8("bullets",1);
		
			if(this.getSprite() !is null)this.getSprite().PlaySound(gun.get_string("sound_fire"));
			
			string type = "main";
			if(!Main)type = "sub";
			
			Vec2f RayHitPos = HitPos;
			getMap().rayCastSolidNoBlobs(this.getPosition(),HitPos,RayHitPos);
			
			Vec2f Dir = RayHitPos-this.get_Vec2f(type+"_gun_barrel_pos");
			int Length = Dir.getLength();
			Dir.Normalize();
			
			for(int i = 0;i < 10;i++)
			makeSteamParticle(this.get_Vec2f(type+"_gun_barrel_pos"), Dir*(f32(20+XORRandom(31))/30.0f)+Vec2f(0,f32(XORRandom(10)-5)/20.0f));
			
			for(int i = 0;i < 10;i++){
				CParticle @p = ParticleSpark(this.get_Vec2f(type+"_gun_barrel_pos"), Dir*(f32(20+XORRandom(31))/30.0f)+Vec2f(0,f32(-XORRandom(10))/20.0f), SColor(255,255,XORRandom(255),0));
				if(p !is null){
					p.gravity = Vec2f(0,0.1f);
				}
			}
			
			for(int i = 0;i < Length;i += XORRandom(Length/5)+1){
				makeSteamParticle(this.get_Vec2f(type+"_gun_barrel_pos")+Dir*f32(i), Dir*(f32(20+XORRandom(31))/30.0f)+Vec2f(0,f32(XORRandom(10)-5)/20.0f));
			}
			
			if(getNet().isServer()){
				this.server_Hit(target, HitPos, Vec2f(0,0), gun.get_f32("damage"), Hitters::bullet, true);

				CBlob @bullet = server_CreateBlobNoInit("mat_bullet");
				if(bullet !is null){
					bullet.setPosition(RayHitPos);
					bullet.Tag('custom quantity');
					bullet.server_SetQuantity(1);
					if(target is null)bullet.setVelocity(Dir*40.0f);
					else bullet.setVelocity(Dir*10.0f);
					bullet.Init();
					if(target is null)bullet.setVelocity(Dir*40.0f);
					else bullet.setVelocity(Dir*10.0f);
				}
			}
		
		}
	}
}

void makeSteamParticle(Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), pos, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}