#include "RunnerCommon.as"
#include "Hitters.as"
#include "Knocked.as"

void onInit(CPlayer@ this)
{
	
	this.set_u8("nathanlvl",1);
	this.set_f32("nathanexp",1);


}
void onTick(CBlob@ this)
{
	
	
	RunnerMoveVars@ moveVars;
	/*if(this.get("moveVars", @moveVars))
	{
		moveVars.jumpFactor = 1.0f;
	}*/
	if(this.get_u32("charge") > 0){
		
		if(this.get("moveVars", @moveVars))
		{
			//print("bah");
			moveVars.walkFactor *= 2.0f;
			moveVars.jumpFactor *= 2.0f;
		}
		this.set_u32("charge",this.get_u32("charge")-1);
	}	
	if(this.get_u32("defend") > 0){
		this.set_u32("defend",this.get_u32("defend")-1);
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
	
	if((this.getName() == "nathan" || this.getName() == "oz"))
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
		else if(this.get_string("sword") == "greatblade")
		{
			this.set_f32("dmgmult",3.0f);
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor *= 0.5f;
			}
		}
		
	}
	if(((this.getName() == "nathan" || this.getName() == "oz") || (this.getName() == "payton" || this.getName() == "molly")))
	{
		if(this.get_string("armor") == "tunic")
		{
			if(this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor *= 1.4f;
			}
		}
	}
	if(this.getName() == "brennan")
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
			this.set_f32("dmgmult",2.0f);
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
	if(((this.getName() == "nathan" || this.getName() == "oz") || (this.getName() == "payton" || this.getName() == "molly")))
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
			if(this.get_f32("zombiespawn") > 10.0f )
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
		else if(this.get_string("sword") == "bladeoflight")
		{
			this.server_Heal(0.25f);
		}
		else if(this.get_string("sword") == "greed")
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

void onInit(CSprite@ this)
{
	
	{
		this.RemoveSpriteLayer("charge");
		CSpriteLayer@ effect = this.addSpriteLayer("charge", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (effect !is null)
		{
			
			Animation@ anim = effect.addAnimation("default", 0, false);
			anim.AddFrame(0);
			effect.SetOffset(Vec2f(0,0));
			effect.SetAnimation("default");
			effect.SetVisible(false);
			effect.SetRelativeZ(4.0f);
		}
	}
	{
		this.RemoveSpriteLayer("defend");
		CSpriteLayer@ effect = this.addSpriteLayer("defend", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (effect !is null)
		{
			
			Animation@ anim = effect.addAnimation("default", 0, false);
			anim.AddFrame(4);
			effect.SetOffset(Vec2f(0,0));
			effect.SetAnimation("default");
			effect.SetVisible(false);
			effect.SetRelativeZ(4.0f);
		}
	}
	
}

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	this.getSpriteLayer("charge").SetVisible(false);
	if(blob.get_u32("charge") > 0)
	{
		this.getSpriteLayer("charge").SetVisible(true);
	}
		
	this.getSpriteLayer("defend").SetVisible(false);	
	if(blob.get_u32("defend") > 0)
	{	
		this.getSpriteLayer("defend").SetVisible(true);
	}
	
} 

void onDie(CBlob@ this)
{
	if((this.getName() == "nathan" || this.getName() == "oz") && this.get_string("sword") != "")
	{
		CBlob@ weapon = server_CreateBlob(this.get_string("sword"), -1, this.getPosition());
	}
	if((this.getName() == "nathan" || this.getName() == "oz") && this.get_string("armor") != "")
	{
		CBlob@ weapon = server_CreateBlob(this.get_string("armor"), -1, this.getPosition());
	}
	if((this.getName() == "molly" || this.getName() == "payton") && this.get_string("armor") != "")
	{
		CBlob@ weapon = server_CreateBlob(this.get_string("armor"), -1, this.getPosition());
	}
	if(this.getName() == "brennan" && this.get_string("bow") != "")
	{
		CBlob@ weapon = server_CreateBlob(this.get_string("bow"), -1, this.getPosition());
	}
}




