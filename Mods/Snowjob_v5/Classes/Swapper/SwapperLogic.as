// Template logic
// If I haven't commented something, it's because I don't know what it is, but I do know it's important.


//Import scripts! These are important for reasons. Basically, they let you steal code from base to use as your own, legally.
#include "Hitters.as"; //Basically, all the types of attacks you get.
#include "Knocked.as"; //Known as stun.
#include "ThrowCommon.as"; //You know when you press 'C' in game and you throw what you're holding?
#include "RunnerCommon.as"; //Movement scripts.

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f); //When the class/blob reaches negative 3 hp, it explodes into gore.

	this.Tag("player"); //This is a player
	this.Tag("flesh"); //This class is also flesh. Tags like plant/stone/metal don't work unless you code them yourself

	CShape@ shape = this.getShape(); //Getting our physics variable
	shape.SetRotationsAllowed(false); //Let's not roll all over the place.
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_s16("stab_cooldown",0);
	
	this.set_s16("swap",0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16)); //This basically sets our score board icon.
	}
}

void onTick(CBlob@ this) //This script is called 30 times a second. It's a general update script. Most of your modding will be done here.
{
	if(this.isInInventory()) //Are we in an inventory? 
		return; //Yes? Back the heck out. We can't use abilities in inventories.

	const bool ismyplayer = this.isMyPlayer(); //Is this our player?

	if(ismyplayer && getHUD().hasMenus()) //If this is our player AND we are in a menu...
	{
		return; //...back the heck out!
	}

	// activate/throw
	if(ismyplayer) //If this is our player
	{

		if(this.isKeyJustPressed(key_action3)) //And we hit action3(default spacebar)
		{
			CBlob@ carried = this.getCarriedBlob(); //Get what we are carrying
			if(carried is null) //If we are carrying something...
			{
				client_SendThrowOrActivateCommand(this); //...throw it! Or activate it.
			}
		}
	}
	
	if(this.get_s16("stab_cooldown") > 0)this.set_s16("stab_cooldown",this.get_s16("stab_cooldown")-1);
	if(this.isKeyPressed(key_action1) && !this.isKeyPressed(key_action2))
	{
		RunnerMoveVars@ moveVars;
		if(this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor = 0.5f;
			moveVars.jumpFactor = 0.5f;
		}
		if(this.get_s16("stab_cooldown") <= 0){
			if(!this.isFacingLeft())DoAttack(this, 0.5f, 0.0f, 45.0f, Hitters::sword, 1);
			else DoAttack(this, 0.5f, 180.0f, 45.0f, Hitters::sword, 1);
			this.set_s16("stab_cooldown",12);
		}
	}
	
	if(this.get_s16("swap") >= 0){
		if(this.isKeyPressed(key_action2))
		{
			RunnerMoveVars@ moveVars;
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor = 0.0f;
				moveVars.jumpFactor = 0.0f;
			}
			if(this.getVelocity().y <= 0){
				this.setVelocity(Vec2f(0,-1));
				if(getNet().isServer()){
					this.set_s16("swap",this.get_s16("swap")+1);
					this.Sync("swap",true);
				}
			}
			if(this.get_s16("swap") > 60){
				
				bool Teleported = false;
				
				if(!Teleported){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getAimPos(), 32.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b !is null)if(b.getTeamNum() != this.getTeamNum() && b.hasTag("player") && !b.hasTag("dead")){
								if(getNet().isServer()){
									CBlob @swap = server_CreateBlob("swap",-1,this.getPosition());
									swap.set_u16("swap",b.getNetworkID());
									CBlob @myswap = server_CreateBlob("swap",-1,b.getPosition());
									myswap.set_u16("swap",this.getNetworkID());
								}
								Teleported = true;
								break;
							}
						}
					}
				}
				
				if(!Teleported){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getAimPos(), 32.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b !is null)if(b.getTeamNum() == this.getTeamNum() && b.hasTag("player") && !b.hasTag("dead")){
								if(getNet().isServer()){
									CBlob @swap = server_CreateBlob("swap",-1,this.getPosition());
									swap.set_u16("swap",b.getNetworkID());
									CBlob @myswap = server_CreateBlob("swap",-1,b.getPosition());
									myswap.set_u16("swap",this.getNetworkID());
								}
								Teleported = true;
								break;
							}
						}
					}
				}
				
				if(!Teleported){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getAimPos(), 32.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b !is null)if(b.hasTag("flesh") && !b.hasTag("dead")){
								if(getNet().isServer()){
									CBlob @swap = server_CreateBlob("swap",-1,this.getPosition());
									swap.set_u16("swap",b.getNetworkID());
									CBlob @myswap = server_CreateBlob("swap",-1,b.getPosition());
									myswap.set_u16("swap",this.getNetworkID());
								}
								Teleported = true;
								break;
							}
						}
					}
				}
				
				if(getNet().isServer()){
					if(Teleported)this.set_s16("swap",-30*10);
					else this.set_s16("swap",-30*2);
					this.Sync("swap",true);
				}
			}
		}
	} else {
		if(getNet().isServer()){
			this.set_s16("swap",this.get_s16("swap")+1);
			this.Sync("swap",true);
		}
	}
	
}



void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, int deltaInt)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(8 + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), 8)*2;

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	const bool jab = true;

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (b.hasTag("ignore sword")) continue;

				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, type, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else  // hitmap
				if (!dontHitMoreMap && (deltaInt == 2 + 1))
				{
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					if (ground || wood || dirt_stone || gold)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);
						f32 tileangle = offset.Angle();
						f32 dif = Maths::Abs(exact_aimangle - tileangle);
						if (dif > 180)
							dif -= 360;
						if (dif < -180)
							dif += 360;

						dif = Maths::Abs(dif);
						//print("dif: "+dif);

						if (dif < 20.0f)
						{
							//detect corner

							int check_x = -(offset.x > 0 ? -1 : 1);
							int check_y = -(offset.y > 0 ? -1 : 1);
							if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
							        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
								continue;

							bool canhit = true; //default true if not jab

							//dont dig through no build zones
							canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

							dontHitMoreMap = true;
							if (canhit)
							{
								map.server_DestroyTile(hi.hitpos, 0.1f, this);
							}
						}
					}
				}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	        (deltaInt == 2 + 1)) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}
bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}