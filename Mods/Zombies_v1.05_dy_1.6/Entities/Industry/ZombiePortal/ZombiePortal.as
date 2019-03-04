// Builder Workshop

//#include "Requirements.as"
//#include "ShopCommon.as";
//#include "Descriptions.as";
//#include "WARCosts.as";
//#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	//this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	CSpriteLayer@ portal = this.getSprite().addSpriteLayer( "portal", "ZombiePortal.png" , 64, 64, -1, -1 );
	CSpriteLayer@ lightning = this.getSprite().addSpriteLayer( "lightning", "EvilLightning.png" , 32, 32, -1, -1 );
	Animation@ anim = portal.addAnimation( "default", 0, true );
	Animation@ lanim = lightning.addAnimation( "default", 4, false );
	for (int i=0; i<7; i++) lanim.AddFrame(i*4);
	Animation@ lanim2 = lightning.addAnimation( "default2", 4, false );
	for (int i=0; i<7; i++) lanim2.AddFrame(i*4+1);
	anim.AddFrame(1);
	portal.SetRelativeZ( 1000 );
//	portal.SetOffset(Vec2f(0,-24));
//	lightning.SetOffset(Vec2f(0,-24));
	this.getShape().getConsts().mapCollisions = false;
	this.set_bool("portalbreach",false);
	this.set_bool("portalplaybreach",false);
	this.SetLight(false);
	this.SetLightRadius( 64.0f );
	
}

void onDie( CBlob@ this)
{
	server_DropCoins(this.getPosition() + Vec2f(0,-32.0f), 1000);
}
void onTick( CBlob@ this)
{
	//Current number
	int num_normal_skeletons = getRules().get_s32("num_normal_skeletons");
	int num_normal_zombies = getRules().get_s32("num_normal_zombies");
	int num_wraiths = getRules().get_s32("num_wraiths");
	int num_gregs = getRules().get_s32("num_gregs");
	int num_zombieknights = getRules().get_s32("num_zombieknights");
	//Maxes

	int max_zombieknights = getRules().get_s32("max_zombieknights");
	int max_gregs = getRules().get_s32("max_gregs");
	int max_wraiths = getRules().get_s32("max_wraiths");
	int max_normal_zombies = getRules().get_s32("max_normal_zombies");
	int max_skeletons = getRules().get_s32("max_skeletons");
	int bossRound = getRules().get_s32("bossRound");
	int gamestart = getRules().get_s32("gamestart");
	int day_cycle = getRules().daycycle_speed * 60;
	int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
	int extra_wraiths_day = getRules().get_s32("extra_wraiths_day");
	int spawnRate = 16 + (184*this.getHealth() / 42.0);
	int max_zombies = getRules().get_s32("max_zombies");
	
	if (getGameTime() % spawnRate == 0 && this.get_bool("portalbreach"))
	{
		this.getSprite().PlaySound("Thunder");
		CSpriteLayer@ lightning = this.getSprite().getSpriteLayer("lightning");
		if (XORRandom(4)>2) lightning.SetAnimation("default"); else lightning.SetAnimation("default2");
		//lightning.SetFrame(0);
	}

	if (this.get_bool("portalplaybreach")) {
		this.getSprite().PlaySound("PortalBreach");
		this.set_bool("portalplaybreach",false);
		this.SetLight(true);
		this.SetLightRadius( 64.0f );		
	}
	if (!getNet().isServer()) return;
	int num_zombies = getRules().get_s32("num_zombies");
	if (this.get_bool("portalbreach"))
	{
		if ((getGameTime() % spawnRate == 0))
		{
			Vec2f sp = this.getPosition();
			if ((bossRound != 1 || bossRound == 2) && num_zombies<max_zombies)
			{
				
				if (dayNumber > extra_wraiths_day)
				{
					max_wraiths = max_wraiths * 2;
				}
				
				int r;
				//if (actdiff>9) r = XORRandom(9); else r = XORRandom(actdiff);
				r = XORRandom(9);
				int rr = XORRandom(9);
				if (r==8 && rr==8 && num_wraiths < max_wraiths || ((dayNumber > extra_wraiths_day) && r==8 && (num_wraiths < max_wraiths)))
					server_CreateBlob( "Wraith", -1, sp);
				else
				if (r==7 && num_gregs < max_gregs)
					server_CreateBlob( "Greg", -1, sp);
				else
				if (r>=5 && r<=6 && rr<=5 && num_zombieknights < max_zombieknights)
				{
					//if(XORRandom(2) == 0)
					server_CreateBlob( "ZombieKnight", -1, sp);
					//else
					//server_CreateBlob( "BossEmo", -1, sp);
				}
				else
				if (r>=3 && num_normal_zombies < max_normal_zombies)
				{
					server_CreateBlob( "Zombie", -1, sp);
				}
				else
				{
					if (num_normal_skeletons < max_skeletons)
						server_CreateBlob( "Skeleton", -1, sp);
				}
					
			}
		}
	}
	else
	{
		if (getGameTime() % 600 == 0)
		{
			Vec2f sp = this.getPosition();
			
		
			CBlob@[] blobs;
			this.getMap().getBlobsInRadius( sp, 64, @blobs );
			for (uint step = 0; step < blobs.length; ++step)
			{
				CBlob@ other = blobs[step];
				if (other.hasTag("player"))
				{
					this.set_bool("portalbreach",true);
					this.set_bool("portalplaybreach",true);
					this.Sync("portalplaybreach",true);
					this.Sync("portalbreach",true);
				}
			}
		}
	}
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
//	this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
}
							   
