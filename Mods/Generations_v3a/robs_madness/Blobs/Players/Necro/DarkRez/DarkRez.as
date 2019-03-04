// Lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 215, 20, 255));
	
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
	
	this.server_SetTimeToDie(1.2f);
	
	this.setVelocity(Vec2f(0,-1));
	
	this.Tag("can_dispell");
	
	CSprite @sprite = this.getSprite();
	if(sprite !is null){
		sprite.SetZ(1000);
	}
}

void onDie(CBlob@ this)
{
	CBlob@[] blobsInRadius;	
	if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("dead") && b.getName() != "necro" && b.hasTag("flesh"))
			{
				for(int j = 0; j < getPlayerCount(); j ++){
					CPlayer @player = getPlayer(j);
					if(player.getTeamNum() == b.getTeamNum() || player.getTeamNum() == this.getTeamNum())
					if(player.getBlob() is null){
						
						Sound::Play("ZombieHit.ogg", this.getPosition());
						
						for(float k = 0.0f; k < this.getDistanceTo(b); k ++){
							Vec2f direction = b.getPosition()-this.getPosition();
							direction.Normalize();
							//ParticlePixel(this.getPosition()+direction*k+Vec2f(XORRandom(7)-3,XORRandom(7)-3), direction*2.0f, SColor(255, 60+XORRandom(50), 0+XORRandom(50), 90+XORRandom(50)), true);
							ParticleAnimated("DeathPuff.png", this.getPosition()+direction*k+Vec2f(XORRandom(7)-3,XORRandom(7)-3), Vec2f(0,0), XORRandom(360), 1.0f, 2, 0, true);
						}
						
						//NO RESPAWN FOR YOU, MWAHAHAHAHA XD
						if(getNet().isServer()){
							
							string type = "zombie";
							
							if(b.getName() == "ghoul")type = "ghoul";
							
							if(b.getName() == "zombie")type = "skeleton";
							
							if(b.getName() == "necro")type = "necro";
							
							CBlob @zombie = server_CreateBlob(type,this.getTeamNum(),b.getPosition());
							zombie.server_SetPlayer(player);
							b.server_Die();
						}
						
						break;
					}
				}
			
			}
		}
	}
	
	Vec2f vec = Vec2f(128,0);
	for(int r = 0; r < 360; r += 5){
		vec.RotateBy(r);
		Vec2f dir = this.getPosition()-(this.getPosition()+vec);
		dir.Normalize();
		ParticleAnimated("DeathPuff.png", this.getPosition()+vec, Vec2f(0,0), XORRandom(360), 1.0f, 2, 0, true);
		ParticleAnimated("DeathPuff.png", this.getPosition()+dir*XORRandom(128), Vec2f(0,0), XORRandom(360), 1.0f, 2, 0, true);
	}
}