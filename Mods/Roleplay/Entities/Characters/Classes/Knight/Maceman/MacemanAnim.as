// Knight animations

#include "RP_Races.as";

#include "EquipmentCommon.as";

#include "MacemanCommon.as";
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

const string sword_layer = "sword layer";
const string shiny_layer = "shiny bit";

void onInit( CSprite@ this )
{
	string texname = this.getBlob().getSexNum() == 0 ?
					 "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightMaleCopper.png" :
                     "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightFemaleCopper.png";
	
	const string armour = getEquipmentSlotItem(this.getBlob(), SLOT_ARMOUR);
	
	if(this.getBlob().getTeamNum() == RACE_HUMANS || this.getBlob().getTeamNum() == RACE_ANGELS)
	{
		if(armour == "iron_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightMaleIron.png" :
                      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightFemaleIron.png";
		else if(armour == "gold_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightMaleGold.png" :
                      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightFemaleGold.png";
		else if(armour == "steel_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightMaleSteel.png" :
                      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightFemaleSteel.png";
		else if(armour == "mythril_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightMaleMythril.png" :
                      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightFemaleMythril.png";
		else if(armour == "adamant_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightMaleAdamant.png" :
                      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/HumanKnightFemaleAdamant.png";
		else if(armour == "dragon_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/KnightDragon.png" :
                      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/KnightDragon.png";
	}
	else if(this.getBlob().getTeamNum() == RACE_DWARVES)
	{
	    if(armour == "default_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightMaleCopper.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightFemaleCopper.png";
		else if(armour == "iron_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightMaleIron.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightFemaleIron.png";
		else if(armour == "gold_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightMaleGold.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightFemaleGold.png";
		else if(armour == "steel_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightMaleSteel.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightFemaleSteel.png";
		else if(armour == "mythril_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightMaleMythril.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightFemaleMythril.png";
		else if(armour == "adamant_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightMaleAdamant.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/DwarfKnightFemaleAdamant.png";
		else if(armour == "dragon_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/KnightDragon.png" :
                      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/KnightDragon.png";
	}
	else if(this.getBlob().getTeamNum() == RACE_ELVES)
	{
	    if(armour == "default_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightMaleCopper.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightFemaleCopper.png";
		else if(armour == "iron_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightMaleIron.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightFemaleIron.png";
		else if(armour == "gold_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightMaleGold.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightFemaleGold.png";
		else if(armour == "steel_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightMaleSteel.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightFemaleSteel.png";
		else if(armour == "mythril_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightMaleMythril.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightFemaleMythril.png";
		else if(armour == "adamant_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightMaleAdamant.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/ElfKnightFemaleAdamant.png";
		else if(armour == "dragon_chestplate")
			texname = "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/KnightDragon.png";
	}
	else if(this.getBlob().getTeamNum() == RACE_ORCS)
	{
	    if(armour == "default_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightMaleCopper.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightFemaleCopper.png";
		else if(armour == "iron_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightMaleIron.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightFemaleIron.png";
		else if(armour == "gold_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightMaleGold.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightFemaleGold.png";
		else if(armour == "steel_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightMaleSteel.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightFemaleSteel.png";
		else if(armour == "mythril_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightMaleMythril.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightFemaleMythril.png";
		else if(armour == "adamant_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightMaleAdamant.png" :
                  	  "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/OrcKnightFemaleAdamant.png";
		else if(armour == "dragon_chestplate")
			texname = this.getBlob().getSexNum() == 0 ?
				      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/KnightDragon.png" :
                      "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/KnightDragon.png";
	}
	else if(this.getBlob().getTeamNum() == RACE_UNDEAD)
	{
	    if(armour == "default_chestplate")
			texname = "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/UndeadKnightCopper.png";
		else if(armour == "iron_chestplate")
			texname = "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/UndeadKnightIron.png";
		else if(armour == "gold_chestplate")
			texname = "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/UndeadKnightGold.png";
		else if(armour == "steel_chestplate")
			texname = "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/UndeadKnightSteel.png";
		else if(armour == "mythril_chestplate")
			texname = "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/UndeadKnightMythril.png";
		else if(armour == "adamant_chestplate")
			texname = "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/UndeadKnightAdamant.png";
		else if(armour == "dragon_chestplate")
			texname = "../Mods/Roleplay/Entities/Characters/Classes/Knight/Swordsman/Sprites/KnightDragon.png";
	}
	
	this.ReloadSprite( texname, this.getConsts().frameWidth, this.getConsts().frameHeight,
						this.getBlob().getTeamNum(), this.getBlob().getSkinNum() );
	
	// add sword
	const string sword_item = getEquipmentSlotItem(this.getBlob(), SLOT_WEAPON);
	const string sword_sprite = "../Mods/Roleplay/Entities/Items/Roleplay/Weapons/Knight/MaceLayer.png";
	
	this.RemoveSpriteLayer(sword_layer);
	CSpriteLayer@ sword = this.addSpriteLayer( sword_layer, sword_sprite, 32, 32 );
	
	if (sword !is null)
	{
	    {
		    Animation@ anim = sword.addAnimation( "default", 0, true );

            for (int i = 0; i < 62; i++) {
                anim.AddFrame(i);
            }
        }
		sword.SetOffset(Vec2f(0.0f, -4.0f));
		sword.SetVisible(true);
		sword.SetRelativeZ(1.0f);
	}			
	
	// mid-air slash effect
	this.RemoveSpriteLayer("chop");
	CSpriteLayer@ chop = this.addSpriteLayer( "chop", sword_sprite, 32, 32 );

	if (chop !is null)
	{
		Animation@ anim = chop.addAnimation( "default", 0, true );
		anim.AddFrame(35);
		anim.AddFrame(43);
		chop.SetVisible(false);
	}
	
	// add shiny
	this.RemoveSpriteLayer(shiny_layer);
	CSpriteLayer@ shiny = this.addSpriteLayer( shiny_layer, "AnimeShiny.png", 16, 16 );

	if (shiny !is null)
	{
		Animation@ anim = shiny.addAnimation( "default", 2, true );
		int[] frames = {0,1,2,3};
		anim.AddFrames(frames);
		shiny.SetVisible(false);
		shiny.SetRelativeZ(1.0f);
	}
}

void onTick( CSprite@ this )
{
    // store some vars for ease and speed
    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f aimpos;

	KnightInfo@ knight;
	if (!blob.get("knightInfo", @knight)) {
        return;
    }

    const u8 knocked = getKnocked(blob);
	
	bool shieldState = isShieldState(knight.state);
	bool specialShieldState = isSpecialShieldState(knight.state);
	bool swordState = isSwordState(knight.state);

	bool pressed_a1 = blob.isKeyPressed(key_action1);
	bool pressed_a2 = blob.isKeyPressed(key_action2);

	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));

    aimpos = blob.getAimPos();
    bool inair = (!blob.isOnGround() && !blob.isOnLadder());

	Vec2f vel = blob.getVelocity();

    if (blob.hasTag("dead"))
    {
		if(this.animation.name != "dead")
		{
			this.RemoveSpriteLayer(sword_layer);
			this.RemoveSpriteLayer(shiny_layer);
			this.SetAnimation("dead");
		}
        Vec2f oldvel = blob.getOldVelocity();

        //TODO: trigger frame one the first time we server_Die()()
        if (vel.y < -1.0f) {
            this.SetFrameIndex( 1 );
        }
        else if (vel.y > 1.0f) {
            this.SetFrameIndex( 3 );
        }
        else {
            this.SetFrameIndex( 2 );
        }

        CSpriteLayer@ chop = this.getSpriteLayer( "chop" );

        if (chop !is null)
        {
            chop.SetVisible(false);
        }

        return;
    }

    // get the angle of aiming with mouse
    Vec2f vec;
	int direction = blob.getAimDirection(vec);

    // set facing
    bool facingLeft = this.isFacingLeft();
    // animations
    bool ended = this.isAnimationEnded() || this.isAnimation("shield_raised");
    bool wantsChopLayer = false;
    s32 chopframe = 0;

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);

	bool shinydot = false;

	if (knocked > 0)
    {
        if (inair) {
            this.SetAnimation("knocked_air");
        }
        else {
            this.SetAnimation("knocked");
        }
    }
    else if (blob.hasTag( "seated" ))
    {
        this.SetAnimation("crouch");
    }
    else if (knight.state == KnightStates::shieldgliding)
    {
        this.SetAnimation("shield_glide");
    }
    else if (knight.state == KnightStates::shielddropping)
    {
        this.SetAnimation("shield_drop");
    }
    else if (knight.state == KnightStates::shielding)
    {
        if (walking)
        {
            if (direction == 0)
            {
                this.SetAnimation("shield_run");
            }
            else if (direction == -1)
            {
                this.SetAnimation("shield_run_up");
            }
            else if (direction == 1)
            {
                this.SetAnimation("shield_run_down");
            }
        }
        else
        {
            this.SetAnimation("shield_raised");

            if (direction == 1) {
                this.animation.frame = 2;
            }
            else if (direction == -1)
            {
                if (vec.y > -0.97) {
                    this.animation.frame = 1;
                }
                else {
                    this.animation.frame = 3;
                }
            }
            else {
                this.animation.frame = 0;
            }
        }
    }
    else if (knight.state == KnightStates::sword_drawn)
    {
		if (knight.swordTimer < KnightVars::slash_charge) {
            this.SetAnimation("draw_sword");
        }
        else if (knight.swordTimer < KnightVars::slash_charge_level2) {
            this.SetAnimation("strike_power_ready");
            this.animation.frame = 0;
        }
		else if (knight.swordTimer < KnightVars::slash_charge_limit) {
			this.SetAnimation("strike_power_ready");
			this.animation.frame = 1;
			shinydot = true;
		}
        else {
            this.SetAnimation("draw_sword");
        }
    }
    else if (knight.state == KnightStates::sword_cut_mid)
    {
        this.SetAnimation("strike_mid");
    }
    else if (knight.state == KnightStates::sword_cut_mid_down)
    {
        this.SetAnimation("strike_mid_down");
    }
    else if (knight.state == KnightStates::sword_cut_up)
    {
        this.SetAnimation("strike_up");
    }
    else if (knight.state == KnightStates::sword_cut_down)
    {
        this.SetAnimation("strike_down");
    }
    else if (knight.state == KnightStates::sword_power || knight.state == KnightStates::sword_power_super)
    {
        this.SetAnimation("strike_power");
		
		if(knight.swordTimer <= 1)
			this.animation.SetFrameIndex(0);

        if (knight.swordTimer >= 6 && knight.swordTimer < 8)
        {
            wantsChopLayer = true;
            chopframe = 0;
        }
    }
    else if (inair)
    {
		RunnerMoveVars@ moveVars;
		if (!blob.get( "moveVars", @moveVars )) {
			return;
		}
		f32 vy = vel.y;
		if (vy < -0.0f && moveVars.walljumped)
		{
			this.SetAnimation("run");
		}
		else
		{
			this.SetAnimation("fall");
			this.animation.timer = 0;

			if (vy < -1.5 ) {
				this.animation.frame = 0;
			}
			else if (vy > 1.5 ) {
				this.animation.frame = 2;
			}
			else {
				this.animation.frame = 1;
			}
		}
    }
    else if (walking ||
             (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down)) ) ) {
        this.SetAnimation("run");
    }
	else
    {
		defaultIdleAnim(this, blob, direction);
    }
	
	
    CSpriteLayer@ sword = this.getSpriteLayer( sword_layer );
	
	if(sword !is null)
	{
	    // mirror the animations
		sword.animation.frame = this.getFrame();
		sword.SetVisible(this.isVisible());
	}

    CSpriteLayer@ chop = this.getSpriteLayer( "chop" );

    if (chop !is null)
    {
        chop.animation.frame = chopframe;
        chop.SetVisible(wantsChopLayer);
    }
    
    //set the shiny dot on the sword
    
    CSpriteLayer@ shiny = this.getSpriteLayer( shiny_layer );
    
    if(shiny !is null)
    {
		shiny.SetVisible(shinydot);
		if(shinydot)
		{
			f32 range = (KnightVars::slash_charge_limit - KnightVars::slash_charge_level2);
			f32 count = (knight.swordTimer - KnightVars::slash_charge_level2);
			f32 ratio = count / range;
			shiny.RotateBy(10, Vec2f());
			shiny.SetOffset(Vec2f(12,-2 + ratio * 8));
		}
	}
    
    //set the head anim
    if (knocked > 0)
    {
		blob.Tag("dead head");
	}
    else if (blob.isKeyPressed(key_action1))
    {
        blob.Tag("attack head");
        blob.Untag("dead head");
    }
    else
    {
        blob.Untag("attack head");
        blob.Untag("dead head");
    }
    
}

void onGib(CSprite@ this)
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()),2.0f) + 1.0f;
	const u8 team = blob.getTeamNum();
    CParticle@ Body     = makeGibParticle( "Entities/Characters/Knight/KnightGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 0, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm      = makeGibParticle( "Entities/Characters/Knight/KnightGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "Entities/Characters/Knight/KnightGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 2, 0, Vec2f (16,16), 2.0f, 0, "Sounds/material_drop.ogg", team );
    CParticle@ Sword    = makeGibParticle( "Entities/Characters/Knight/KnightGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ), 3, 0, Vec2f (16,16), 2.0f, 0, "Sounds/material_drop.ogg", team );
}


// render cursors

void DrawCursorAt( Vec2f pos, string& in filename )
{
	Vec2f aligned = getDriver().getScreenPosFromWorldPos( getMap().getAlignedWorldPos( pos ) );
	GUI::DrawIcon( filename, aligned, getCamera().targetDistance * getDriver().getResolutionScaleFactor() );
}

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer()) {
		return;			      }					  
	if (getHUD().hasButtons()) {
		return;
	}

	// draw tile cursor

	if (blob.isKeyPressed(key_action1))
	{
		CMap@ map = blob.getMap();
		Vec2f pos = blob.getPosition();
		Vec2f vector = blob.getAimPos() - pos;
		f32 aimLength = vector.getLength();				   
		if (aimLength < 16.0f )
		{
			
			DrawCursorAt( pos + vector, cursorTexture );
		}
	}
}
