#include "RunnerCommon.as"
#include "Hitters.as"
#include "Knocked.as"

void onInit(CBlob@ this) 
{
  this.set_u32("healcooldown", 600);
}

void onTick(CBlob@ this)
{
	
	RunnerMoveVars@ moveVars;

	/*if(this.get("moveVars", @moveVars))
	{
		moveVars.jumpFactor = 1.0f;
	}*/
	
	if(this.get_u32("defend") > 0){
		this.set_u32("defend",this.get_u32("defend")-1);
	}	
  
  if(this.get_string("sword") == "bladeoflight" && this.get_u32("healcooldown") > 0)
  {
    this.set_u32("healcooldown", this.get_u32("healcooldown") - 1);
  }
  else if(this.get_string("sword") == "bladeoflight" && this.get_u32("healcooldown") <= 0)
  {
    this.set_u32("healcooldown", 600);
    this.server_Heal(1.0f);
  }
  
	/*
	CPlayer@ player = this.getPlayer();
	
	if(player !is null)
	{
		print("lvl: " + player.get_u8("nathanlvl"));
		if (player.get_u8("nathanlvl") == 0 && player.get_f32("nathanexp") > 6.0f)
		{
			client_AddToChat("Leveled up to Level 2! New Ability: CHARGE", SColor(255, 125, 0, 0));
			player.set_u8("nathanlvl", 1);
			this.set_u8("nathanlvl", 1);
			player.set_f32("nathanexp", 0.0f);
		}
		else if (player.get_u8("nathanlvl") == 1 && player.get_f32("nathanexp") > 200.0f)
		{
			client_AddToChat("Leveled up to Level 3! New Ability: Back up", SColor(255, 125, 0, 0));
			player.set_u8("nathanlvl", 2);
			this.set_u8("nathanlvl", 2);
			player.set_f32("nathanexp", -1.0f);
		}
	}*/
	
	if(this.getName() == "knight")
	{
		if(this.get_string("sword") == "woodenblade")
		{
			this.set_f32("dmgmult",1.1f);
		}
		else if(this.get_string("sword") == "stoneblade")
		{
			this.set_f32("dmgmult",1.25f);
		}
		else if(this.get_string("sword") == "ironblade")
		{
			this.set_f32("dmgmult",1.5f);
		}
		else if(this.get_string("sword") == "mithrilblade")
		{
			this.set_f32("dmgmult",1.75f);
		}
		else if(this.get_string("sword") == "platiumblade")
		{
			this.set_f32("dmgmult",2.0f);
		}
		else if(this.get_string("sword") == "bladeofundead")
		{
			this.set_f32("dmgmult",2.0f);
		}
		else if(this.get_string("sword") == "bladeoflight")
		{
			this.set_f32("dmgmult",1.75f);
		}
		else if(this.get_string("sword") == "shadowblade")
		{
			this.set_f32("dmgmult",1.7f);
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor *= 1.2f;
			}
		}
		else if(this.get_string("sword") == "hammer")
		{
			this.set_f32("dmgmult",0.5f);
		}
		else if(this.get_string("sword") == "greed")
		{
			this.set_f32("dmgmult",2.0f);
		}
		else if(this.get_string("sword") == "thefailedwhistle")
		{
			this.set_f32("dmgmult",1.2f);
		}
		else if(this.get_string("sword") == "greatblade")
		{
			this.set_f32("dmgmult",3.0f);
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor *= 0.5f;
			}
		}
		
	}
	if(this.getName() == "knight" || this.getName() == "builder")
	{
		if(this.get_string("armor") == "tunic")
		{
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor *= 1.4f;
			}
		}
		else if(this.get_string("armor") == "TITAN")
		{
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor *= 0.65f;
			}
		}
	}
	if(this.getName() == "archer")
	{
		if(this.get_string("bow") == "woodenbow")
		{
			this.set_f32("dmgmult",1.1f);
		}
		else if(this.get_string("bow") == "stonebow")
		{
			this.set_f32("dmgmult",1.25f);
		}
		else if(this.get_string("bow") == "ironbow")
		{
			this.set_f32("dmgmult",1.5f);
		}
		else if(this.get_string("bow") == "mithrilbow")
		{
			this.set_f32("dmgmult",1.75f);
		}
		else if(this.get_string("bow") == "platiumbow")
		{
			this.set_f32("dmgmult",4.0f);
		}
    else if(this.get_string("bow") == "triplebow")
		{
			this.set_f32("dmgmult",1.5f);
      this.set_bool("trip",true);
		}
		
	}
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	
	if(dmg <= 0)return dmg;
	
	
	if(this.get_u32("defend") > 0){
		return dmg * 0.75f;
	}
	if(this.getName() == "knight" || this.getName() == "builder")
	{
		if(this.get_string("armor") == "woodenarmor")
		{
			dmg *= 0.9f;
		}
		else if(this.get_string("armor") == "stonearmor")
		{
			dmg *= 0.8f;
		}
		else if(this.get_string("armor") == "ironarmor")
		{
			dmg *= 0.7f;
		}
		else if(this.get_string("armor") == "mithrilarmor")
		{
			dmg *= 0.6f;
		}
		else if(this.get_string("armor") == "platiumarmor")
		{
			dmg *= 0.5f;
		}
		else if(this.get_string("armor") == "tunic")
		{
			dmg *= 2.0f;
		}
		else if(this.get_string("armor") == "TITAN")
		{
			dmg *= 0.25f;
		}
	}
	
	return dmg; 
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if(this.getName() == "knight")
	{
		if(this.get_string("sword") == "bladeofundead")
		{
			this.set_f32("zombiespawn",this.get_f32("zombiespawn") + 1.0f);
			if(this.get_f32("zombiespawn") > 5.0f )
			{
				CBlob@ skel2 = server_CreateBlob("skeleton");
				if(skel2 !is null)
				{
					skel2.server_setTeamNum(this.getTeamNum());
					skel2.setPosition(this.getPosition() + Vec2f(0.0f, -4.0f));
					skel2.server_SetTimeToDie(40);
				}
			
				this.set_f32("zombiespawn",0.0f);
			}
		}
		else if(this.get_string("sword") == "greed" && (hitBlob.getName() == "knight" || hitBlob.getName() == "builder" || hitBlob.getName() == "archer"))
		{
			CPlayer@ player = this.getPlayer();
			if(player !is null)
			{
				player.server_setCoins(player.getCoins() + 5);
			}
		}
		else if(this.get_string("sword") == "hammer")
		{
			SetKnocked(hitBlob, 40);
		}
	}
	
	return;
}

void onDie(CBlob@ this)
{
	if(this.getName() == "knight" && this.get_string("sword") != "")
	{
		CBlob@ weapon = server_CreateBlob(this.get_string("sword"), -1, this.getPosition());
	}
	if(this.getName() == "knight" && this.get_string("armor") != "")
	{
		CBlob@ weapon = server_CreateBlob(this.get_string("armor"), -1, this.getPosition());
	}
	if(this.getName() == "builder" && this.get_string("armor") != "")
	{
		CBlob@ weapon = server_CreateBlob(this.get_string("armor"), -1, this.getPosition());
	}
	if(this.getName() == "archer" && this.get_string("bow") != "")
	{
		CBlob@ weapon = server_CreateBlob(this.get_string("bow"), -1, this.getPosition());
	}
}





