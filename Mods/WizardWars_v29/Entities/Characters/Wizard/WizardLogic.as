// Wizard logic

#include "WizardCommon.as"
#include "HotbarCommon.as"
#include "MagicCommon.as";
#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";
#include "SpellCommon.as";

void onInit( CBlob@ this )
{
	WizardInfo wizard;
	this.set("wizardInfo", @wizard);
	
	ManaInfo manaInfo;
	manaInfo.maxMana = MAX_MANA;
	manaInfo.manaRegen = MANA_REGEN;
	this.set("manaInfo", @manaInfo);

	this.set_s8( "charge_time", 0 );
	this.set_u8( "charge_state", WizardParams::not_aiming );
	this.set_s32( "mana", 100 );
	this.set_f32("gib health", -3.0f);
	this.set_Vec2f("spell blocked pos", Vec2f(0.0f, 0.0f));
	this.set_bool("casting", false);
	
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("ignore crouch");
	
	this.push("names to activate", "keg");
	this.push("names to activate", "nuke");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
    this.addCommandID( "pick spell");
    this.addCommandID( "spell");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

    AddIconToken( "$Skeleton$", "SpellIcons.png", Vec2f(16,16), 0 );
    AddIconToken( "$Zombie$", "SpellIcons.png", Vec2f(16,16), 1 );
    AddIconToken( "$Wraith$", "SpellIcons.png", Vec2f(16,16), 2 );
    AddIconToken( "$Greg$", "SpellIcons.png", Vec2f(16,16), 3 );
    AddIconToken( "$ZK$", "SpellIcons.png", Vec2f(16,16), 4 );
    AddIconToken( "$Orb$", "SpellIcons.png", Vec2f(16,16), 5 );
    AddIconToken( "$ZombieRain$", "SpellIcons.png", Vec2f(16,16), 6 );
    AddIconToken( "$Teleport$", "SpellIcons.png", Vec2f(16,16), 7 );
    AddIconToken( "$MeteorRain$", "SpellIcons.png", Vec2f(16,16), 8 );
    AddIconToken( "$SkeletonRain$", "SpellIcons.png", Vec2f(16,16), 9 );
	AddIconToken( "$Firebomb$", "SpellIcons.png", Vec2f(16,16), 10 );
	AddIconToken( "$FireSprite$", "SpellIcons.png", Vec2f(16,16), 11 );
	AddIconToken( "$FrostBall$", "SpellIcons.png", Vec2f(16,16), 12 );
	AddIconToken( "$Heal$", "SpellIcons.png", Vec2f(16,16), 13 );
	AddIconToken( "$Revive$", "SpellIcons.png", Vec2f(16,16), 14 );
	AddIconToken( "$CounterSpell$", "SpellIcons.png", Vec2f(16,16), 15 );
	AddIconToken( "$MagicMissile$", "SpellIcons.png", Vec2f(16,16), 16 );
	
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath);
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer( CBlob@ this, CPlayer@ player )
{
	if (player !is null){
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16,16));
	}
}

void ManageSpell( CBlob@ this, WizardInfo@ wizard, HotbarInfo@ hotbarInfo, RunnerMoveVars@ moveVars )
{
	CSprite@ sprite = this.getSprite();
	bool ismyplayer = this.isMyPlayer();
	s32 charge_time = wizard.charge_time;
	u8 charge_state = wizard.charge_state;
	Vec2f pos = this.getPosition();
    Vec2f aimpos = this.getAimPos();
	Vec2f aimVec = aimpos - pos;
	Vec2f normal = aimVec;
	normal.Normalize();
	
	Spell spell = WizardParams::spells[hotbarInfo.primarySpellID];
	
	ManaInfo@ manaInfo;
	if (!this.get( "manaInfo", @manaInfo )) 
	{
		return;
	}	
    s32 wizMana = manaInfo.mana;

    bool is_pressed = this.isKeyPressed( key_action1 );
    bool just_pressed = this.isKeyJustPressed( key_action1 );
    bool just_released = this.isKeyJustReleased( key_action1 );

    bool is_secondary = false;
	bool is_aux1 = false;
	
    if (!is_pressed and !just_released and !just_pressed)//secondary hand
    {
        spell = WizardParams::spells[hotbarInfo.secondarySpellID];

        is_pressed = this.isKeyPressed( key_action2 );
        just_pressed = this.isKeyJustPressed( key_action2 );
        just_released = this.isKeyJustReleased( key_action2 );

        is_secondary = true;
    }
    if (!is_pressed and !just_released and !just_pressed)//auxiliary1 hand
    {
        spell = WizardParams::spells[hotbarInfo.aux1SpellID];
		
		CControls@ controls = this.getControls();
        is_pressed = this.isKeyPressed( key_action3 );
        just_pressed = this.isKeyJustPressed( key_action3 );
        just_released = this.isKeyJustReleased( key_action3 ); 

        is_aux1 = true;
    }
	
	Vec2f tilepos = pos + normal * Maths::Min(aimVec.Length() - 1, spell.range);
	Vec2f surfacepos;
	CMap@ map = this.getMap();
	bool aimPosBlocked = map.rayCastSolid(pos, tilepos, surfacepos);
	Vec2f spellPos = surfacepos - normal*8.0f; 
	
	//Are we casting? 
	if ( is_pressed )
	{
		this.set_bool("casting", true);
		this.set_Vec2f("spell blocked pos", spellPos);
	}
	else
		this.set_bool("casting", false);

    // info about spell
    s32 readyTime = spell.readyTime;
    u8 spellType = spell.type;

    if (just_pressed)
    {
        charge_time = 0;
        charge_state = 0;
    }
    if (is_pressed && wizMana >= spell.mana) 
    {
        moveVars.walkFactor *= 0.75f;
        charge_time += 1;
        if (charge_time >= spell.full_cast_period)
        {
            charge_state = WizardParams::extra_ready;
            charge_time = spell.full_cast_period;
        }
        else if (charge_time >= spell.cast_period)
        {
            charge_state = WizardParams::cast_3;
        }
        else if (charge_time >= spell.cast_period_2)
        {
            charge_state = WizardParams::cast_2;
        }
        else if (charge_time >= spell.cast_period_1)
        {
            charge_state = WizardParams::cast_1;
        }
    }
    else if (getControls().isKeyJustPressed( KEY_KEY_U )) // teleport using u
    {
        spell = WizardParams::spells[1];
        charge_state = WizardParams::cast_3;
        if (wizMana >= spell.mana && (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot()))
        {
            CBitStream params;
            params.write_u8(charge_state);
            params.write_u8(1);
            params.write_Vec2f(spellPos);
            this.SendCommand(this.getCommandID("spell"), params);
            SetKnocked( this, 5 );
        }
    }
    else if (just_released)
    {
        if (wizMana >= spell.mana && charge_state > WizardParams::charging && not (spell.needs_full && charge_state < WizardParams::cast_3) &&
            (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot()))
        {
            CBitStream params;
            params.write_u8(charge_state);
			u8 castSpellID;
			if ( is_aux1 )
				castSpellID = hotbarInfo.aux1SpellID;
			else if ( is_secondary )
				castSpellID = hotbarInfo.secondarySpellID;
			else
				castSpellID = hotbarInfo.primarySpellID;
            params.write_u8(castSpellID);
            params.write_Vec2f(spellPos);
            this.SendCommand(this.getCommandID("spell"), params);
        }
        charge_state = WizardParams::not_aiming;
        charge_time = 0;
    }

    wizard.charge_time = charge_time;
    wizard.charge_state = charge_state;

    if ( ismyplayer )
    {
		if (!getHUD().hasButtons()) 
		{
			int frame = 0;
            if (charge_state == WizardParams::extra_ready) {
                frame = 15;
            }
            else if (wizard.charge_time > spell.cast_period)
            {
                frame = 12 + wizard.charge_time % 15 / 5;
            }
			else if (wizard.charge_time > 0) {
				frame = wizard.charge_time * 12 /spell.cast_period; 
			}
			getHUD().SetCursorFrame( frame );
		}

        if (this.isKeyJustPressed(key_action3))
        {
			client_SendThrowOrActivateCommand( this );
        }
    }
	
	//cancel charging
	if ( this.isKeyJustPressed( key_action1 ) || this.isKeyJustPressed( key_action2 ) )
	{
		// cancel charging
		if (charge_state != WizardParams::not_aiming)
		{
			charge_state = WizardParams::not_aiming;
			wizard.charge_time = 0;
			sprite.SetEmitSoundPaused(true);
			sprite.PlaySound("PopIn.ogg", 1.0f, 1.0f);
		}
	}
	
	CControls@ controls = getControls();
	if ( !is_pressed )
	{
		if (WizardParams::spells.length == 0) {
			return;
		}

		WizardInfo@ wizard;
		if (!this.get( "wizardInfo", @wizard )) {
			return;
		}
		
		HotbarInfo@ hotbarInfo;
		if (!this.getPlayer().get( "hotbarInfo", @hotbarInfo )) 
		{
			return;
		}
		
		bool spellSelected = this.get_bool("spell selected");
		int currHotkey = hotbarInfo.primaryHotkeyID;
		int nextHotkey =  hotbarInfo.hotbarAssignments_Wizard.length;
		if ( controls.isKeyJustPressed(KEY_KEY_1) || controls.isKeyJustPressed(KEY_NUMPAD1) )
		{
			if ( (currHotkey == 0 || currHotkey == 5) && !spellSelected )
				nextHotkey = currHotkey + 5;
			else
				nextHotkey = 0;
		}
		else if ( controls.isKeyJustPressed(KEY_KEY_2) || controls.isKeyJustPressed(KEY_NUMPAD2) )
		{
			if ( (currHotkey == 1 || currHotkey == 6) && !spellSelected )
				nextHotkey = currHotkey + 5;
			else
				nextHotkey = 1;
		}
		else if ( controls.isKeyJustPressed(KEY_KEY_3) || controls.isKeyJustPressed(KEY_NUMPAD3))
		{
			if ( (currHotkey == 2 || currHotkey == 7) && !spellSelected )
				nextHotkey = currHotkey + 5;
			else
				nextHotkey = 2;
		}
		else if ( controls.isKeyJustPressed(KEY_KEY_4) || controls.isKeyJustPressed(KEY_NUMPAD4) )
		{
			if ( (currHotkey == 3 || currHotkey == 8) && !spellSelected )
				nextHotkey = currHotkey + 5;
			else
				nextHotkey = 3;
		}
		else if ( controls.isKeyJustPressed(KEY_KEY_5) || controls.isKeyJustPressed(KEY_NUMPAD5) )
		{
			if ( (currHotkey == 4 || currHotkey == 9) && !spellSelected )
				nextHotkey = currHotkey + 5;
			else
				nextHotkey = 4;
		}
		
		if ( nextHotkey <  hotbarInfo.hotbarAssignments_Wizard.length )
		{
			hotbarInfo.primaryHotkeyID = nextHotkey;
			hotbarInfo.primarySpellID = hotbarInfo.hotbarAssignments_Wizard[nextHotkey];
			this.set_bool("spell selected", false);
			
			sprite.PlaySound("PopIn.ogg");
		}
	}
	else
		this.set_bool("spell selected", true);
}

void onTick( CBlob@ this )
{
    WizardInfo@ wizard;
	if (!this.get( "wizardInfo", @wizard )) 
	{
		return;
	}
	
	CPlayer@ thisPlayer = this.getPlayer();
	if ( thisPlayer is null )
	{
		return;
	}
	
	HotbarInfo@ hotbarInfo;
	if (!thisPlayer.get( "hotbarInfo", @hotbarInfo )) 
	{
		return;
	}

	/*if(getKnocked(this) > 0)
	{
		wizard.charge_state = 0;
		wizard.charge_time = 0;
		return;
	}*/

    RunnerMoveVars@ moveVars;
    if (!this.get( "moveVars", @moveVars )) {
        return;
    }

	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;

	if (this.isInInventory()) return;

    ManageSpell( this, wizard, hotbarInfo, moveVars );
}

void SummonZombie(CBlob@ this, string name, Vec2f pos, int team)
{
    ParticleZombieLightning( pos );
    if (getNet().isServer())
	{
        CBlob@ summoned = server_CreateBlob( name, team, pos );
		if ( summoned !is null )
		{
			summoned.SetDamageOwnerPlayer( this.getPlayer() );
		}
	}
}

void CastSpell(CBlob@ this, const s8 charge_state, const Spell spell, Vec2f aimpos )
{
    const string spellName = spell.typeName;
    if (spell.type == SpellType::summoning)
    {
        Vec2f pos = aimpos + Vec2f(0.0f,-0.5f*this.getRadius());
        SummonZombie(this, spellName, pos, this.getTeamNum());
    }//summoning
    else if (spellName == "orb")
    {
        if (!getNet().isServer())
            return;
        f32 orbspeed = WizardParams::shoot_max_vel;
        f32 orbDamage = 4.0f;

        if (charge_state == WizardParams::cast_1) {
            orbspeed *= (1.0f/2.0f);
            orbDamage *= 0.5f;
        }
        else if (charge_state == WizardParams::cast_2) {
            orbspeed *= (4.0f/5.0f);
            orbDamage *= 0.7f;
        }
        else if (charge_state == WizardParams::extra_ready) {
            orbspeed *= 1.2f;
            orbDamage *= 1.5f;
        }

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;

        CBlob@ orb = server_CreateBlob( "orb" );
        if (orb !is null)
        {
            orb.set_f32("explosive_damage", orbDamage);

            orb.IgnoreCollisionWhileOverlapped( this );
            orb.SetDamageOwnerPlayer( this.getPlayer() );
            orb.server_setTeamNum( this.getTeamNum() );
            orb.setPosition( orbPos );
            orb.setVelocity( orbVel );
        }
        
    }// orb
    else if (spellName == "firebomb")
    {
        if (!getNet().isServer())
            return;
        f32 orbspeed = WizardParams::shoot_max_vel*0.75f;
        f32 orbDamage = 4.0f;

        if (charge_state == WizardParams::cast_1) {
            orbspeed *= (1.0f/2.0f);
            orbDamage *= 0.5f;
        }
        else if (charge_state == WizardParams::cast_2) {
            orbspeed *= (4.0f/5.0f);
            orbDamage *= 0.7f;
        }
        else if (charge_state == WizardParams::extra_ready) {
            orbspeed *= 1.2f;
            orbDamage *= 1.5f;
        }

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;

        CBlob@ orb = server_CreateBlob( "firebomb" );
        if (orb !is null)
        {
            orb.set_f32("explosive_damage", orbDamage);

            orb.IgnoreCollisionWhileOverlapped( this );
            orb.SetDamageOwnerPlayer( this.getPlayer() );
            orb.server_setTeamNum( this.getTeamNum() );
            orb.setPosition( orbPos );
            orb.setVelocity( orbVel );
        }
        
    }// firebomb
    else if (spellName == "fire_sprite")
    {
        if (!getNet().isServer())
            return;
			
        f32 orbDamage = 2.0f;

        if (charge_state == WizardParams::cast_1) {
            orbDamage *= 0.5f;
        }
        else if (charge_state == WizardParams::cast_2) {
            orbDamage *= 0.7f;
        }
        else if (charge_state == WizardParams::extra_ready) {
            orbDamage *= 1.5f;
        }

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);

        CBlob@ orb = server_CreateBlob( "fire_sprite" );
        if (orb !is null)
        {
            orb.set_f32("explosive_damage", orbDamage);

            orb.IgnoreCollisionWhileOverlapped( this );
            orb.SetDamageOwnerPlayer( this.getPlayer() );
            orb.server_setTeamNum( this.getTeamNum() );
            orb.setPosition( orbPos );
        }
        
    }// fire sprite
    else if (spellName == "frost_ball")
    {
        if (!getNet().isServer())
            return;
        f32 orbspeed = 6.0f;
        f32 orbDamage = 4.0f;

        if (charge_state == WizardParams::cast_1) {
            orbspeed *= (1.0f/2.0f);
            orbDamage *= 0.5f;
        }
        else if (charge_state == WizardParams::cast_2) {
            orbspeed *= (4.0f/5.0f);
            orbDamage *= 0.7f;
        }
        else if (charge_state == WizardParams::extra_ready) {
            orbspeed *= 1.2f;
            orbDamage *= 1.5f;
        }

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;

        CBlob@ orb = server_CreateBlob( "frost_ball" );
        if (orb !is null)
        {
            orb.set_f32("explosive_damage", orbDamage);

            orb.IgnoreCollisionWhileOverlapped( this );
            orb.SetDamageOwnerPlayer( this.getPlayer() );
            orb.server_setTeamNum( this.getTeamNum() );
            orb.setPosition( orbPos );
            orb.setVelocity( orbVel );
        }
        
    }// frost ball
    else if (spellName == "heal")
    {
        f32 orbspeed = 4.0f;
        f32 healAmount = 0.8f;

        if (charge_state == WizardParams::cast_1) {
            orbspeed *= (1.0f/2.0f);
        }
        else if (charge_state == WizardParams::cast_2) {
            orbspeed *= (4.0f/5.0f);
        }
        else if (charge_state == WizardParams::extra_ready) {
            orbspeed *= 1.2f;
        }

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;
		
		if (charge_state == WizardParams::extra_ready)
		{
			Heal(this, healAmount);
        }
		else
		{
			if (getNet().isServer())
			{
				CBlob@ orb = server_CreateBlob( "effect_missile" ); 
				if (orb !is null)
				{
					orb.set_string("effect", "heal");
					orb.set_f32("heal_amount", healAmount);

					orb.IgnoreCollisionWhileOverlapped( this );
					orb.SetDamageOwnerPlayer( this.getPlayer() );
					orb.server_setTeamNum( this.getTeamNum() );
					orb.setPosition( orbPos );
					orb.setVelocity( orbVel );
				}
			}
		}
    }	// heal
    else if (spellName == "revive")
    {
        f32 orbspeed = 4.0f;

        if (charge_state == WizardParams::cast_1) 
		{
            orbspeed *= (1.0f/2.0f);
        }
        else if (charge_state == WizardParams::cast_2) 
		{
            orbspeed *= (4.0f/5.0f);
        }
        else if (charge_state == WizardParams::extra_ready) 
		{
            orbspeed *= 1.2f;
        }

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;	
		
		if (getNet().isServer())
		{
			CBlob@ orb = server_CreateBlob( "effect_missile" ); 
			if (orb !is null)
			{
				orb.set_string("effect", "revive");

				orb.IgnoreCollisionWhileOverlapped( this );
				orb.SetDamageOwnerPlayer( this.getPlayer() );
				orb.server_setTeamNum( this.getTeamNum() );
				orb.setPosition( orbPos );
				orb.setVelocity( orbVel );
			}
		}
		
    }	// revive
    else if (spellName == "counter_spell")
    {
		counterSpell( this );
		
    }// counter spell
    else if (spellName == "magic_missile")
    {
        f32 orbspeed = 2.0f;

        if (charge_state == WizardParams::cast_1) 
		{
            orbspeed *= (1.0f/2.0f);
        }
        else if (charge_state == WizardParams::cast_2) 
		{
            orbspeed *= (4.0f/5.0f);
        }
        else if (charge_state == WizardParams::extra_ready) 
		{
            orbspeed *= 1.2f;
        }

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;	
		
		if (getNet().isServer())
		{
			const int numOrbs = 4;
			for (int i = 0; i < numOrbs; i++)
			{
				CBlob@ orb = server_CreateBlob( "magic_missile" ); 
				if (orb !is null)
				{				
					orb.set_string("effect", "heal");

					orb.IgnoreCollisionWhileOverlapped( this );
					orb.SetDamageOwnerPlayer( this.getPlayer() );
					orb.server_setTeamNum( this.getTeamNum() );
					orb.setPosition( orbPos );
					Vec2f newVel = orbVel;
					newVel.RotateBy( -10 + 5*i, Vec2f());
					orb.setVelocity( newVel );
				}
			}
		}
		this.getSprite().PlaySound("MagicMissile.ogg", 0.8f, 1.0f + XORRandom(3)/10.0f);
		
    }	// magic missile
    else if (spellName == "black_hole")
    {
        if (!getNet().isServer())
            return;
        f32 orbspeed = 6.0f;

        if (charge_state == WizardParams::cast_1) {
            orbspeed *= (1.0f/2.0f);
        }
        else if (charge_state == WizardParams::cast_2) {
            orbspeed *= (4.0f/5.0f);
        }
        else if (charge_state == WizardParams::extra_ready) {
            orbspeed *= 1.2f;
        }

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;

        CBlob@ orb = server_CreateBlob( "black_hole" );
        if (orb !is null)
        {
            orb.IgnoreCollisionWhileOverlapped( this );
            orb.SetDamageOwnerPlayer( this.getPlayer() );
            orb.server_setTeamNum( this.getTeamNum() );
            orb.setPosition( orbPos );
            orb.setVelocity( orbVel );
        } 
    }// black hole
    else if (spellName == "slow")
    {
        f32 orbspeed = 4.0f;
        u16 slowTime = 600;

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;
		
		if (getNet().isServer())
		{
			CBlob@ orb = server_CreateBlob( "effect_missile" ); 
			if (orb !is null)
			{
				orb.set_string("effect", "slow");
				orb.set_u16("slow_time", slowTime);

				orb.IgnoreCollisionWhileOverlapped( this );
				orb.SetDamageOwnerPlayer( this.getPlayer() );
				orb.server_setTeamNum( this.getTeamNum() );
				orb.setPosition( orbPos );
				orb.setVelocity( orbVel );
			}
		}
    }	// slow
    else if (spellName == "haste")
    {
        f32 orbspeed = 4.0f;
        u16 hasteTime = 600;

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f orbPos = this.getPosition() + Vec2f(0.0f,-2.0f);
        Vec2f orbVel = (targetPos- orbPos);
        orbVel.Normalize();
        orbVel *= orbspeed;

		if (charge_state == WizardParams::extra_ready)
		{
			Haste(this, hasteTime);
        }		
		else if (getNet().isServer())
		{
			CBlob@ orb = server_CreateBlob( "effect_missile" ); 
			if (orb !is null)
			{
				orb.set_string("effect", "haste");
				orb.set_u16("haste_time", hasteTime);

				orb.IgnoreCollisionWhileOverlapped( this );
				orb.SetDamageOwnerPlayer( this.getPlayer() );
				orb.server_setTeamNum( this.getTeamNum() );
				orb.setPosition( orbPos );
				orb.setVelocity( orbVel );
			}
		}
    }	// haste
    else if (spellName == "magic_barrier")
    {
        u16 lifetime = 20;

        Vec2f targetPos = aimpos + Vec2f(0.0f,-2.0f);
        Vec2f dirNorm = (targetPos - this.getPosition());
        dirNorm.Normalize();
		Vec2f orbPos = aimpos;	

		CBlob@ orb = server_CreateBlob( "magic_barrier" ); 
		if (orb !is null)
		{
			orb.set_u16("lifetime", lifetime);

			orb.IgnoreCollisionWhileOverlapped( this );
			orb.SetDamageOwnerPlayer( this.getPlayer() );
			orb.server_setTeamNum( this.getTeamNum() );
			orb.setPosition( orbPos );
			orb.setAngleDegrees(-dirNorm.Angle()+90.0f);
		}
    }	// magic barrier
    else if (spellName == "teleport")
    {
		if ( this.get_u16("slowed") > 0 )	//cannot teleport while slowed
		{
			ManaInfo@ manaInfo;
			if (!this.get( "manaInfo", @manaInfo )) {
				return;
			}
			
			manaInfo.mana += spell.mana;
			
			this.getSprite().PlaySound("ManaStunCast.ogg", 1.0f, 1.0f);
		}
		else
		{
			ParticleAnimated( "Flash3.png",
							this.getPosition(),
							Vec2f(0,0),
							float(XORRandom(360)),
							1.0f, 
							3, 
							0.0f, true );
			
			Vec2f aimVector = aimpos - this.getPosition();
			Vec2f aimNorm = aimVector;
			aimNorm.Normalize();
			
			for (uint step = 0; step < aimVector.Length(); step += 8)
			{
				sparks( this.getPosition() + aimNorm*step, 5, aimNorm*4.0f );
			}
				
			this.setPosition( aimpos );
			this.setVelocity( Vec2f_zero );
			
			ParticleAnimated( "Flash3.png",
							this.getPosition(),
							Vec2f(0,0),
							float(XORRandom(360)),
							1.0f, 
							3, 
							0.0f, true );     
							
			this.getSprite().PlaySound("Teleport.ogg", 0.8f, 1.0f);
		}
    }// teleport
    else if (spellName == "zombie_rain" || spellName == "skeleton_rain" || spellName == "meteor_rain" || spellName == "meteor_strike" || spellName == "arrow_rain" )
    {
        if (!getNet().isServer())
            return;
        CBitStream params;
        params.write_string(spellName);
        params.write_u8(charge_state);
        params.write_Vec2f(aimpos);

        this.SendCommand(this.getCommandID("rain"), params);
    }// zombie_rain, skeleton_rain, meteor_rain, meteor_strike
}

Random _sprk_r;
void sparks(Vec2f pos, int amount, Vec2f pushVel = Vec2f(0,0))
{
	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 1.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        CParticle@ p = ParticlePixel( pos, vel + pushVel, SColor( 255, 180+XORRandom(40), 0, 255), true );
        if(p is null) return; //bail if we stop getting particles

        p.timeout = 10 + _sprk_r.NextRanged(20);
        p.scale = 0.5f + _sprk_r.NextFloat();
        p.damping = 0.95f;
		p.gravity = Vec2f(0,0);
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("spell"))  //from standardcontrols
    {
		ManaInfo@ manaInfo;
		if (!this.get( "manaInfo", @manaInfo )) 
		{
			return;
		}
	
        u8 charge_state = params.read_u8();
        Spell spell = WizardParams::spells[params.read_u8()];
        Vec2f aimpos = params.read_Vec2f();
        CastSpell(this, charge_state, spell, aimpos);
		
		manaInfo.mana -= spell.mana;
    }
    if (cmd == this.getCommandID("pick spell"))  //from standardcontrols
    {
        u8 spellID = params.read_u8();
        bool is_secondary = params.read_bool();
        if (is_secondary)
            SetSecondarySpell(this.getPlayer(), spellID);
        else
            SetCustomSpell(this.getPlayer(), spellID);
    }
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (( hitterBlob.getName() == "wraith" || hitterBlob.getName() == "orb" ) && hitterBlob.getTeamNum() == this.getTeamNum())
        return 0;
    return damage;
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (customData == Hitters::stab)
	{
		if (damage > 0.0f)
		{

			// fletch arrow
			if ( hitBlob.hasTag("tree") )	// make arrow from tree
			{
				if (getNet().isServer())
				{
					CBlob@ mat_arrows = server_CreateBlob( "mat_arrows", this.getTeamNum(), this.getPosition() );
					if (mat_arrows !is null)
					{
						mat_arrows.server_SetQuantity(10);//fletch_num_arrows);
						mat_arrows.Tag("do not set materials");
						this.server_PutInInventory( mat_arrows );
					}
				}
				this.getSprite().PlaySound( "Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg" );
			}
			else
				this.getSprite().PlaySound("KnifeStab.ogg");
		}

		if (blockAttack(hitBlob, velocity, 0.0f))
		{
			this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			SetKnocked( this, 30 );
		}
	}
}