// Kagician logic

#include "Hitters.as";
#include "MagicalHitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "MagicCommon.as";

void onInit(CBlob@ this)
{

	this.Tag("player");
	this.Tag("flesh");


	CShape@ shape = this.getShape();


	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	if(getNet().isServer())
	{
		string[] scripts;
		scripts.push_back("Gravity");
		scripts.push_back("Bounce");
		scripts.push_back("Harm");
		this.set("scripts", scripts);
	}
	this.set_u16("charge", 0); //The amount of time the spell has been charged.
	this.set_u8("firestyle", 0); //Style of shooting spells.
	this.set_u8("stylepower", 0);//Strength of fire style's attack.
	this.set_u8("abilityindex", 255);
	this.getSprite().SetEmitSound("/WaterSparkle.ogg");
	this.addCommandID("scale");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}



void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	moveVars.walkFactor *= 0.7f;
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	// activate/throw
	if(ismyplayer)
	{

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
	CSprite@ sprite = this.getSprite();
	Vec2f vel = this.getVelocity();
	int charge = this.get_u16("charge");
	u8 firestyle = this.get_u8("firestyle");
	u8 stylepower = this.get_u8("stylepower");
	
	bool action2 = this.isKeyPressed(key_action2);
	bool action1 = this.isKeyPressed(key_action1);
	if(this.isKeyJustPressed(key_action2))
	{
		sprite.SetEmitSoundPaused(false);
	}
	if(action2)
	{
		charge = Maths::Min(getChargeMax(firestyle, stylepower), charge + 1);
		sprite.SetEmitSoundSpeed((charge / 200.0f));
	}
	else if(action1)
	{
		charge = Maths::Min(400, charge + 1);
	}
	
	if(this.isKeyJustReleased(key_action2))
	{
		sprite.SetEmitSoundPaused(true);
		Vec2f pos = Vec2f(0, 0); //Pos to summon stuff.
		Vec2f aimpos = Vec2f(0, 0); //Hack to make FireStyles Work, set to anything other than 0
		
		switch(firestyle)
		{
			case FireStyle::Plain:
			break;
			case FireStyle::Rapid:
				if(stylepower >= 1)
				{
					charge *= 6.0f;
				}
				else
				{
					charge *= 4.0f;
				}
			break;
			case FireStyle::SkySummon:
				if(!getMap().rayCastSolid(this.getPosition(), Vec2f(this.getPosition().x, 0)))
				{
					pos = Vec2f(this.getAimPos().x, 1);
				}
				else
				{
					pos = Vec2f(this.getPosition().x, 1);
				}
			break;
			case FireStyle::SpreadShot:
				charge /= 0.8f * (stylepower + 1);
			break;
			case FireStyle::Eruption:
				getMap().rayCastSolid(this.getPosition(), this.getAimPos(), pos);
			break;
		}
		//DO THA MAGIC
		if(canCast(this)) // Cast the spell.
		{
			sprite.PlaySound("OrbFireSound.ogg", charge / 30.0f, Maths::Clamp(1 / (charge / 120.0f), 0.8f, 4.53f));
			if(pos.y == 0) //If it's not already been set.
			{
				pos = this.getPosition();
				aimpos = this.getAimPos() - pos;
				aimpos.Normalize();
				aimpos *= 9 * (Maths::Min(charge / 55.0f, 3.1f));
				if(vel.Length() > 4)
				{
					aimpos += vel / 4;
				}
			}
			
			if(getNet().isServer())
			{
				if(firestyle == FireStyle::SpreadShot)
				{
					aimpos.RotateBy(-8, Vec2f());
					for(int i = 0; i < 3; i++)
					{
						ShootSpell(this, pos, aimpos, charge, firestyle);
						aimpos.RotateBy(8, Vec2f());
					}
					if(stylepower >= 1)
					{
						aimpos /= 1.5f;
						aimpos.RotateBy(-8, Vec2f());
						for(int i = 0; i < 3; i++)
						{
							ShootSpell(this, pos, aimpos, charge, firestyle);
							aimpos.RotateBy(-8, Vec2f());
						}
						if(stylepower >= 2) //derp ;D
						{
							aimpos *= 2.1f;
							aimpos.RotateBy(8, Vec2f());
							for(int i = 0; i < 3; i++)
							{
								ShootSpell(this, pos, aimpos, charge, firestyle);
								aimpos.RotateBy(8, Vec2f());
							}
						}
					}
				}
				else if(firestyle == FireStyle::SkySummon && stylepower >= 1)
				{
					int num = stylepower * 2;
					num = stylepower * stylepower;
					num *= 2;
					num += 1;
					//print("Num: " + num);
					pos.x -= 20.0f * (num / 2);
					for(int i = 0; i < (num); i++) //So that its always an odd number
					{
						ShootSpell(this, pos, aimpos, charge, firestyle);
						pos.x += 20;
						pos.y = (XORRandom(num * 5.0f));
					}
				}
				else if(firestyle == FireStyle::Eruption)
				{
					int num = (stylepower + 1) * 3;
					aimpos = Vec2f(0, -9);
					aimpos.RotateBy(((-num + 1)/ 2.0f) * 10.0f, Vec2f());
					for(int i = 0; i < num; i++)
					{
						ShootSpell(this, pos, aimpos, charge, firestyle);
						aimpos.RotateBy(10, Vec2f());
					}
				}
				else
				{
					ShootSpell(this, pos, aimpos, charge, firestyle);	
				}
			}
		}
		else
		{
			charge += 1; //prevent divide by 0
			sprite.PlaySound("OrbExplosion.ogg", charge / 30.0f, Maths::Clamp(1 / (charge / 120.0f), 0.8f, 4.53f));
		}
		charge = 0;
	}

	if(action1)
	{
		//action1
		int abilityindex = this.get_u8("abilityindex");
		if(abilityindex != 255 && charge >= minAbilityCharges[abilityindex])
		{
			Vec2f pos = this.getPosition();
			Vec2f extravel = this.getAimPos() - pos;
			Vec2f vel = this.getVelocity();
			extravel.Normalize();
					extravel *= 6;
					this.setVelocity(this.getVelocity() + extravel);
					charge -= 50;
			switch(this.get_u8("abilityindex"))
			{
				
				case Ability::Leap:
					
				break;
				case Ability::Regenerate:
					if(getNet().isServer())
					{
						this.server_Heal(0.2f);
						//TODO: particles here
					}
					if(getNet().isClient())
					{
						ParticleAnimated(CFileMatcher("HeartAnim.png").getFirst(), pos, Vec2f(XORRandom(3) - 1, 0), 0, 0.5f, 20, -0.1f, false);
					}
					print("greh");
					charge -= 20;
				break;
				case Ability::Glide:
					if(vel.y > 3)
					{
						this.setVelocity(Vec2f(vel.x, vel.y / 1.3f));
					}
				break;
			}
		}
	}
	if(this.isKeyJustReleased(key_action1))
	{
		charge = 0;
	}
	this.set_u16("charge", charge);	
}
void ShootSpell(CBlob@ this, Vec2f pos, Vec2f aimpos, u16 charge, u8 firestyle)
{
	CBlob@ spell = server_CreateBlob("spell", this.getTeamNum(), pos);
	if(spell !is null)
	{
		spell.setVelocity(aimpos);
		CSprite@ spr = spell.getSprite();
		string[] scripts;
		this.get("scripts", scripts);
		for(int i = 0; i < scripts.length; i++)
		{
			string scriptname = (scripts[i]);
			if(scriptname == "Necromance")
			{
				this.server_Hit(this, this.getPosition(), aimpos, charge / 60.0f, MagicalHitters::Magic);
				charge = Maths::Min(charge * 2, 255);
			}
			spell.set_u16("ownerID", this.getNetworkID());
			scriptname += ".as";
			//print("Script Name: " + scriptname);
			spell.AddScript(scriptname);
		}
		spell.set_u16("charge", charge);
		spell.SetFacingLeft(this.isFacingLeft());
		//-- scale the blob client side --
		CBitStream params;
		params.write_u16(spell.getNetworkID());
		this.SendCommand(this.getCommandID("scale"), params);
		
		
		
	}
}

void onHit(CBlob@ this) //Reset charge if user was pressing key_action1.
{
	if(this.isKeyPressed(key_action1))
	{
		this.set_u16("charge", 0);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("scale"))
    {
		CBlob@ spell = getBlobByNetworkID(params.read_u16());
		u16 charge = spell.get_u16("charge");
		if(spell !is null)
		{
			f32 scale = charge;
			scale += 40;
			scale /= 200.0f;
			scale = Maths::Min(scale, 1.5f);
			spell.getSprite().ScaleBy(Vec2f(scale, scale));
		}
	}
}