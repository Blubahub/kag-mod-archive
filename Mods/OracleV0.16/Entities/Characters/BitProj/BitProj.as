
#include "Hitters.as";
#include "ShieldCommon.as";
#include "FireParticle.as"
#include "ArcherCommon.as";
#include "BombCommon.as";
#include "SplashWater.as";
#include "TeamStructureNear.as";
#include "Knocked.as"

const s32 bomb_fuse = 120;
const f32 arrowMediumSpeed = 8.0f;
const f32 arrowFastSpeed = 13.0f;
//maximum is 15 as of 22/11/12 (see ArcherCommon.as)

const f32 ARROW_PUSH_FORCE = 6.0f;
const f32 SPECIAL_HIT_SCALE = 1.0f; //special hit on food items to shoot to team-mates

const s32 FIRE_IGNITE_TIME = 5;


//Arrow logic

//blob functions
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
  this.set_u32("tick",0);
	this.Tag("projectile");
  
  CSprite@ sprt = this.getSprite();
  
  if(sprt !is null)
  {
    sprt.SetAnimation(this.get_string("arrow type"));
  }

	//dont collide with top of the map
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	// 20 seconds of floating around - gets cut down for fire arrow
	// in ArrowHitMap
	this.server_SetTimeToDie(10);

	

	
}
void onTick(CBlob@ this)
{
  this.set_u32("tick", this.get_u32("tick") + 1);
  
  if(this.get_string("arrow type") == "zora" && !this.get_bool("ZoraDisable") && this.get_u32("tick") == 12)
  {
     ShootArrow(this, this.getPosition() , this.getPosition() + this.getVelocity() , 7.0f , 0.5f, 10, "zora"); 
     ShootArrow(this, this.getPosition() , this.getPosition() + this.getVelocity() , 7.0f , 0.5f, -10, "zora"); 
  }
	CShape@ shape = this.getShape();

	f32 angle;
	bool processSticking = true;
	if (!this.hasTag("collided")) //we haven't hit anything yet!
	{
		//temp arrows arrows die in the air
		

		//prevent leaving the map
		{
			Vec2f pos = this.getPosition();
			if (pos.x < 0.1f ||
			        pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
			{
				this.server_Die();
				return;
			}
		}

		angle = (this.getVelocity()).Angle();
		Pierce(this);   //map
		this.setAngleDegrees(-angle);
    
    shape.SetGravityScale(0.0f);
		
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided"))
	{
    
      if(blob.getTeamNum() == this.getTeamNum() && this.get_string("arrow type") == "snake") 
      {
        blob.server_Heal(0.5f);
        this.server_Die();
      }
      else if(blob.getTeamNum() != this.getTeamNum() && this.get_string("arrow type") == "snake") 
      {
        blob.set_u32("Poison",100);
        CPlayer@ P = this.getDamageOwnerPlayer();
        if( P !is null)
        {
          CBlob@ B = P.getBlob();
          if(B !is null)
          {
            blob.set_u32("PoisonID",B.getNetworkID());
          }
        }
        
        this.server_Die();
      }
      else if(blob.getTeamNum() != this.getTeamNum() && this.get_string("arrow type") == "goron" && this.get_bool("stun")) 
      {
        blob.set_u32("Stun",40);
      }
      else if(blob.getTeamNum() != this.getTeamNum() && this.get_string("arrow type") == "ghost") 
      {
        CPlayer@ p = this.getDamageOwnerPlayer();
        if(p !is null)
        {
          CBlob@ b = p.getBlob();
          if( b !is null)
          {
            b.server_Heal(0.25f);
          }
        }
      }
      else if(blob.getTeamNum() == this.getTeamNum() && this.get_string("arrow type") == "snakepotheal") 
      {
        blob.server_Heal(0.25f);
        this.server_Die();
      }
      else if(blob.getTeamNum() != this.getTeamNum() && blob.getName() == "blaino" && blob.isKeyPressed(key_action2) && blob.get_u32("Reload2") > 0) 
      {
        if(getNet().isServer() )
        {
          print("hi " + this.get_f32("ArrowDamage") );
          ShootArrow(blob, this.getPosition() , this.get_Vec2f("start") , 12.0f , this.get_f32("Damage"),0,this.get_string("arrow type"));
          this.server_Die();
          return;
        }
        
      }
      
      if(blob.getTeamNum() != this.getTeamNum() && this.get_string("arrow type") == "din") 
      {
        if(getNet().isServer() && blob.hasTag("player"))
        {
          int lmao = XORRandom(360);
          ShootArrow(this, blob.getPosition() + Vec2f(16.0f,0.0f).RotateBy(lmao) , blob.getPosition() + Vec2f(17.0f,0.0f).RotateBy(lmao) , 7.0f , 0.5f); 
        }
      }
      
      Vec2f initVelocity = this.getOldVelocity();
      f32 vellen = initVelocity.Length();
      if (vellen < 0.1f)
        return;

      f32 dmg = 0.0f;
      if (blob.getTeamNum() != this.getTeamNum())
        dmg = getArrowDamage(this, vellen);
        // this isnt synced cause we want instant collision for arrow even if it was wrong
        dmg = ArrowHitBlob(this, point1, initVelocity, dmg, blob, Hitters::arrow, 0);
        if (this.get_string("arrow type") == "marin")
        {
          this.server_Hit(blob, point1, initVelocity , dmg, Hitters::arrow);
          Vec2f velocity = blob.getPosition() - this.getPosition();
          Vec2f force = velocity * 70;
          blob.AddForce( force );
            
        }
        else if (this.get_string("arrow type") == "hook")
        {
          this.server_Hit(blob, point1, initVelocity , dmg, Hitters::arrow);
          Vec2f velocity = blob.getPosition() - this.get_Vec2f("start");
          Vec2f force = velocity * 7;
          blob.AddForce( -force );
            
        }
        else if (dmg > 0.0f )
        {
            this.server_Hit(blob, point1, initVelocity, dmg, Hitters::arrow);
        }
      

      if (dmg > 0.0f )   // dont stick bomb arrows
      {
        this.server_Die();
      }
    
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("projectile") || blob.getName() == "point" || blob.getName() == "tent")
	{
		return false;
	}
  
  

	bool check = this.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
  
  if(!check && (this.get_string("arrow type") == "snake" || this.get_string("arrow type") == "snakepotheal")) 
  {
    return true;
  }
	if (!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (check)
	{
		if (this.getShape().isStatic() ||
		        this.hasTag("collided") ||
		        blob.hasTag("dead") ||
		        blob.hasTag("ignore_arrow"))
		{
			return false;
		}
		else
		{
			return true;
		}
	}


	return false;
}

void Pierce(CBlob @this, CBlob@ blob = null)
{
	Vec2f end;
	CMap@ map = this.getMap();
	Vec2f position = blob is null ? this.getPosition() : blob.getPosition();

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		ArrowHitMap(this, end, this.getOldVelocity(), 0.5f, Hitters::arrow);
	}
}


f32 ArrowHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData, const u8 arrowType)
{
	if (hitBlob !is null)
	{
		Pierce(this, hitBlob);
		if (this.hasTag("collided")) return 0.0f;

		// check if invincible + special -> add force here

		// check if shielded
		const bool hitShield = (hitBlob.hasTag("shielded") && blockAttack(hitBlob, velocity, 0.0f));

		if (hitBlob.hasTag("flesh"))
		{
     
      if (hitBlob.getTeamNum() == this.getTeamNum())
			{
				//this.getSprite().PlaySound("Heal.ogg");
			}
			else
			{
        if(this.get_string("arrow type") == "cactus")
          this.getSprite().PlaySound("CactusHit.ogg");
        else if (this.get_string("arrow type") == "din")
          this.getSprite().PlaySound("DinHit.ogg");
        else if (this.get_string("arrow type") == "hook")
          this.getSprite().PlaySound("HookHit.ogg");
        else if (this.get_string("arrow type") == "goron")
          this.getSprite().PlaySound("GoronPotHit.ogg");
        else
          this.getSprite().PlaySound("Hit.ogg");
        
			}
		}
			
		this.server_Die();
	}

	return damage;
}

void ArrowHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	this.server_Die();
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (!getNet().isServer())
	{
		return;
	}

	const u8 arrowType = this.get_u8("arrow type");
	if (arrowType == ArrowType::bomb)
	{
		return;
	}

	// merge arrow into mat_arrows

	for (int i = 0; i < inventoryBlob.getInventory().getItemsCount(); i++)
	{
		CBlob @blob = inventoryBlob.getInventory().getItem(i);

		if (blob !is this && blob.getName() == "mat_arrows")
		{
			blob.server_SetQuantity(blob.getQuantity() + 1);
			this.server_Die();
			return;
		}
	}

	// mat_arrows not found
	// make arrow into mat_arrows
	CBlob @mat = server_CreateBlob("mat_arrows");

	if (mat !is null)
	{
		inventoryBlob.server_PutInInventory(mat);
		mat.server_SetQuantity(1);
		this.server_Die();
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	// unbomb, stick to blob
	if (this !is hitBlob && customData == Hitters::arrow)
	{
		// affect players velocity

		const f32 scale =  1.0f;

		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if (speed > ArcherParams::shoot_max_vel * 0.5f)
		{
			f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass() + 1) * scale;

			if (this.hasTag("bow arrow"))
			{
				force *= 1.3f;
			}

			hitBlob.AddForce(velocity * force);
		}
	}
}


f32 getArrowDamage(CBlob@ this, f32 vellen = -1.0f)
{
	if (vellen < 0) //grab it - otherwise use cached
	{
		CShape@ shape = this.getShape();
		if (shape is null)
			vellen = this.getOldVelocity().Length();
		else
			vellen = this.getShape().getVars().oldvel.Length();
	}

	
	return this.get_f32("Damage");
	
	

	return 0.5f;
}

void SplashArrow(CBlob@ this)
{
	if (!this.hasTag("splashed"))
	{
		this.Tag("splashed");
		Splash(this, 3, 3, 0.0f, true);
		this.getSprite().PlaySound("GlassBreak");
	}
}


void ShootArrow(CBlob@ this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const f32 arrow_type, const f32 legolas = 0, string types = "din")
{
		Vec2f arrowVel = (aimpos - arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		CreateArrow(this, arrowPos, arrowVel.RotateBy(legolas), arrow_type, types);
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, f32 arrowType, string types)
{
  
  CBlob@ arrow = server_CreateBlobNoInit("bitproj");
	if (arrow !is null)
	{
		// fire arrow?
    arrow.set_bool("ZoraDisable",true);
		arrow.set_string("arrow type", types);
    arrow.set_f32("Damage", arrowType);
    arrow.set_Vec2f("start",this.getPosition());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
    arrow.server_SetTimeToDie(5);	
	}
	return arrow;
}
