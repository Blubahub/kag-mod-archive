/*
Do you really have to read this file?

That's kinda boring :/






















































*/
#include "RunesCommon.as";
#include "Health.as";

void PrimaryAbility(CBlob@ this, CBlob @Holder, int AbilityID, f32 Power, int Heat, int Flow, int Holy, int Complexity){
	
	switch(AbilityID){
	
		case 1:{ //Fire
			if(Power > 0)Fireball(this, Holder, Power, Heat);
		break;}
		case 2:{ //Water
			if(Power > 0)Geyser(this, Holder, Power, Flow);
		break;}
		case 3:{ //Earth
			if(Power > 0)BoulderToss(this, Holder, Power);
		break;}
		case 4:{ //Air
			if(Power > 0)Push(this, Holder, Power);
		break;}
		
		case 5:{ //Flesh
			if(Power > 0)Teeth(this, Holder, Power);
		break;}
		case 6:{ //Plant
			if(Power > 0)Root(this, Holder, Power, Flow);
		break;}
		case 7:{ //Space
			if(Power > 0)Blink(this, Holder, Power);
		break;}
		case 8:{ //Time
			if(Power > 0)Slow(this, Holder, Power,Flow);
		break;}
		
		case 9:{ //Light
			if(Power > 0)DeathGuard(this, Holder, Power);
		break;}
		case 10:{ //Life
			if(Power > 0)Revive(this, Holder, Power, Holy);
		break;}
		case 11:{ //Restore
			if(Power > 0)MassHeal(this, Holder, Power, Holy);
		break;}
		
		case 12:{ //Dark
			if(Power > 0)Shroud(this, Holder, Power, Holy);
		break;}
		case 13:{ //Decay
			if(Power > 0)DeathBarrage(this, Holder, Power, Holy);
		break;}
		case 14:{ //Decay
			if(Power > 0)Plague(this, Holder, Power, Holy);
		break;}
	}

}



void Fireball(CBlob @this, CBlob @Holder, f32 Power, int Heat)
{
	if (getNet().isServer()){
		CBlob @blob = server_CreateBlob("scrollfire", Holder.getTeamNum(), Holder.getPosition());
		blob.SetDamageOwnerPlayer(Holder.getPlayer());
		Vec2f arrowVel = (Holder.getPosition() - Holder.getAimPos());
		arrowVel.Normalize();
		arrowVel *= -6;
		blob.setVelocity(arrowVel);
		blob.set_f32("damage",Power*(Heat*1.0f));
		blob.Sync("damage",true);
	}
}

void Geyser(CBlob @this, CBlob @Holder, f32 Power, int Flow)
{
	if (getNet().isServer()){
		CBlob @blob = server_CreateBlob("geyser", Holder.getTeamNum(), Holder.getPosition());
		blob.set_f32("MaxHeight",180*Power);
		blob.set_u8("Push",Flow*Power);
	}
}

void BoulderToss(CBlob @this, CBlob @Holder, f32 Power)
{
	if (getNet().isServer()){
		Vec2f arrowVel = (Holder.getPosition() - Holder.getAimPos());
		arrowVel.Normalize();
		
		CBlob @blob = server_CreateBlob("boulder", Holder.getTeamNum(), Holder.getPosition()-(arrowVel*24));
		blob.SetDamageOwnerPlayer(this.getPlayer());
		
		arrowVel *= -10*Power;
		blob.setVelocity(arrowVel);
	}
}

void Push(CBlob @this, CBlob @Holder, f32 Power)
{
	if (getNet().isServer()){
		CBlob @blob = server_CreateBlob("push", Holder.getTeamNum(), Holder.getPosition());
		blob.set_u8("radius",25.0f*Power);
	}
}

void Teeth(CBlob @this, CBlob @Holder, f32 Power)
{
	if (getNet().isServer()){
		CBlob @blob = server_CreateBlob("tooth", Holder.getTeamNum(), Holder.getPosition()+Vec2f(0,-16));
		blob.set_u8("count",15.0f*Power);
		if(!Holder.isFacingLeft())blob.set_s8("direction",1);
		else blob.set_s8("direction",-1);
	}
}

void Root(CBlob @this, CBlob @Holder, f32 Power, int Flow)
{
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getTeamNum() != Holder.getTeamNum() && b.hasTag("flesh"))
			{
				b.AddScript("Root.as");
				b.set_u32("root_timer",getGameTime()+30.0f*(10.0f*Power*((10.0f-Flow)/10.0f)));
			}
		}
	}
}



void Blink(CBlob @this, CBlob @Holder, f32 Power){
	CMap@ map = this.getMap();
	Vec2f surfacepos;
	Vec2f direction = (Holder.getAimPos()-Holder.getPosition());
	direction.Normalize();
	map.rayCastSolid(Holder.getPosition(), Holder.getPosition()+direction*200*Power, surfacepos);
	
	for(int i=0;i<200*Power;i+=10) ParticleAnimated("RuneParticle.png", Holder.getPosition()+direction*i, Vec2f(0,0), 0, 1.0f, 3, 0, true);
	
	// Sounds by TFlippy
	Holder.getSprite().PlaySound("CK_Blink", 1.00f, 1.00f);
	
	Holder.setPosition(surfacepos-direction*8);
}


void Slow(CBlob @this, CBlob @Holder, f32 Power, int Flow)
{
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getTeamNum() != Holder.getTeamNum() && b.hasTag("flesh"))
			{
				b.AddScript("Slow.as");
				float time = 30.0f*(10.0f*Power);
				b.set_u32("slow_timer",getGameTime()+(time+1));
				b.set_u32("slow_time_amount",(time+1));
				b.set_f32("slow_amount",(Power-(float(Flow)*0.1f)));
			}
		}
	}
}

void DeathGuard(CBlob @this, CBlob @Holder, f32 Power)
{
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getTeamNum() == Holder.getTeamNum() && b.hasTag("flesh") && !b.hasTag("Halo"))
			{
				b.AddScript("DeathGuard.as");
				
				for(int j=0;j<10;j++)
				ParticleAnimated("HolyParticle.png", b.getPosition()+Vec2f(XORRandom(16)-8,-12), Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 1+XORRandom(3), 0.0f, true);
				break;
			}
		}
	}
}

void Revive(CBlob @this, CBlob @Holder, f32 Power, int Holy)
{
	int amount = Holy*Power;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
	{
		// Sounds by TFlippy
		Holder.getSprite().PlaySound("WC3_Revive", 1.00f, 1.00f);
	
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getTeamNum() == Holder.getTeamNum() && b.hasTag("flesh") && b.hasTag("dead"))
			{
				if(getPlayerByUsername(b.get_string("username")) !is null)
				if(getPlayerByUsername(b.get_string("username")).getBlob() is null){
					if(getNet().isServer()){
						CBlob @ blob = server_CreateBlob(b.getName(),b.getTeamNum(),b.getPosition());
						blob.server_SetPlayer(getPlayerByUsername(b.get_string("username")));
						blob.RemoveScript("DeathGuard.as");
						b.server_Die();
					}
					
					Vec2f vec = Vec2f(16,0);
					for(int r = 0; r < 360; r += 10){
						vec.RotateBy(r);
						Vec2f dir = b.getPosition()-(b.getPosition()+vec);
						dir.Normalize();
						ParticleAnimated("HolyParticle.png", b.getPosition()+vec, Vec2f(XORRandom(5)-2,XORRandom(5)-2)*0.25, XORRandom(360), 0.5f+0.25f*float(XORRandom(2))+0.5f*float(XORRandom(2)), 1+XORRandom(3), 0.0f, true);
					}
					
					amount -= 1;
					if(amount <= 0)break;
				}
			}
		}
	}
}


void MassHeal(CBlob @this, CBlob @Holder, f32 Power, int Holy)
{
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 256.0f*Power, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getTeamNum() == Holder.getTeamNum() && b.hasTag("flesh"))
			{
				Heal(b,Holy*Power);
				b.Tag("Cleanse");
				
				Vec2f vec = Vec2f(16,0);
				for(int r = 0; r < 360; r += 10){
					vec.RotateBy(r);
					Vec2f dir = b.getPosition()-(b.getPosition()+vec);
					dir.Normalize();
					ParticleAnimated("HealParticle.png", b.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
					ParticleAnimated("HealParticle.png", b.getPosition()+vec, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
				}
			}
		}
	}
}


void Shroud(CBlob @this, CBlob @Holder, f32 Power, int evil)
{
	if (getNet().isServer()){
		CBlob @blob = server_CreateBlob("shroud", Holder.getTeamNum(), Holder.getPosition());
		blob.set_f32("scale",Power*(float(10-evil)/10.0f)*2);
	}
}

void DeathBarrage(CBlob @this, CBlob @Holder, f32 Power, int Holy)
{

	int amount = (5-Holy)*2-1;

	Vec2f vec = Vec2f(32,0);
	if(getNet().isServer())
	for(int r = 0; r < amount; r += 1){
		vec.RotateBy(-float(180.0f/amount));
		CBlob @death = server_CreateBlob("deathorb", Holder.getTeamNum(), Holder.getPosition()+vec);
		death.set_f32("damage",Power*5);
		death.SetDamageOwnerPlayer(Holder.getPlayer());
		death.setVelocity(Vec2f(0.0f,-6.0f));
	}
}

void Plague(CBlob @this, CBlob @Holder, f32 Power, int evil)
{
	if (getNet().isServer()){
		for(int i=0;i<Power*(float(10-evil)/10.0f)*10;i++)server_CreateBlob("plague", Holder.getTeamNum(), Holder.getPosition()+Vec2f(XORRandom(32)-16,XORRandom(32)-16));
	}
}










void SecondaryAbility(CBlob@ this, CBlob @Holder, int AbilityID, int Heat, int Flow, int Holy, int Complexity){
	
	switch(AbilityID){
	
		case 1:{ //Fire
			LivingFlame(this, Holder);
		break;}
		case 2:{ //Water
			AirBubble(this, Holder);
		break;}
		case 3:{ //Stone
			StoneShield(this, Holder);
		break;}
		case 4:{ //Air
			HighJump(this, Holder);
		break;}
	
		case 5:{ //Consume
			SelfHeal(this, Holder);
		break;}
		case 6:{ //Growth
			Regen(this, Holder);
		break;}
		case 7:{ //Space
			Recall(this, Holder);
		break;}
		case 8:{ //Time
			Haste(this, Holder);
		break;}
		
		case 9:{ //light
			LightOrb(this, Holder);
		break;}
		case 10:{ //life
			Barrier(this, Holder);
		break;}
		case 11:{ //Restore
			Cleanse(this, Holder);
		break;}
		
		case 12:{ //Invisible
			Invisible(this, Holder);
		break;}
		case 13:{ //Death
			SelfSacrifice(this, Holder);
		break;}
		case 14:{ //Decay
			if(Holy <= 1)SelfPlague(this, Holder);
		break;}
	}

}


void LivingFlame(CBlob @this, CBlob @Holder)
{
	Holder.AddScript("LivingFlame.as");
}

void AirBubble(CBlob @this, CBlob @Holder)
{
	Holder.AddScript("AirBubble.as");
}

void StoneShield(CBlob @this, CBlob @Holder)
{
	Holder.AddScript("StoneShield.as");
}

void HighJump(CBlob @this, CBlob @Holder)
{
	Holder.AddForce(Vec2f(0,-800));
}

void SelfHeal(CBlob @this, CBlob @Holder)
{
	if(Health(Holder) < MaxHealth(Holder)*1.4){
		OverHeal(Holder,0.5);
		for(int i=0;i<10;i++)
		ParticleAnimated("HealParticle.png", Holder.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 1.0f, 5, -0.1f, true);
	}
}

void Regen(CBlob @this, CBlob @Holder)
{
	Holder.AddScript("RegenVines.as");
}

// Sounds by TFlippy
void Recall(CBlob@ this, CBlob@ holder)
{
	CBlob@[] tents;
	getBlobsByName("flag_base", @tents);
	
	holder.getSprite().PlaySound("WC3_Recall", 1.00f, 1.00f);
	if (holder.isMyPlayer())
	{
		SetScreenFlash(255, 255, 255, 255);
		Sound::Play("WC3_Recall");
	}
	
	for(uint i = 0; i < tents.length; i++)
	{
		if(tents[i].getTeamNum() == holder.getTeamNum())
		{
			holder.setPosition(tents[i].getPosition());
			holder.setVelocity( Vec2f_zero );			  
			holder.getShape().PutOnGround();
			
			tents[i].getSprite().PlaySound("WC3_Recall", 1.00f, 1.00f);
			
			break;
		}
	}
}

void Haste(CBlob @this, CBlob @Holder)
{
	Holder.AddScript("Haste.as");
}

void LightOrb(CBlob @this, CBlob @Holder)
{
	if (getNet().isServer()){
		CBlob @blob = server_CreateBlob("lightorb", Holder.getTeamNum(), Holder.getPosition());
	}
}

void Barrier(CBlob @this, CBlob @Holder)
{
	Holder.AddScript("Barrier.as");
}

void Cleanse(CBlob @this, CBlob @Holder)
{
	Holder.Tag("Cleanse");
	if(getNet().isServer())this.Sync("Cleanse",true);
}

void Invisible(CBlob @this, CBlob @Holder)
{
	Holder.AddScript("Invisibility.as");
}

void SelfSacrifice(CBlob @this, CBlob @Holder)
{
	if(getNet().isServer())
	{
		if(Holder.hasTag("evil") || Holder.hasTag("undead"))this.server_Hit(Holder, this.getPosition(), Vec2f(0,0), 0.25f, Hitters::suddengib, true);
		else if(Holder.hasTag("holy"))this.server_Hit(Holder, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::suddengib, true);
		else this.server_Hit(Holder, this.getPosition(), Vec2f(0,0), 0.5f, Hitters::suddengib, true);
	}
}

void SelfPlague(CBlob @this, CBlob @Holder)
{
	Holder.AddScript("Plague.as");
}