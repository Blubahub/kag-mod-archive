// Archer logic

#include "NecromancerCommon.as"
#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";

void onInit( CBlob@ this )
{
	NecromancerInfo necromancer;
	this.set("necromancerInfo", @necromancer);

	this.set_s8( "charge_time", 0 );
	this.set_u8( "charge_state", NecroParams::not_aiming );
	this.set_s32( "mana", 100 );
	this.set_f32("gib health", -3.0f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetEmitSound( "Entities/Characters/Archer/BowPull.ogg" );
	this.addCommandID("shoot arrow");
    this.addCommandID( "pick spell");
    this.addCommandID( "spell");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

    AddIconToken( "$Skeleton$", "SpellIcons.png", Vec2f(16,16), 0 );
    AddIconToken( "$Zombie$", "SpellIcons.png", Vec2f(16,16), 1 );
    AddIconToken( "$Wraith$", "SpellIcons.png", Vec2f(16,16), 2 );
    AddIconToken( "$ZK$", "SpellIcons.png", Vec2f(16,16), 3 );
    AddIconToken( "$Orb$", "SpellIcons.png", Vec2f(16,16), 4 );
    AddIconToken( "$ZombieRain$", "SpellIcons.png", Vec2f(16,16), 5 );
    AddIconToken( "$Teleport$", "SpellIcons.png", Vec2f(16,16), 6 );
    AddIconToken( "$MeteorRain$", "SpellIcons.png", Vec2f(16,16), 7 );
    AddIconToken( "$SkeletonRain$", "SpellIcons.png", Vec2f(16,16), 8 );

	SetHelp( this, "help self action", "necromancer", "$Zombie$ Primary Spell    $LMB$", "", 3 );
	SetHelp( this, "help self action2", "necromancer", "$Orb$ Secondary Spell    $RMB$", "", 3 );
    SetHelp( this, "help self action2", "necromancer", "$Teleport$ Teleport using U", "", 3 );


	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer( CBlob@ this, CPlayer@ player )
{
	if (player !is null){
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16,16));
	}
}

void ManageSpell( CBlob@ this, NecromancerInfo@ necromancer, RunnerMoveVars@ moveVars )
{
	CSprite@ sprite = this.getSprite();
	bool ismyplayer = this.isMyPlayer();
	s32 charge_time = necromancer.charge_time;
	u8 charge_state = necromancer.charge_state;
	Vec2f pos = this.getPosition();
    Vec2f aimpos = this.getAimPos();

    Spell spell = NecroParams::spells[necromancer.primarySpellID];
    s32 mana = necromancer.mana;

    bool is_pressed = this.isKeyPressed( key_action1 );
    bool just_pressed = this.isKeyJustPressed( key_action1 );
    bool just_released = this.isKeyJustReleased( key_action1 );

    bool is_secondary = false;

    if (!is_pressed and !just_released and !just_pressed)//secondary hand
    {
        spell = NecroParams::spells[necromancer.secondarySpellID];

        is_pressed = this.isKeyPressed( key_action2 );
        just_pressed = this.isKeyJustPressed( key_action2 );
        just_released = this.isKeyJustReleased( key_action2 );

        is_secondary = true;
    }

    // info about spell
    s32 readyTime = spell.readyTime;
    u8 spellType = spell.type;

    if (just_pressed)
    {
        charge_time = 0;
        charge_state = 0;
    }
    if (is_pressed && mana >= spell.mana)
    {
        moveVars.walkFactor *= 0.75f;
        charge_time += 1;
        if (charge_time >= spell.full_cast_period)
        {
            charge_state = NecroParams::extra_ready;
            charge_time = spell.full_cast_period;
        }
        else if (charge_time >= spell.cast_period)
        {
            charge_state = NecroParams::cast_3;
        }
        else if (charge_time >= spell.cast_period_2)
        {
            charge_state = NecroParams::cast_2;
        }
        else if (charge_time >= spell.cast_period_1)
        {
            charge_state = NecroParams::cast_1;
        }
    }
    else if (getControls().isKeyJustPressed( KEY_KEY_U )) // teleport using u
    {
        spell = NecroParams::spells[7];
        charge_state = NecroParams::cast_3;
        if (necromancer.mana >= spell.mana && (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot()))
        {
            CBitStream params;
            params.write_u8(charge_state);
            params.write_u8(7);
            params.write_Vec2f(aimpos);
            this.SendCommand(this.getCommandID("spell"), params);
            necromancer.mana -= spell.mana;
            SetKnocked( this, 5 );
        }
    }
    else if (just_released)
    {
        if (necromancer.mana >= spell.mana && charge_state > NecroParams::charging && not (spell.needs_full && charge_state < NecroParams::cast_3) &&
            (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot()))
        {
            CBitStream params;
            params.write_u8(charge_state);
            params.write_u8(is_secondary ? necromancer.secondarySpellID : necromancer.primarySpellID);
            params.write_Vec2f(aimpos);
            this.SendCommand(this.getCommandID("spell"), params);
            necromancer.mana -= spell.mana;
        }
        charge_state = NecroParams::not_aiming;
        charge_time = 0;
    }

    necromancer.charge_time = charge_time;
    necromancer.charge_state = charge_state;

    if ( ismyplayer )
    {
		if (!getHUD().hasButtons()) 
		{
			int frame = 0;
            if (charge_state == NecroParams::extra_ready) {
                frame = 15;
            }
            else if (necromancer.charge_time > spell.cast_period)
            {
                frame = 12 + necromancer.charge_time % 15 / 5;
            }
			else if (necromancer.charge_time > 0) {
				frame = necromancer.charge_time * 12 /spell.cast_period;
			}
			getHUD().SetCursorFrame( frame );
		}

        if (this.isKeyJustPressed(key_action3))
        {
			client_SendThrowOrActivateCommand( this );
        }
    }
}

void onTick( CBlob@ this )
{
    NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer )) {
		return;
	}

	/*if(getKnocked(this) > 0)
	{
		necromancer.charge_state = 0;
		necromancer.charge_time = 0;
		return;
	}*/

    RunnerMoveVars@ moveVars;
    if (!this.get( "moveVars", @moveVars )) {
        return;
    }

	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;

	if (this.isInInventory()) return;

    ManageSpell( this, necromancer, moveVars );
}

void SummonZombie(string name, Vec2f pos, int team)
{
    ParticleZombieLightning( pos );
    if (getNet().isServer())
        server_CreateBlob( name, team, pos );
}

void CastSpell(CBlob@ this, const s8 charge_state, const Spell spell, Vec2f aimpos )
{
    const string spellName = spell.typeName;
    if (spell.type == SpellType::summoning)
    {
        Vec2f pos = aimpos + Vec2f(0.0f,-0.5f*this.getRadius());
        SummonZombie(spellName, pos, this.getTeamNum());
    }//summoning
    else if (spellName == "orb")
    {
        if (!getNet().isServer())
            return;
        f32 orbspeed = NecroParams::shoot_max_vel;
        f32 orbDamage = 4.0f;

        if (charge_state == NecroParams::cast_1) {
            orbspeed *= (1.0f/2.0f);
            orbDamage *= 0.5f;
        }
        else if (charge_state == NecroParams::cast_2) {
            orbspeed *= (4.0f/5.0f);
            orbDamage *= 0.7f;
        }
        else if (charge_state == NecroParams::extra_ready) {
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
    else if (spellName == "teleport")
    {
        ParticleZombieLightning( this.getPosition() );
        this.setPosition( aimpos );
        this.setVelocity( Vec2f_zero );
        ParticleZombieLightning( this.getPosition() );            
        this.getSprite().PlaySound("/Respawn.ogg");
    }// teleport
    else if (spellName == "zombie_rain" || spellName == "skeleton_rain" || spellName == "meteor_rain")
    {
        if (!getNet().isServer())
            return;
        CBitStream params;
        params.write_string(spellName);
        params.write_u8(charge_state);
        params.write_Vec2f(aimpos);

        this.SendCommand(this.getCommandID("rain"), params);
    }// zombie_rain, skeleton_rain, meteor_rain
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("spell"))  //from standardcontrols
    {
        u8 charge_state = params.read_u8();
        Spell spell = NecroParams::spells[params.read_u8()];
        Vec2f aimpos = params.read_Vec2f();
        CastSpell(this, charge_state, spell, aimpos);
    }
    if (cmd == this.getCommandID("pick spell"))  //from standardcontrols
    {
        u8 spellID = params.read_u8();
        bool is_secondary = params.read_bool();
        if (is_secondary)
            SetSecondarySpell(this, spellID);
        else
            SetPrimarySpell(this, spellID);
    }
}

// spell pick menu
void onCreateInventoryMenu( CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu )
{
	if (NecroParams::spells.length == 0) {
		return;
	}

    NecromancerInfo@ necromancer;
    if (!this.get( "necromancerInfo", @necromancer )) {
        return;
    }

    this.ClearGridMenusExceptInventory();
    Vec2f pos( gridmenu.getUpperLeftPosition().x + 0.5f*(gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
               gridmenu.getUpperLeftPosition().y - 32 * 1 - 2*24 );

    CGridMenu@ menu = CreateGridMenu( Vec2f(pos.x, pos.y - 64), this, Vec2f( NecroParams::spells.length, 1 ), "Primary Spell - Left Mouse Button" );
	const u8 primarySpell = necromancer.primarySpellID;

    CGridMenu@ menuS = CreateGridMenu( Vec2f(pos.x, pos.y + 16), this, Vec2f( NecroParams::spells.length, 1 ), "Secondary Spell - Right Mouse Button" );
    const u8 secondarySpell = necromancer.secondarySpellID;

    if (menu !is null && menuS !is null)
    {
		menu.deleteAfterClick = false;
        menuS.deleteAfterClick = false;

        for (uint i = 0; i < NecroParams::spells.length; i++)
        {
            Spell spell = NecroParams::spells[i];

            CBitStream params;
            params.write_u8(i);
            params.write_bool(false);
            CGridButton @button = menu.AddButton( spell.icon, spell.name, this.getCommandID( "pick spell" ), params );
            CBitStream params2;
            params2.write_u8(i);
            params2.write_bool(true);
            CGridButton @button2 = menuS.AddButton( spell.icon, spell.name, this.getCommandID( "pick spell" ), params2 );

            string hoverText = "Mana required: "+spell.mana;
            if (spell.needs_full)
                hoverText += "\nMust be fully charged";

            if (button !is null)
            {
                button.selectOneOnClick = true;
                button.hoverText = hoverText;
				if (primarySpell == i) {
                    button.SetSelected(1);
                }
			}

            if (button2 !is null)
            {
                button2.selectOneOnClick = true;
                button2.hoverText = hoverText;
                if (secondarySpell == i) {
                    button2.SetSelected(1);
                }
            }
        }
    }
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (( hitterBlob.getName() == "wraith" || hitterBlob.getName() == "orb" ) && hitterBlob.getTeamNum() == this.getTeamNum())
        return 0;
    return damage;
}

